import {
  affectedUsers,
  type Environment,
  equalSecret,
  parseEvent,
} from "../_shared/subscription_core.ts";

export interface WebhookDependencies {
  authorization: string;
  appIds: Set<string>;
  environment: Environment;
  processed(id: string): Promise<boolean>;
  userExists(id: string): Promise<boolean>;
  reconcile(id: string): Promise<void>;
  complete(id: string): Promise<void>;
}
async function boundedBody(req: Request): Promise<string | null> {
  if (!req.body) return "";
  const reader = req.body.getReader();
  const chunks: Uint8Array[] = [];
  let size = 0;
  try {
    while (true) {
      const { value, done } = await reader.read();
      if (done) break;
      size += value.length;
      if (size > 65536) {
        await reader.cancel();
        return null;
      }
      chunks.push(value);
    }
  } finally {
    reader.releaseLock();
  }
  const bytes = new Uint8Array(size);
  let offset = 0;
  for (const chunk of chunks) {
    bytes.set(chunk, offset);
    offset += chunk.length;
  }
  return new TextDecoder("utf-8", { fatal: true }).decode(bytes);
}

export async function handleWebhook(
  req: Request,
  deps: WebhookDependencies,
): Promise<Response> {
  if (req.method !== "POST") {
    return Response.json({ error: "Method not allowed" }, { status: 405 });
  }
  if (
    !deps.authorization ||
    !await equalSecret(
      req.headers.get("Authorization") ?? "",
      deps.authorization,
    )
  ) {
    return Response.json({ error: "Unauthorized" }, { status: 401 });
  }
  if (Number(req.headers.get("content-length")) > 65536) {
    return Response.json({ error: "Too large" }, { status: 413 });
  }
  let event;
  try {
    const body = await boundedBody(req);
    if (body === null) {
      return Response.json({ error: "Too large" }, { status: 413 });
    }
    event = parseEvent(JSON.parse(body), deps.appIds, deps.environment);
  } catch (_) {
    return Response.json({ error: "Invalid event" }, { status: 400 });
  }
  try {
    if (await deps.processed(event.id)) {
      return Response.json({ received: true, duplicate: true });
    }
    for (const id of affectedUsers(event)) {
      if (await deps.userExists(id)) await deps.reconcile(id);
    }
    // Persist completion only after every affected account has been reconciled.
    await deps.complete(event.id);
    return Response.json({ received: true });
  } catch (_) {
    return Response.json({ error: "Unable to synchronize. Retry delivery." }, {
      status: 503,
    });
  }
}
