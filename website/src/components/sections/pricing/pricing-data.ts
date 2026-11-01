export interface PricingData {
  title: string;
  discountedPrice: number;
  oneTimePrice?: number;
  currency: string;
  features: string[];
  button: string;
  buttonLink: string;
  popular: boolean;
  monthlyPrice?: number;
}

export const pricingData: PricingData[] = [
  {
    title: 'Free',
    discountedPrice: 0,
    currency: ' ',
    features: [
      'Up to 50 notes',
      'Up to 3 folders',
      'Basic text formatting',
      'Checklists',
      'Local storage',
      'Works offline',
      'No account required',
    ],
    button: 'Download Free',
    buttonLink: '/download',
    popular: false,
  },
  {
    title: 'Monthly Pro',
    discountedPrice: 2.99,
    currency: '/month',
    features: [
      'Everything in Free',
      'Unlimited notes',
      'Unlimited folders',
      'Tags & smart search',
      'Rich text & markdown',
      'Cloud sync',
    ],
    button: 'Unlock Monthly Pro',
    buttonLink: '/download',
    popular: false,
  },
  {
    title: 'Yearly Pro',
    discountedPrice: 19.99,
    oneTimePrice: 35.88,
    monthlyPrice: 1.67,
    currency: '/year',
    features: [
      'Everything in Free',
      'Unlimited notes',
      'Unlimited folders',
      'Tags & smart search',
      'Rich text & markdown',
      'Cloud sync',
    ],
    button: 'Unlock Yearly Pro',
    buttonLink: '/download',
    popular: true,
  },
];
