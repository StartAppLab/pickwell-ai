const appName = 'StartAppNotes';

const sectionConfig = {
  sectionId: 'cookies',
  content: {
    title: 'Cookie Policy',
    lastUpdated: 'January 28, 2026',
  },
  contact: {
    email: 'hello@startapplab.com',
    website: 'https://startapplab.com/contact',
  },
};

export const Cookies = () => {
  return (
    <section className='px-4 py-20 md:px-8 md:py-24'>
      <div className='mx-auto max-w-3xl'>
        <h1 className='mb-8 text-4xl font-semibold tracking-tight'>
          {sectionConfig.content.title}
        </h1>
        <p className='text-muted-foreground mb-6'>
          Last Updated: {sectionConfig.content.lastUpdated}
        </p>

        <div className='space-y-10'>
          <section>
            <h2 className='mb-6 text-2xl font-semibold'>Introduction</h2>
            <p className='mb-6'>
              This Cookie Policy explains how {appName} (&quot;we&quot;,
              &quot;us&quot;, or &quot;our&quot;) uses cookies and similar
              technologies in our mobile application (the &quot;App&quot;) and
              on our website. It explains what these technologies are and why we
              use them, as well as your rights to control our use of them.
            </p>
            <p className='mb-6'>
              {appName} is designed with privacy in mind. We use minimal
              tracking technologies on our website and in our App for essential
              functionality and optional analytics.
            </p>
            <p>
              By using or accessing our App or website, you agree to this Cookie
              Policy. This policy may change from time to time and your
              continued use of the App or website is deemed to be acceptance of
              such changes.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              Our Approach to Data Minimization
            </h2>
            <p className='mb-6'>
              At {appName}, we are committed to collecting only the data that is
              necessary to provide you with a better experience. We follow data
              minimization principles by:
            </p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>
                Collecting only the information needed to understand app usage
                and improve functionality
              </li>
              <li>
                Setting reasonable expiration dates for cookies and similar
                technologies to ensure they don&apos;t persist longer than
                necessary
              </li>
              <li>
                Anonymizing and aggregating data whenever possible to protect
                your privacy
              </li>
              <li>
                Encrypting data in transit and at rest when using cloud services
              </li>
              <li>
                Providing you with control over your data and privacy settings
              </li>
            </ul>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              What are Cookies and Similar Technologies?
            </h2>
            <p className='mb-6'>
              Cookies are small data files that are placed on your device when
              you visit a website. In mobile applications like ours, we use
              similar technologies such as device identifiers, local storage,
              and analytics tools to achieve the same purposes as cookies in web
              browsers.
            </p>
            <p>
              These technologies help us provide and improve the App&apos;s
              functionality, remember your preferences, and analyze usage
              patterns (in anonymized form only).
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              Why Do We Use Cookies and Similar Technologies?
            </h2>
            <p className='mb-6'>
              We use cookies and similar technologies for the following
              purposes:
            </p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>
                <strong>Essential functionality:</strong> These are necessary
                for the App and website to function properly. They help us
                remember your preferences, maintain session state, and sync your
                data across devices.
              </li>
              <li>
                <strong>Authentication:</strong> If you have an account, we use
                cookies to keep you logged in and sync your data securely.
              </li>
              <li>
                <strong>Analytics (optional):</strong> These help us understand
                how visitors interact with our App and website by collecting and
                reporting information anonymously. We use this data to improve
                the user experience and optimize our content. This data is
                anonymized and aggregated.
              </li>
              <li>
                <strong>Crash reporting (optional):</strong> These help us
                identify and fix bugs in the App. No personal data is included
                in crash reports.
              </li>
            </ul>
            <p>
              We do not use cookies or similar technologies for advertising,
              marketing to third parties, or behavioral tracking of individual
              users.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>Technologies We Use</h2>
            <p className='mb-6'>
              The specific cookies and similar technologies we use include:
            </p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>
                <strong>Local Storage:</strong> We use local storage to store
                information about your preferences (such as theme settings and
                subscription status) and to personalize the App for you. This
                data remains on your device.
              </li>
              <li>
                <strong>Secure Cloud Storage:</strong> If you use cloud sync,
                your data is encrypted and stored securely on our servers to
                enable access across your devices.
              </li>
              <li>
                <strong>Device Identifiers:</strong> We may use device
                identifiers for analytics purposes (anonymized only) and to
                ensure compatibility with your device.
              </li>
              <li>
                <strong>Authentication Tokens:</strong> If you have an account,
                we use secure tokens to keep you logged in and protect your
                data.
              </li>
              <li>
                <strong>Optional Analytics:</strong> We may use optional
                analytics services to analyze the use of our App and website.
                These services gather information about app use in anonymized
                form. The information gathered is used to create reports about
                the use of our App and website to help us improve functionality.
              </li>
            </ul>
            <p>
              Your content is never tracked or analyzed. Only anonymized usage
              data (such as which features are used most) may be collected if
              you opt in to analytics.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              Third-Party Services
            </h2>
            <p className='mb-6'>
              Our App and website may integrate with third-party services for
              essential functionality:
            </p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>
                <strong>Payment Processing:</strong> Apple&apos;s App Store
                (iOS) and Google Play Store (Android) for subscription
                management. These services have their own privacy policies.
              </li>
              <li>
                <strong>Cloud Infrastructure:</strong> Secure cloud services for
                data sync and storage. Your data is encrypted and handled in
                accordance with our Privacy Policy.
              </li>
              <li>
                <strong>Optional Analytics:</strong> Optional analytics services
                to help us understand app usage and improve functionality
                (anonymized data only).
              </li>
              <li>
                <strong>Crash Reporting:</strong> Optional crash reporting
                services to help us identify and fix bugs (no personal data
                included).
              </li>
            </ul>
            <p>
              These third parties may use cookies or similar technologies, but
              they do not have access to your personal content. We carefully
              select our partners and require them to handle your data securely.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              Your Choices Regarding Cookies and Tracking
            </h2>
            <p className='mb-6'>
              You have control over how cookies and similar technologies are
              used:
            </p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>
                <strong>In the App:</strong> You can control some data
                collection through your device settings. Optional analytics can
                be disabled if you prefer.
              </li>
              <li>
                <strong>On our website:</strong> When you first visit our
                website, you may be presented with a cookie consent banner that
                allows you to accept or decline non-essential cookies. You can
                change your preferences at any time by clearing your browser
                cookies and revisiting our site.
              </li>
              <li>
                <strong>Browser settings:</strong> You can configure your
                browser to warn you each time a cookie is being sent, or you can
                choose to turn off all cookies. You do this through your browser
                settings. Since each browser is different, please refer to your
                browser&apos;s Help Menu to learn the correct way to modify your
                cookies.
              </li>
            </ul>
            <p className='mb-6'>If you decline cookies or disable them:</p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>
                Essential cookies will still be used as they are necessary for
                the App and website to function properly
              </li>
              <li>
                Some features may be disabled, and some parts of the App or
                website may not function optimally
              </li>
              <li>Your preferences may not be saved between sessions</li>
              <li>
                We will not be able to collect information about your usage to
                improve our App and website
              </li>
            </ul>
            <p>
              Even if you decline cookies, you can still use our App and
              website, though some functionality may be limited.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              Data Storage and Retention
            </h2>
            <p className='mb-6'>
              Your data may be stored locally on your device or synced to the
              cloud depending on your settings:
            </p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>
                Local data remains on your device until you delete the App or
                clear its data
              </li>
              <li>
                Cloud-synced data is retained until you delete it or close your
                account
              </li>
            </ul>
            <p className='mb-6'>
              Any limited information collected through cookies and similar
              technologies (such as anonymized analytics data) is retained only
              for as long as necessary to fulfill the purposes outlined in this
              Cookie Policy.
            </p>
            <p className='mb-6'>
              Analytics and usage data is typically retained for a maximum of 26
              months, after which it is either deleted or fully anonymized and
              aggregated for long-term statistical purposes.
            </p>
            <p>
              Preference data stored locally on your device (such as theme
              settings and subscription status) remains on your device until you
              delete the App or clear its data.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>Do Not Track</h2>
            <p className='mb-6'>
              Some internet browsers and devices have &quot;Do Not Track&quot;
              features that allow you to tell websites and applications not to
              track your online activities. We respect your privacy choices and
              will honor Do Not Track signals where technically feasible.
            </p>
            <p>
              However, please note that some essential functionality may still
              require minimal data collection to operate properly.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              Updates to This Cookie Policy
            </h2>
            <p>
              We may update this Cookie Policy from time to time in order to
              reflect changes to the cookies and similar technologies we use or
              for other operational, legal, or regulatory reasons. Please
              revisit this Cookie Policy regularly to stay informed about our
              use of cookies and related technologies. The date at the top of
              this Cookie Policy indicates when it was last updated.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>Contact Us</h2>
            <p className='mb-6'>
              If you have any questions about our use of cookies or other
              technologies, please contact us:
            </p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>
                By email:{' '}
                <a
                  href={`mailto:${sectionConfig.contact.email}`}
                  className='text-primary underline'>
                  {sectionConfig.contact.email}
                </a>
              </li>
              <li>
                By visiting the contact page on our website:{' '}
                <a
                  href={sectionConfig.contact.website}
                  target='_blank'
                  rel='noopener noreferrer'
                  className='text-primary underline'>
                  {sectionConfig.contact.website}
                </a>
              </li>
            </ul>
          </section>
        </div>
      </div>
    </section>
  );
};
