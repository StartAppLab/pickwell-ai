export type PlanTier = 'free' | 'pro' | 'enterprise';

export interface PlanDefinition {
  id: PlanTier;
  name: string;
  price: number;
  interval: 'month' | 'year';
  features: string[];
  limits: Record<string, number | null>;
}

export interface BillingSummary {
  plan: PlanTier;
  status: 'active' | 'trialing' | 'past_due' | 'canceled' | 'none';
  currentPeriodEnd: string | null;
  credits: number;
}

export interface PlanResult {
  summary: BillingSummary;
  definition: PlanDefinition;
}

export interface UsageSnapshot {
  key: string;
  count: number;
  windowStart: string;
  windowEnd: string;
}

export interface PlanGateOptions {
  minimumPlan: PlanTier;
  orgId?: string | null;
  featureKey?: string;
}
