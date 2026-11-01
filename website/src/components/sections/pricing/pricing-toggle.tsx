import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs';

interface PricingToggleProps {
  view: 'monthly' | 'yearly';
  setView: (view: 'monthly' | 'yearly') => void;
  labels: {
    monthly: string;
    yearly: string;
    savePercentage: string;
  };
}

export const PricingToggle = ({
  view,
  setView,
  labels,
}: PricingToggleProps) => {
  return (
    <div className='flex justify-center'>
      <Tabs
        value={view}
        onValueChange={(v) => setView(v as 'monthly' | 'yearly')}
        className='flex items-center justify-center'>
        <TabsList className='grid min-w-[300px] grid-cols-2'>
          <TabsTrigger
            value='monthly'
            className='w-full px-8'>
            {labels.monthly}
          </TabsTrigger>
          <TabsTrigger
            value='yearly'
            className='w-full px-8'>
            {labels.yearly}
            <span className='bg-primary/10 text-primary ml-2 rounded-full px-2 py-0.5 text-xs'>
              {labels.savePercentage}
            </span>
          </TabsTrigger>
        </TabsList>
      </Tabs>
    </div>
  );
};
