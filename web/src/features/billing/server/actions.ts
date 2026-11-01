'use server';

import type { PostgrestError } from '@supabase/supabase-js';
import { revalidatePath } from 'next/cache';
import { z } from 'zod';
import {
  PLAN_DEFINITIONS,
  getPlanDefinition,
  withPlan,
} from '@/features/billing/lib/plan-gate';
import type {
  BillingSummary,
  PlanResult,
  PlanTier,
  UsageSnapshot,
} from '@/features/billing/types';
import { requireAuthState } from '@/lib/auth';
import { insertAuditLog, resolveActiveOrgId } from '@/lib/db';
import {
  type SupabaseServerClient,
  createSupabaseServerClient,
  createSupabaseServiceRoleClient,
} from '@/lib/supabase-server';
import { uuidSchema, validateInput } from '@/lib/validation';
import type { Database } from '@/types/database';

const getPlanSchema = z.object({
  orgId: uuidSchema.nullable().optional(),
});

const checkoutSchema = z.object({
  plan: z.enum(['pro', 'enterprise']),
  orgId: uuidSchema.nullable().optional(),
});

const consumeCreditSchema = z.object({
  key: z.string().min(1),
  amount: z.number().int().positive().default(1),
  orgId: uuidSchema.nullable().optional(),
});

const usageSchema = z.object({
  key: z.string().min(1),
  orgId: uuidSchema.nullable().optional(),
  windowStart: z.string().datetime().optional(),
  windowEnd: z.string().datetime().optional(),
});

const webhookSchema = z.object({
  provider: z.string().min(1),
  externalId: z.string().min(1),
  orgId: uuidSchema.nullable().optional(),
  plan: z.string().optional(),
  status: z.string().optional(),
  currentPeriodEnd: z.string().datetime().optional(),
  payload: z.record(z.string(), z.unknown()),
});

const PLAN_TIERS: PlanTier[] = ['free', 'pro', 'enterprise'];

const flagKeySchema = z.object({
  key: z.string().min(1),
});

const setFlagSchema = flagKeySchema.extend({
  enabled: z.boolean(),
  rollout: z.record(z.string(), z.unknown()).optional(),
});

export async function getPlan(input: unknown): Promise<PlanResult> {
  const payload = await validateInput(getPlanSchema, input);
  const { user } = await requireAuthState('/login');
  const supabase = await createSupabaseServerClient();

  const orgId = await resolveActiveOrgId(
    supabase,
    user.id,
    payload.orgId ?? null
  );
  if (!orgId) {
    return {
      summary: {
        plan: 'free',
        status: 'none',
        currentPeriodEnd: null,
        credits: PLAN_DEFINITIONS.free.limits.credits ?? 0,
      },
      definition: PLAN_DEFINITIONS.free,
    };
  }

  const { data: customer, error } = (await supabase
    .from('billing_customers')
    .select('*')
    .eq('org_id', orgId)
    .maybeSingle()) as {
    data: Database['public']['Tables']['billing_customers']['Row'] | null;
    error: PostgrestError | null;
  };

  if (error) {
    throw new Error(`Unable to load plan: ${error.message}`);
  }

  const plan = normalizePlan(customer?.plan) ?? 'free';

  const { data: wallet, error: walletError } = (await supabase
    .from('credits_wallets')
    .select('credits')
    .eq('org_id', orgId)
    .maybeSingle()) as {
    data: Pick<
      Database['public']['Tables']['credits_wallets']['Row'],
      'credits'
    > | null;
    error: PostgrestError | null;
  };

  if (walletError) {
    throw new Error(`Unable to load credits: ${walletError.message}`);
  }

  const summary: BillingSummary = {
    plan,
    status: normalizeStatus(customer?.status),
    currentPeriodEnd: customer?.current_period_end ?? null,
    credits: wallet?.credits ?? getPlanDefinition(plan).limits.credits ?? 0,
  };

  return {
    summary,
    definition: getPlanDefinition(plan),
  };
}

export async function startCheckoutSession(
  input: unknown
): Promise<{ url: string }> {
  const payload = await validateInput(checkoutSchema, input);
  const { orgId } = await withPlan(
    { minimumPlan: 'free', orgId: payload.orgId ?? null },
    async ({ supabase, orgId, membershipRole, userId }) => {
      if (membershipRole === 'member') {
        throw new Error('Only owners or admins can start billing changes.');
      }

      await insertAuditLog(supabase, {
        orgId,
        userId,
        action: 'billing.checkout.started',
        meta: { plan: payload.plan },
      });

      return { orgId };
    }
  );

  revalidatePath('/settings/billing');
  return {
    url: `https://billing.example.com/checkout?plan=${payload.plan}&org=${orgId}`,
  };
}

export async function consumeCredit(input: unknown): Promise<number> {
  const payload = await validateInput(consumeCreditSchema, input);

  const amount = payload.amount ?? 1;
  const remaining = await withPlan(
    { minimumPlan: 'free', orgId: payload.orgId ?? null },
    async ({ supabase, orgId, plan, userId }) => {
      const limit = getPlanDefinition(plan).limits.credits;

      const { data: wallet, error: walletError } = (await supabase
        .from('credits_wallets')
        .select('*')
        .eq('org_id', orgId)
        .maybeSingle()) as {
        data: Database['public']['Tables']['credits_wallets']['Row'] | null;
        error: PostgrestError | null;
      };

      if (walletError) {
        throw new Error(`Unable to load credits: ${walletError.message}`);
      }

      if (limit === null) {
        await trackUsage(supabase, orgId, payload.key, amount);
        return wallet?.credits ?? 0;
      }

      const currentCredits = wallet?.credits ?? limit;
      if (currentCredits < amount) {
        throw new Error('Not enough credits remaining.');
      }

      const updatedCredits = currentCredits - amount;
      const { error: updateError } = await supabase
        .from('credits_wallets')
        .upsert({
          org_id: orgId,
          credits: updatedCredits,
          refreshed_at: new Date().toISOString(),
        });

      if (updateError) {
        throw new Error(`Unable to update credits: ${updateError.message}`);
      }

      await trackUsage(supabase, orgId, payload.key, amount);
      await insertAuditLog(supabase, {
        orgId,
        userId,
        action: 'billing.credits.consumed',
        meta: { key: payload.key, amount },
      });

      return updatedCredits;
    }
  );

  return remaining;
}

export async function getUsage(input: unknown): Promise<UsageSnapshot> {
  const payload = await validateInput(usageSchema, input);

  return withPlan(
    { minimumPlan: 'free', orgId: payload.orgId ?? null },
    async ({ supabase, orgId }) => {
      const window = resolveWindow(payload.windowStart, payload.windowEnd);

      const { data, error } = (await supabase
        .from('usage_counters')
        .select('*')
        .eq('org_id', orgId)
        .eq('key', payload.key)
        .eq('window_start', window.start)
        .eq('window_end', window.end)
        .maybeSingle()) as {
        data: Database['public']['Tables']['usage_counters']['Row'] | null;
        error: PostgrestError | null;
      };

      if (error) {
        throw new Error(`Unable to load usage: ${error.message}`);
      }

      return {
        key: payload.key,
        count: data?.count ?? 0,
        windowStart: window.start,
        windowEnd: window.end,
      };
    }
  );
}

export async function syncSubscriptionFromWebhook(
  input: unknown
): Promise<void> {
  const payload = await validateInput(webhookSchema, input);
  const supabase = createSupabaseServiceRoleClient();

  const { error: eventError } = await supabase
    .from('billing_events_raw')
    .insert({
      provider: payload.provider,
      org_id: payload.orgId ?? null,
      external_id: payload.externalId,
      payload: payload.payload,
    });

  if (eventError) {
    throw new Error(`Unable to persist webhook event: ${eventError.message}`);
  }

  if (!payload.orgId) {
    return;
  }

  const { error: customerError } = await supabase
    .from('billing_customers')
    .upsert(
      {
        org_id: payload.orgId,
        provider: payload.provider,
        external_id: payload.externalId,
        plan: payload.plan ?? null,
        status: payload.status ?? null,
        current_period_end: payload.currentPeriodEnd ?? null,
      },
      { onConflict: 'org_id' }
    );

  if (customerError) {
    throw new Error(
      `Unable to update billing customer: ${customerError.message}`
    );
  }

  const plan = normalizePlan(payload.plan) ?? 'free';
  const limit = getPlanDefinition(plan).limits.credits;

  if (limit !== null) {
    const { error: walletError } = await supabase
      .from('credits_wallets')
      .upsert(
        {
          org_id: payload.orgId,
          credits: limit,
          refreshed_at: new Date().toISOString(),
        },
        { onConflict: 'org_id' }
      );

    if (walletError) {
      throw new Error(`Unable to refresh credits: ${walletError.message}`);
    }
  }

  revalidatePath('/settings/billing');
}

export async function getFlag(
  input: unknown
): Promise<{ key: string; enabled: boolean }> {
  const payload = await validateInput(flagKeySchema, input);
  await requireAuthState('/login');
  const supabase = await createSupabaseServerClient();
  const { data, error } = (await supabase
    .from('feature_flags')
    .select('key, enabled')
    .eq('key', payload.key)
    .maybeSingle()) as {
    data: Pick<
      Database['public']['Tables']['feature_flags']['Row'],
      'key' | 'enabled'
    > | null;
    error: PostgrestError | null;
  };

  if (error) {
    throw new Error(`Unable to load feature flag: ${error.message}`);
  }

  return {
    key: payload.key,
    enabled: data?.enabled ?? false,
  };
}

export async function setFlag(input: unknown): Promise<void> {
  const payload = await validateInput(setFlagSchema, input);

  await withPlan(
    { minimumPlan: 'free' },
    async ({ supabase, membershipRole, orgId, userId }) => {
      if (membershipRole === 'member') {
        throw new Error('You do not have permission to update feature flags.');
      }

      const { error } = await supabase.from('feature_flags').upsert({
        key: payload.key,
        enabled: payload.enabled,
        rollout: payload.rollout ?? {},
      });

      if (error) {
        throw new Error(`Unable to update feature flag: ${error.message}`);
      }

      await insertAuditLog(supabase, {
        orgId,
        userId,
        action: 'feature.flag.updated',
        meta: { key: payload.key, enabled: payload.enabled },
      });
    }
  );

  revalidatePath('/settings/billing');
}

function normalizePlan(plan: string | null | undefined): PlanTier | null {
  if (!plan) return null;
  const value = plan.toLowerCase() as PlanTier;
  return PLAN_TIERS.includes(value) ? value : null;
}

function normalizeStatus(
  status: string | null | undefined
): BillingSummary['status'] {
  const value = status?.toLowerCase();
  if (
    value === 'trialing' ||
    value === 'active' ||
    value === 'past_due' ||
    value === 'canceled'
  ) {
    return value;
  }
  return 'none';
}

async function trackUsage(
  supabase: SupabaseServerClient,
  orgId: string,
  key: string,
  amount: number
): Promise<void> {
  const window = resolveWindow();
  const { data: existing, error: existingError } = (await supabase
    .from('usage_counters')
    .select('id, count')
    .eq('org_id', orgId)
    .eq('key', key)
    .eq('window_start', window.start)
    .eq('window_end', window.end)
    .maybeSingle()) as {
    data: Pick<
      Database['public']['Tables']['usage_counters']['Row'],
      'id' | 'count'
    > | null;
    error: PostgrestError | null;
  };

  if (existingError) {
    throw new Error(`Unable to read usage counter: ${existingError.message}`);
  }

  const newCount = (existing?.count ?? 0) + amount;

  const { error: upsertError } = await supabase.from('usage_counters').upsert({
    ...(existing?.id ? { id: existing.id } : {}),
    org_id: orgId,
    key,
    count: newCount,
    window_start: window.start,
    window_end: window.end,
  });

  if (upsertError) {
    throw new Error(`Unable to update usage: ${upsertError.message}`);
  }
}

function resolveWindow(
  start?: string | null,
  end?: string | null
): { start: string; end: string } {
  if (start && end) {
    return { start, end };
  }

  const now = new Date();
  const windowStart = new Date(now.getFullYear(), now.getMonth(), 1);
  const windowEnd = new Date(now.getFullYear(), now.getMonth() + 1, 1);

  return {
    start: windowStart.toISOString(),
    end: windowEnd.toISOString(),
  };
}
