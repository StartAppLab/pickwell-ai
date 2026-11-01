import { Badge } from '@/components/ui/badge';
import { getPlan } from '@/features/billing/server/actions';

interface CreditBadgeProps {
  orgId?: string | null;
}

export async function CreditBadge({ orgId }: CreditBadgeProps) {
  const { summary, definition } = await getPlan({ orgId });
  const limit = definition.limits.credits;

  if (limit === null) {
    return <Badge variant='default'>Unlimited credits</Badge>;
  }

  const formatted = new Intl.NumberFormat('en-US').format(summary.credits);
  const variant = summary.credits > limit * 0.1 ? 'default' : 'destructive';
  return <Badge variant={variant}>{formatted} credits</Badge>;
}
