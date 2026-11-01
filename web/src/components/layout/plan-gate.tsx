import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import { BillingPortalButton } from '@/features/billing/components/billing-portal-button';
import { isPlanSufficient } from '@/features/billing/lib/plan-gate';
import { getPlan } from '@/features/billing/server/actions';
import type { PlanTier } from '@/features/billing/types';

interface PlanGateProps {
  requiredPlan: PlanTier;
  orgId?: string | null;
  children: React.ReactNode;
  featureName?: string;
}

export async function PlanGate({
  requiredPlan,
  orgId,
  children,
  featureName,
}: PlanGateProps) {
  const { summary } = await getPlan({ orgId });

  if (isPlanSufficient(summary.plan, requiredPlan)) {
    return <>{children}</>;
  }

  const readableFeature = featureName ?? 'this feature';

  return (
    <Card className='border-dashed'>
      <CardHeader>
        <CardTitle>Upgrade required</CardTitle>
        <CardDescription>
          Your current plan ({summary.plan}) does not include access to{' '}
          {readableFeature}. Upgrade to continue.
        </CardDescription>
      </CardHeader>
      <CardContent>
        <BillingPortalButton
          plan={requiredPlan === 'enterprise' ? 'enterprise' : 'pro'}
          orgId={orgId ?? null}
        />
      </CardContent>
    </Card>
  );
}
