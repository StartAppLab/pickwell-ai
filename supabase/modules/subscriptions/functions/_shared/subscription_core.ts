export type Environment = "PRODUCTION" | "SANDBOX";
export interface Grant {
  entitlement_id: string;
  product_id: string;
  is_active: boolean;
  is_non_expiring: boolean;
  expires_at: string | null;
}
export const uuid = (value: unknown): value is string =>
  typeof value === "string" &&
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(value);

const object = (value: unknown): Record<string, unknown> => {
  if (value === null || typeof value !== "object" || Array.isArray(value)) {
    throw new Error("Invalid object");
  }
  return value as Record<string, unknown>;
};
const date = (value: unknown): string | null => {
  if (value === null) return null;
  if (typeof value !== "string" || !Number.isFinite(Date.parse(value))) {
    throw new Error("Invalid date");
  }
  return new Date(value).toISOString();
};

/** Fail closed on malformed data. Sandbox transactions never authorize production. */
export function grantsFromCustomer(
  body: unknown,
  environment: Environment,
  now = Date.now(),
): Grant[] {
  const subscriber = object(object(body).subscriber);
  const entitlements = object(subscriber.entitlements);
  const subscriptions = object(subscriber.subscriptions);
  const nonSubscriptions = object(subscriber.non_subscriptions);
  const result: Grant[] = [];
  for (const [id, raw] of Object.entries(entitlements)) {
    const entitlement = object(raw);
    const product = entitlement.product_identifier;
    if (!id || id.length > 200 || typeof product !== "string" || !product) {
      throw new Error("Invalid entitlement");
    }
    const expiry = date(entitlement.expires_date);
    const grace = entitlement.grace_period_expires_date === undefined
      ? null
      : date(entitlement.grace_period_expires_date);
    const validUntil =
      grace && (!expiry || Date.parse(grace) > Date.parse(expiry))
        ? grace
        : expiry;
    const subscription = subscriptions[product] === undefined
      ? null
      : object(subscriptions[product]);
    const purchases = nonSubscriptions[product];
    if (purchases !== undefined && !Array.isArray(purchases)) {
      throw new Error("Invalid transactions");
    }
    const transactions = (purchases as unknown[] | undefined)?.map(object) ??
      [];
    const correctEnvironment = (item: Record<string, unknown>) =>
      typeof item.is_sandbox === "boolean" &&
      item.is_sandbox === (environment === "SANDBOX");
    // Promotional lifetime grants have no store transaction; require explicit server metadata.
    const promotional = subscription?.store === "promotional" &&
      correctEnvironment(subscription);
    const lifetime = expiry === null && grace === null &&
      (transactions.some((item) =>
        correctEnvironment(item) && item.refunded_at == null
      ) || promotional);
    const environmentMatches = subscription
      ? correctEnvironment(subscription) && subscription.refunded_at == null
      : transactions.some((item) =>
        correctEnvironment(item) && item.refunded_at == null
      );
    if (!environmentMatches) continue;
    result.push({
      entitlement_id: id,
      product_id: product,
      is_active: lifetime ||
        (validUntil !== null && Date.parse(validUntil) > now),
      is_non_expiring: lifetime,
      expires_at: lifetime ? null : validUntil,
    });
  }
  return result;
}

export interface WebhookEvent {
  id: string;
  type: string;
  app_id?: string | null;
  store?: string;
  original_app_user_id?: string;
  aliases?: string[];
  environment?: Environment;
  app_user_id?: string;
  transferred_from?: string[];
  transferred_to?: string[];
}
export function parseEvent(
  body: unknown,
  appIds: Set<string>,
  environment: Environment,
): WebhookEvent {
  const event = object(object(body).event);
  for (const field of ["id", "type"]) {
    if (
      typeof event[field] !== "string" || !(event[field] as string).length ||
      (event[field] as string).length > 200
    ) {
      throw new Error("Invalid event");
    }
  }
  if (event.app_id == null) {
    // These project-level events may have no store app. The integration's unique
    // secret authenticates them; grants still come from the project-scoped API.
    if (
      event.store !== "PROMOTIONAL" &&
      !["TRANSFER", "SUBSCRIBER_ALIAS"].includes(event.type as string)
    ) {
      throw new Error("Missing RevenueCat app");
    }
  } else if (typeof event.app_id !== "string" || !appIds.has(event.app_id)) {
    throw new Error("Unexpected RevenueCat app");
  }
  // TRANSFER may omit environment; reconciliation still filters actual transactions.
  if (event.environment !== undefined && event.environment !== environment) {
    throw new Error("Unexpected environment");
  }
  for (const field of ["transferred_from", "transferred_to", "aliases"]) {
    if (
      event[field] !== undefined &&
      (!Array.isArray(event[field]) ||
        (event[field] as unknown[]).length > 100 ||
        !(event[field] as unknown[]).every((value) =>
          typeof value === "string"
        ))
    ) throw new Error("Invalid transfer");
  }
  if (
    event.type === "TRANSFER" &&
    (!Array.isArray(event.transferred_from) ||
      !Array.isArray(event.transferred_to))
  ) {
    throw new Error("Missing transfer identities");
  }
  for (const field of ["app_user_id", "original_app_user_id"]) {
    if (event[field] !== undefined && typeof event[field] !== "string") {
      throw new Error("Invalid identity");
    }
  }
  return event as unknown as WebhookEvent;
}
export function affectedUsers(event: WebhookEvent): string[] {
  // Trusted webhook aliases discover candidates only. Each existing signed-in
  // UUID is independently reconciled via the server API; no event grants access.
  const ids = event.type === "TRANSFER"
    ? [...event.transferred_from ?? [], ...event.transferred_to ?? []]
    : [event.app_user_id, event.original_app_user_id, ...event.aliases ?? []];
  return [...new Set(ids.filter(uuid).map((id) => id.toLowerCase()))];
}
export async function equalSecret(
  actual: string,
  expected: string,
): Promise<boolean> {
  const digest = async (value: string) =>
    new Uint8Array(
      await crypto.subtle.digest("SHA-256", new TextEncoder().encode(value)),
    );
  const [a, b] = await Promise.all([digest(actual), digest(expected)]);
  let difference = 0;
  for (let i = 0; i < a.length; i++) difference |= a[i] ^ b[i];
  return difference === 0;
}

export class SyncBusy extends Error {}
