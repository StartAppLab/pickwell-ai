import { type NextRequest, NextResponse } from 'next/server';
import { syncSubscriptionFromWebhook } from '@/features/billing/server/actions';

export async function POST(request: NextRequest) {
  const payload = await request.json();
  const provider = payload.provider;
  const externalId = payload.externalId;

  if (!provider || !externalId) {
    return NextResponse.json(
      { error: 'provider and externalId are required' },
      { status: 400 }
    );
  }

  await syncSubscriptionFromWebhook({
    provider: String(provider),
    externalId: String(externalId),
    orgId: payload.orgId ?? null,
    plan: payload.plan ?? null,
    status: payload.status ?? null,
    currentPeriodEnd: payload.currentPeriodEnd ?? null,
    payload,
  });

  return NextResponse.json({ ok: true });
}
