import { CheckArrowIcon } from '@/assets/icons/check-arrow-icon';
import {
  pricingData,
  type PricingData,
} from '@/components/sections/pricing/pricing-data';
import { CtaButton } from '@/components/shared/cta-button';
import { Card } from '@/components/ui/card';
import { trackButtonClick } from '@/lib/analytics';

const PRICING_CARD = {
  bestValue: 'Best Value',
  savePrefix: 'Save $',
  startUsingToday: 'Start using today',
  cancelAnytime: 'Cancel anytime',
} as const;

export const PricingCard = ({ pricing }: { pricing: PricingData }) => {
  const hasMoreThanTwoPlans = pricingData.length > 3;
  const currency = pricing.currency || 'USD';

  const handleClick = async () => {
    await trackButtonClick('pricing_cta', undefined, {
      plan_name: pricing.title,
      plan_price: pricing.discountedPrice,
      currency: currency,
      is_popular: pricing.popular,
    });
    window.location.href = pricing.buttonLink;
  };

  return (
    <Card
      className={`relative flex w-full flex-1 flex-col p-6 md:p-8 ${pricing.popular ? 'border-primary border-2' : ''} ${hasMoreThanTwoPlans ? '' : 'max-w-md'}`}>
      {pricing.popular && (
        <div className='bg-primary text-primary-foreground absolute -top-4 left-1/2 -translate-x-1/2 rounded-(--radius) px-4 py-1 text-sm font-semibold'>
          {PRICING_CARD.bestValue}
        </div>
      )}
      {/* Title */}
      <h3 className='text-card-foreground mb-4 text-left text-xl font-semibold'>
        {pricing.title}
      </h3>
      {/* Price */}
      <div className='mb-2 flex items-end justify-start'>
        <div className='text-foreground mr-2 text-left text-4xl font-semibold sm:text-5xl'>
          ${pricing.discountedPrice}
        </div>
        <div className='flex flex-col'>
          {pricing.oneTimePrice && (
            <div className='text-muted-foreground text-sm line-through'>
              ${pricing.oneTimePrice}
            </div>
          )}
          <div className='text-muted-foreground text-sm'>{currency}</div>
        </div>
        {/* Savings Badge */}
        {pricing.oneTimePrice && (
          <div className='bg-secondary text-secondary-foreground ml-2 hidden w-fit items-center self-center rounded-(--radius) px-2 py-1 text-center text-sm font-medium md:inline-flex'>
            {PRICING_CARD.savePrefix}
            {(pricing.oneTimePrice - pricing.discountedPrice).toFixed(2)}
          </div>
        )}
      </div>
      {/* Features */}
      <ul className='text-card-foreground mt-6 flex-1'>
        {pricing.features.map((text: string, index: number) => (
          <li
            key={`${text}-${index}`}
            className='mb-3 flex items-center text-start'>
            <div className='shrink-0'>
              <CheckArrowIcon showBackground={false} />
            </div>
            <span className='text-foreground text-sm'>{text}</span>
          </li>
        ))}
      </ul>
      <div className='mt-6 flex flex-col gap-3'>
        {/* CTA Button */}
        <CtaButton
          ctaButtonTitle={pricing.button}
          className='w-full! px-4 py-3 text-lg'
          onClick={handleClick}
        />
        <p className='text-muted-foreground text-center text-sm'>
          {pricing.discountedPrice === 0
            ? PRICING_CARD.startUsingToday
            : PRICING_CARD.cancelAnytime}
        </p>
      </div>
    </Card>
  );
};
