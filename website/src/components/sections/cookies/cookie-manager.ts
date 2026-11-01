type ConsentStatus = 'accepted' | 'rejected' | 'pending';

class CookieManager {
  private static CONSENT_KEY = 'pickwell-cookie-consent';

  static getConsentStatus(): ConsentStatus {
    if (typeof window === 'undefined') return 'pending';

    const stored = localStorage.getItem(this.CONSENT_KEY);
    if (!stored) return 'pending';
    return stored as ConsentStatus;
  }

  static setConsent(status: ConsentStatus) {
    if (typeof window === 'undefined') return;
    localStorage.setItem(this.CONSENT_KEY, status);
  }

  static hasAccepted(): boolean {
    return this.getConsentStatus() === 'accepted';
  }
}

export default CookieManager;
