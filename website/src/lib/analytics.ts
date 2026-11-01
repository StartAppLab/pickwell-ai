import { logEvent } from 'firebase/analytics';
import CookieManager from '@/components/sections/cookies/cookie-manager';
import { analytics } from '@/lib/firebase';
import type { ButtonSize, ButtonType } from '@/types/button';

const trackEvent = async (
  eventName: string,
  eventData: Record<string, string | number | boolean | undefined>
) => {
  if (!CookieManager.hasAccepted()) {
    return;
  }

  try {
    const analyticsInstance = await analytics;

    if (analyticsInstance) {
      await logEvent(analyticsInstance, eventName, eventData);
    } else if (import.meta.env.DEV) {
      console.warn('Analytics instance not available');
    }
  } catch (error) {
    // Only log errors in development to avoid noise in production
    if (import.meta.env.DEV) {
      console.error('Error tracking analytics event:', error);
    }
  }
};

export const trackButtonClick = async (
  buttonType: ButtonType,
  buttonSize?: ButtonSize,
  additionalData?: Record<string, string | number | boolean>
) => {
  await trackEvent('button_click', {
    button_type: buttonType,
    button_size: buttonSize,
    location: window.location.pathname,
    ...additionalData,
  });
};
