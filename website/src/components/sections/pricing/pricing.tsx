import { useState } from 'react';
import { PricingCard } from '@/components/sections/pricing/pricing-card';
import { pricingData } from '@/components/sections/pricing/pricing-data';
import { PricingToggle } from '@/components/sections/pricing/pricing-toggle';
import { MotionWrapper } from '@/components/shared/motion-wrapper';

const sectionConfig = {
  sectionId: 'pricing',
  content: {
    subtitle: 'Pricing',
    title: 'Simple, Transparent Pricing',
    description:
      'Start for free with generous limits, then upgrade to Pro for unlimited notes, advanced organization, and premium features.',
  },
};

export const Pricing = () => {
  const [billingCycle, setBillingCycle] = useState<'monthly' | 'yearly'>(
    'yearly'
  );

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const visiblePlans = pricingData.filter((plan) => {
    if (plan.title === 'Free') return true;
    if (billingCycle === 'monthly' && plan.title.includes('Monthly'))
      return true;
    if (billingCycle === 'yearly' && plan.title.includes('Yearly')) return true;
    return false;
  });

  const monthlyPlan = pricingData.find((p) => p.title.includes('Monthly'));
  const yearlyPlan = pricingData.find((p) => p.title.includes('Yearly'));

  const savePercentage =
    monthlyPlan && yearlyPlan
      ? Math.round(
          ((monthlyPlan.discountedPrice * 12 - yearlyPlan.discountedPrice) /
            (monthlyPlan.discountedPrice * 12)) *
            100
        )
      : 0;

  // Show pricing toggle by changing this value to visiblePlans else pricingData
  const plans = pricingData; // visiblePlans or pricingData

  return (
    <section className='section-style bg-background'>
      <div
        className='absolute -top-16'
        id={sectionConfig.sectionId}
      />
      <div className='section-size max-w-screen-3xl'>
        <MotionWrapper>
          <div className='flex flex-col gap-12'>
            <div className='flex flex-col items-center gap-6 text-center'>
              {/* Subtitle */}
              <p className='block-subtitle'>{sectionConfig.content.subtitle}</p>
              {/* Title */}
              <h2 className='block-big-title max-w-3xl'>
                {sectionConfig.content.title}
              </h2>
              {/* Description */}
              <p className='text-muted-foreground max-w-2xl text-lg'>
                {sectionConfig.content.description}
              </p>
              {/* Pricing Toggle */}
              {plans.length < 3 && (
                <PricingToggle
                  view={billingCycle}
                  setView={setBillingCycle}
                  labels={{
                    monthly: 'Monthly',
                    yearly: 'Yearly',
                    savePercentage: `Save ${savePercentage}%`,
                  }}
                />
              )}
            </div>

            {/* Plans */}
            <div className='flex flex-col items-stretch justify-center gap-6 sm:mx-auto lg:mx-0 lg:flex-row'>
              {plans.map((plan) => (
                <PricingCard
                  key={plan.title}
                  pricing={plan}
                />
              ))}
            </div>
          </div>
        </MotionWrapper>
      </div>
    </section>
  );
};
