const appName = 'StartAppNotes';

const sectionConfig = {
  sectionId: 'privacy',
  content: {
    title: 'Privacy Policy',
    lastUpdated: 'January 28, 2026',
  },
  contact: {
    email: 'hello@startapplab.com',
    website: 'https://startapplab.com/contact',
  },
};

export const Privacy = () => {
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
              At {appName} (&quot;we,&quot; &quot;our,&quot; or &quot;us&quot;),
              we are committed to protecting your privacy. This Privacy Policy
              explains how we collect, use, disclose, and safeguard your
              information when you use our mobile application (the
              &quot;App&quot;).
            </p>
            <p className='mb-6'>
              {appName} is designed with privacy in mind. We collect only the
              minimum information necessary to provide and improve our services.
            </p>
            <p>
              By using or accessing our App, you agree to the collection and use
              of information in accordance with this policy.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              Information We Collect
            </h2>
            <p className='mb-6'>
              We collect minimal information to provide and improve our
              services. The information we may collect includes:
            </p>

            <h3 className='mb-2 text-xl font-medium'>Usage Data</h3>
            <p className='mb-6'>
              Information about how you use the App, including features accessed
              and time spent. This helps us improve the App&apos;s functionality
              and user experience.
            </p>

            <h3 className='mb-2 text-xl font-medium'>Device Information</h3>
            <p className='mb-6'>
              Device type, operating system version, and app version. This
              information helps us ensure compatibility and provide appropriate
              support.
            </p>

            <h3 className='mb-2 text-xl font-medium'>User Content</h3>
            <p className='mb-6'>
              Content you create within the App may be stored locally on your
              device and/or synced to the cloud depending on your settings.
            </p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>
                Local storage: Data stored on your device remains under your
                control
              </li>
              <li>
                Cloud sync: If enabled, your data is encrypted and stored
                securely on our servers
              </li>
            </ul>

            <h3 className='mb-2 text-xl font-medium'>Account Data</h3>
            <p className='mb-6'>
              If you create an account, we collect your email address and any
              profile information you provide. This allows us to sync your data
              across devices and provide support.
            </p>

            <h3 className='mb-2 text-xl font-medium'>Subscription Data</h3>
            <p className='mb-6'>
              Information related to your subscription status and payment is
              processed securely through Apple&apos;s App Store (iOS) or Google
              Play Store (Android). {appName} does not store or process payment
              information directly.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              How We Use Your Information
            </h2>
            <p className='mb-6'>
              We use the information we collect for the following purposes:
            </p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>Provide and improve the App&apos;s functionality</li>
              <li>Sync your data across devices (if you use cloud sync)</li>
              <li>Process subscription payments through Apple or Google</li>
              <li>Send important updates and notifications (if you opt in)</li>
              <li>Provide customer support</li>
              <li>
                Analyze usage patterns to enhance user experience (anonymized
                data only)
              </li>
              <li>
                Ensure compatibility with your device and operating system
              </li>
            </ul>
            <p>
              We do not use your information for advertising, marketing to third
              parties, or any purpose other than providing and improving the
              App.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              Data Storage and Security
            </h2>
            <p className='mb-6'>
              {appName} is designed with privacy and security as core
              principles:
            </p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>
                Your data may be stored locally on your device and/or in the
                cloud
              </li>
              <li>Cloud data is encrypted in transit and at rest</li>
              <li>
                We use industry-standard security measures to protect your data
              </li>
              <li>
                Subscription data is processed securely through Apple&apos;s or
                Google&apos;s payment systems
              </li>
            </ul>
            <p className='mb-6'>
              Data stored locally on your device is protected by your
              device&apos;s built-in security features. You are responsible for
              backing up your local data. {appName} is not responsible for any
              loss of locally stored data.
            </p>
            <p>
              No method of electronic storage is 100% secure. While we strive to
              use commercially acceptable means to protect your data, we cannot
              guarantee its absolute security.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>Data Sharing</h2>
            <p className='mb-6'>
              We do not sell, trade, or share your personal information with
              third parties for marketing purposes.
            </p>
            <p className='mb-6'>
              We may share limited information in the following circumstances:
            </p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>When required by law or legal process</li>
              <li>To protect and defend our rights or property</li>
              <li>With your explicit consent</li>
              <li>
                With service providers who assist in app functionality (such as
                Apple or Google for payment processing) under strict
                confidentiality agreements
              </li>
            </ul>
            <p>
              We may share aggregated, anonymized, non-personally identifiable
              information for analytical purposes, but this does not include
              your personal data or content.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              Third-Party Services
            </h2>
            <p className='mb-6'>
              Our App integrates with third-party services for essential
              functionality:
            </p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>
                <strong>Payment Processing:</strong> Apple&apos;s App Store
                (iOS) and Google Play Store (Android) for subscription
                management and payment processing
              </li>
              <li>
                <strong>Cloud Services:</strong> Secure cloud infrastructure for
                data sync and storage
              </li>
              <li>
                <strong>App Analytics:</strong> Optional analytics services to
                help us understand app usage and improve functionality
                (anonymized data only)
              </li>
              <li>
                <strong>Crash Reporting:</strong> Optional crash reporting
                services to help us identify and fix bugs (no personal data
                included)
              </li>
            </ul>
            <p>
              These services have their own privacy policies, which we encourage
              you to review.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>Your Rights</h2>
            <p className='mb-6'>You have the right to:</p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>Access any personal data we hold about you</li>
              <li>Request correction of inaccurate information</li>
              <li>Request deletion of your information</li>
              <li>Export your data in a portable format</li>
              <li>Opt out of certain data collection (where applicable)</li>
              <li>Withdraw consent for data processing</li>
              <li>Delete your content at any time through the App</li>
            </ul>
            <p>
              To exercise any of these rights, please contact us using the
              information provided in the &quot;Contact Us&quot; section of this
              Privacy Policy.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              Children&apos;s Privacy
            </h2>
            <p className='mb-6'>
              Our App is intended for use by individuals who are at least 13
              years of age. We do not knowingly collect personally identifiable
              information from children under 13. If we learn that we have
              collected personal information from a child under 13, we will
              delete that information as quickly as possible.
            </p>
            <p className='mb-6'>
              If you are between the ages of 13 and 18, you may only use the App
              with the consent and supervision of a parent or legal guardian. If
              you are a parent or guardian and you are aware that your child has
              provided us with personal information without your consent, please
              contact us so that we can take necessary actions.
            </p>
            <p>
              We encourage parents and legal guardians to monitor their
              children&apos;s Internet usage and to help enforce our Privacy
              Policy by instructing their children never to provide personal
              information through the App without their permission.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>Data Retention</h2>
            <p className='mb-6'>
              We retain your information only as long as necessary to provide
              our services and comply with legal obligations.
            </p>
            <p className='mb-6'>
              Your content stored locally on your device remains there until you
              delete it through the App or your device&apos;s file management
              system. Cloud-synced data is retained until you delete it or close
              your account.
            </p>
            <p>
              If you request deletion of your account or information, we will
              delete it within 30 days, except for information that we are
              required to retain for legal, accounting, or audit purposes.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              International Data Transfers
            </h2>
            <p className='mb-6'>
              {appName} is based in the Philippines, but our App is available
              worldwide. Your data may be transferred to and processed in
              countries other than your own.
            </p>
            <p className='mb-6'>
              Any information we collect may be transferred to and maintained on
              computers located outside of your state, province, country, or
              other governmental jurisdiction where the data protection laws may
              differ from those of your jurisdiction.
            </p>
            <p>
              We will take all steps reasonably necessary to ensure that your
              data is treated securely and in accordance with this Privacy
              Policy.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              Regional Privacy Rights
            </h2>
            <p className='mb-6'>
              Depending on your location, you may have certain rights regarding
              your personal information under applicable data protection laws.
              These may include:
            </p>

            <h3 className='mb-2 text-xl font-medium'>
              European Economic Area (GDPR)
            </h3>
            <p className='mb-6'>
              If you are a resident of the European Economic Area (EEA), you
              have certain data protection rights under the General Data
              Protection Regulation (GDPR). These include the right to:
            </p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>Access and receive a copy of your personal data</li>
              <li>Rectify inaccurate personal data</li>
              <li>Request deletion of your personal data</li>
              <li>Object to processing of your personal data</li>
              <li>Restrict processing of your personal data</li>
              <li>Data portability</li>
              <li>
                Withdraw consent at any time where we relied on your consent to
                process your personal data
              </li>
            </ul>

            <h3 className='mb-2 text-xl font-medium'>
              California Residents (CCPA)
            </h3>
            <p className='mb-6'>
              If you are a California resident, you have rights under the
              California Consumer Privacy Act (CCPA), including:
            </p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>
                The right to know what personal information we collect about you
              </li>
              <li>
                The right to know whether your personal information is sold or
                disclosed and to whom
              </li>
              <li>The right to say no to the sale of personal information</li>
              <li>The right to access your personal information</li>
              <li>
                The right to request deletion of your personal information
              </li>
              <li>
                The right to equal service and price, even if you exercise your
                privacy rights
              </li>
            </ul>
            <p className='mb-6'>
              We do not sell personal information to third parties. We have not
              sold any personal information in the preceding 12 months.
            </p>

            <h3 className='mb-2 text-xl font-medium'>
              Philippines Data Privacy Act
            </h3>
            <p className='mb-6'>
              As a company based in the Philippines, we comply with the Data
              Privacy Act of 2012 (Republic Act No. 10173). Under this law, you
              have the right to:
            </p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>
                Be informed of the collection and processing of your personal
                data
              </li>
              <li>Object to the processing of your personal data</li>
              <li>Access your personal data</li>
              <li>Rectify inaccuracies in your personal data</li>
              <li>Erasure or blocking of your personal data</li>
              <li>Be indemnified for damages</li>
              <li>Data portability</li>
            </ul>
            <p>
              To exercise any of these rights, please contact us using the
              information provided in the &quot;Contact Us&quot; section of this
              Privacy Policy.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              Mobile Device Permissions
            </h2>
            <p className='mb-6'>
              {appName} may request certain permissions to function properly:
            </p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>
                <strong>Notifications:</strong> Optional permission to send you
                reminders and updates.
              </li>
              <li>
                <strong>Camera/Photos:</strong> Optional permission if you want
                to add images to your content.
              </li>
              <li>
                <strong>Biometrics:</strong> Optional permission for secure app
                unlock using Face ID or fingerprint.
              </li>
            </ul>
            <p>
              All permissions are requested only when needed, and you can revoke
              them at any time through your device settings. {appName} will
              continue to function with limited features if you deny optional
              permissions.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              Cookies and Tracking Technologies
            </h2>
            <p className='mb-6'>
              {appName} is a mobile application and does not use traditional web
              cookies. However, we may use technologies similar to cookies, such
              as device identifiers and local storage, for:
            </p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>Storing your app preferences locally on your device</li>
              <li>Remembering your subscription status</li>
              <li>
                Optional analytics to help us improve the App (anonymized data
                only)
              </li>
            </ul>
            <p>
              These technologies help us provide and improve the App&apos;s
              functionality. All data remains on your device or is anonymized
              before transmission. For more detailed information about tracking
              technologies, please refer to our Cookie Policy.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              Updates to This Privacy Policy
            </h2>
            <p className='mb-6'>
              We may update our Privacy Policy from time to time. We will notify
              you of any changes by posting the new Privacy Policy on this page
              and updating the &quot;Last Updated&quot; date at the top of this
              policy.
            </p>
            <p>
              You are advised to review this Privacy Policy periodically for any
              changes. Changes to this Privacy Policy are effective when they
              are posted on this page. Your continued use of the App after any
              changes constitutes acceptance of the updated Privacy Policy.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>Contact Us</h2>
            <p className='mb-6'>
              If you have any questions about this Privacy Policy, please
              contact us:
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
