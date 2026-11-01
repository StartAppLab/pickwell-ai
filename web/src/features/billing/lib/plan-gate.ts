import type { PostgrestError } from '@supabase/supabase-js';
import type {
  PlanDefinition,
  PlanGateOptions,
  PlanTier,
} from '@/features/billing/types';
import type { OrgRole } from '@/features/orgs/types';
import { requireAuthState } from '@/lib/auth';
import { fetchMemberships, resolveActiveOrgId } from '@/lib/db';
import {
  type SupabaseServerClient,
  createSupabaseServerClient,
} from '@/lib/supabase-server';
import type { Database } from '@/types/database';

export const PLAN_ORDER: PlanTier[] = ['free', 'pro', 'enterprise'];

export const PLAN_DEFINITIONS: Record<PlanTier, PlanDefinition> = {
  free: {
    id: 'free',
    name: 'Free',
    price: 0,
    interval: 'month',
    features: ['Basic analytics', 'Community support'],
    limits: {
      credits: 100,
    },
  },
  pro: {
    id: 'pro',
    name: 'Pro',
    price: 49,
    interval: 'month',
    features: [
      'Usage-based credits',
      'Priority email support',
      'Advanced automation',
    ],
    limits: {
      credits: 1000,
    },
  },
  enterprise: {
    id: 'enterprise',
    name: 'Enterprise',
    price: 199,
    interval: 'month',
    features: [
      'Unlimited credits',
      'Dedicated success manager',
      'Custom integrations',
    ],
    limits: {
      credits: null,
    },
  },
};

export function getPlanDefinition(plan: PlanTier): PlanDefinition {
  switch (plan) {
    case 'free':
      return PLAN_DEFINITIONS.free;
    case 'pro':
      return PLAN_DEFINITIONS.pro;
    case 'enterprise':
      return PLAN_DEFINITIONS.enterprise;
  }
}

export interface PlanContext {
  supabase: SupabaseServerClient;
  orgId: string;
  plan: PlanTier;
  membershipRole: OrgRole;
  userId: string;
}

export async function withPlan<T>(
  options: PlanGateOptions,
  handler: (context: PlanContext) => Promise<T>
): Promise<T> {
  const auth = await requireAuthState('/login');
  const supabase = await createSupabaseServerClient();

  const orgId = await resolveActiveOrgId(supabase, auth.user.id, options.orgId);
  if (!orgId) {
    throw new Error(
      'No organization selected. Create or join an organization to continue.'
    );
  }

  const memberships = await fetchMemberships(supabase, auth.user.id);
  const membership = memberships.find((row) => row.org_id === orgId);

  if (!membership) {
    throw new Error('You do not have access to that organization.');
  }

  const { data: billing, error } = (await supabase
    .from('billing_customers')
    .select('plan')
    .eq('org_id', orgId)
    .maybeSingle()) as {
    data: Pick<
      Database['public']['Tables']['billing_customers']['Row'],
      'plan'
    > | null;
    error: PostgrestError | null;
  };

  if (error) {
    throw new Error(`Unable to load billing information: ${error.message}`);
  }

  const plan = normalizePlan(billing?.plan) ?? 'free';

  if (!isPlanSufficient(plan, options.minimumPlan)) {
    throw new Error('Your current plan does not include this feature.');
  }

  if (options.featureKey) {
    const { data: flag, error: flagError } = (await supabase
      .from('feature_flags')
      .select('enabled')
      .eq('key', options.featureKey)
      .maybeSingle()) as {
      data: Pick<
        Database['public']['Tables']['feature_flags']['Row'],
        'enabled'
      > | null;
      error: PostgrestError | null;
    };

    if (flagError) {
      throw new Error(`Unable to evaluate feature flag: ${flagError.message}`);
    }

    if (flag && !flag.enabled) {
      throw new Error('This feature is currently disabled.');
    }
  }

  return handler({
    supabase,
    orgId,
    plan,
    membershipRole: membership.role,
    userId: auth.user.id,
  });
}

function normalizePlan(plan: string | null | undefined): PlanTier | null {
  if (!plan) return null;
  const candidate = plan.toLowerCase() as PlanTier;
  return PLAN_ORDER.includes(candidate) ? candidate : null;
}

export function isPlanSufficient(plan: PlanTier, minimum: PlanTier): boolean {
  return PLAN_ORDER.indexOf(plan) >= PLAN_ORDER.indexOf(minimum);
}
