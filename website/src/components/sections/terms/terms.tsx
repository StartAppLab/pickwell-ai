const appName = 'StartAppNotes';

const sectionConfig = {
  sectionId: 'terms',
  content: {
    title: 'Terms of Use',
    lastUpdated: 'January 28, 2026',
  },
  contact: {
    email: 'hello@startapplab.com',
    website: 'https://startapplab.com/contact',
  },
};

export const Terms = () => {
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
            <h2 className='mb-6 text-2xl font-semibold'>Acceptance of Terms</h2>
            <p className='mb-6'>
              Welcome to {appName}. These Terms of Use (&quot;Terms&quot;)
              govern your use of our mobile application (the &quot;App&quot;)
              operated by {appName} (&quot;we,&quot; &quot;us,&quot; or
              &quot;our&quot;).
            </p>
            <p className='mb-6'>
              By downloading, installing, or using the App, you agree to be
              bound by these Terms. If you do not agree to these Terms, do not
              use the App.
            </p>
            <p className='mb-6'>
              {appName} is based in the Philippines but the App is available for
              download and use in multiple regions including Southeast Asia,
              Asia, the United States, Europe, and other territories. By using
              the App, you agree to comply with all applicable local laws in
              your jurisdiction.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              Description of Service
            </h2>
            <p className='mb-6'>
              {appName} is a mobile application that provides various features
              and services as described in the App and on our website. The App
              may include both free features and premium features available
              through subscription.
            </p>
            <p className='mb-6'>
              The App requires iOS 14.0 or later (iOS) or Android 7.0 (API 24+)
              or later (Android). Certain features may require appropriate
              permissions which the App will guide you through during setup.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              User Responsibilities
            </h2>
            <p className='mb-6'>You are responsible for:</p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>Complying with all applicable laws and regulations</li>
              <li>Respecting the privacy and rights of others</li>
              <li>Using the App only for lawful purposes</li>
              <li>
                Maintaining the confidentiality of your account credentials if
                applicable
              </li>
              <li>
                Ensuring you have the right to use and share any content you
                create
              </li>
            </ul>
            <p>
              You acknowledge that you are solely responsible for the content
              you create and share using the App. {appName} does not monitor,
              review, or control the content created using the App.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>Prohibited Uses</h2>
            <p className='mb-6'>You agree not to use the App:</p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>
                In any way that violates any applicable federal, state, local,
                or international law or regulation
              </li>
              <li>To create, distribute, or share illegal content</li>
              <li>
                To violate any intellectual property rights, including
                copyrights, trademarks, or trade secrets
              </li>
              <li>To harass, abuse, harm, or impersonate others</li>
              <li>
                To circumvent any security measures or attempt to gain
                unauthorized access to the App
              </li>
              <li>
                To transmit, or procure the sending of, any advertising or
                promotional material, including any &quot;junk mail,&quot;
                &quot;chain letter,&quot; &quot;spam,&quot; or any other similar
                solicitation
              </li>
              <li>
                To engage in any other conduct that restricts or inhibits
                anyone&apos;s use or enjoyment of the App, or which may harm
                {appName} or users of the App, or expose them to liability
              </li>
            </ul>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              Data Storage and Privacy
            </h2>
            <p className='mb-6'>
              {appName} is designed with privacy in mind. Please refer to our
              Privacy Policy for detailed information about how we collect, use,
              and protect your data.
            </p>
            <p className='mb-6'>
              Your data may be stored locally on your device and/or in the cloud
              depending on your settings and the features you use:
            </p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>
                Local storage: Data stored on your device is your responsibility
                to back up
              </li>
              <li>
                Cloud storage: If you use cloud sync features, your data will be
                stored securely on our servers
              </li>
            </ul>
            <p>
              By using the App, you acknowledge that you are responsible for
              backing up your data. {appName} is not responsible for any loss of
              data. For more information about how we handle your data, please
              refer to our Privacy Policy.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>User Content</h2>
            <p className='mb-6'>
              The App allows you to create and manage content (&quot;User
              Content&quot;). You retain all rights to your User Content.
              {appName} does not claim ownership of your User Content.
            </p>
            <p className='mb-6'>You represent and warrant that:</p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>
                You own the User Content or have the right to use and share it
              </li>
              <li>
                The creation and sharing of your User Content does not violate
                the privacy rights, publicity rights, copyrights, contract
                rights, intellectual property rights, or any other rights of any
                person
              </li>
            </ul>
            <p>
              You are solely responsible for your User Content and any
              consequences of sharing it. {appName} is not responsible for any
              User Content created or shared using the App.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              Subscriptions and Payments
            </h2>
            <p className='mb-6'>
              {appName} offers a free version with basic features and a Pro
              subscription that unlocks additional features.
            </p>
            <p className='mb-6'>Subscriptions are managed through:</p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>iOS: Apple&apos;s App Store</li>
              <li>Android: Google Play Store</li>
            </ul>
            <p className='mb-6'>
              Subscriptions automatically renew unless cancelled at least 24
              hours before the end of the current period. You can manage your
              subscription and cancel at any time through your device&apos;s App
              Store or Google Play Store settings.
            </p>
            <p>
              All payments are processed by Apple or Google. {appName} does not
              store or process payment information. Refunds are subject to
              Apple&apos;s or Google&apos;s refund policies.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>Age Restrictions</h2>
            <p className='mb-6'>
              The App is intended for use by individuals who are at least 13
              years of age. By using the App, you represent and warrant that you
              are at least 13 years old.
            </p>
            <p>
              If you are between the ages of 13 and 18, you may only use the App
              with the consent and supervision of a parent or legal guardian who
              agrees to be bound by these Terms. Children under the age of 13
              are not permitted to use the App under any circumstances.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              Intellectual Property
            </h2>
            <p className='mb-6'>
              The App and its original content (excluding User Content),
              features, and functionality are and will remain the exclusive
              property of {appName} and its licensors. The App is protected by
              copyright, trademark, and other laws of the Republic of the
              Philippines, the United States, and other foreign countries. Our
              trademarks and trade dress may not be used in connection with any
              product or service without the prior written consent of
              {appName}.
            </p>
            <p>
              You may not copy, modify, distribute, sell, or lease any part of
              the App or its content, nor may you reverse engineer or attempt to
              extract the source code of the App, unless laws prohibit those
              restrictions or you have our written permission.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>Privacy</h2>
            <p>
              Your use of the App is also governed by our Privacy Policy, which
              is incorporated into these Terms by reference. Please review our
              Privacy Policy to understand how we handle your information.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              Disclaimer of Warranties
            </h2>
            <p className='mb-6'>
              The App is provided on an &quot;AS IS&quot; and &quot;AS
              AVAILABLE&quot; basis. {appName} expressly disclaims all
              warranties of any kind, whether express or implied, including but
              not limited to the implied warranties of merchantability, fitness
              for a particular purpose, and non-infringement.
            </p>
            <p className='mb-6'>{appName} makes no warranty that:</p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>The App will meet your requirements</li>
              <li>
                The App will be uninterrupted, timely, secure, or error-free
              </li>
              <li>
                The results that may be obtained from the use of the App will be
                accurate or reliable
              </li>
              <li>
                The quality of any services, information, or other material
                obtained by you through the App will meet your expectations
              </li>
            </ul>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              Limitation of Liability
            </h2>
            <p className='mb-6'>
              In no event shall {appName}, its directors, employees, partners,
              agents, suppliers, or affiliates be liable for any indirect,
              incidental, special, consequential, or punitive damages, including
              without limitation, loss of profits, data, use, goodwill, or other
              intangible losses, resulting from:
            </p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>
                Your access to or use of or inability to access or use the App
              </li>
              <li>Any content created or shared using the App</li>
              <li>Unauthorized access, use, or alteration of your data</li>
              <li>Loss of data due to device failure or deletion</li>
            </ul>
            <p>
              Whether based on warranty, contract, tort (including negligence),
              or any other legal theory, whether or not we have been informed of
              the possibility of such damage, and even if a remedy set forth
              herein is found to have failed of its essential purpose.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>Indemnification</h2>
            <p>
              You agree to defend, indemnify, and hold harmless {appName}, its
              parent, subsidiaries, affiliates, and their respective directors,
              officers, employees, contractors, agents, suppliers, licensors,
              successors, and assigns from and against any claims, liabilities,
              damages, judgments, awards, losses, costs, expenses, or fees
              (including reasonable attorneys&apos; fees) arising out of or
              relating to your violation of these Terms or your use of the App,
              including, but not limited to, your User Content, any use of the
              App&apos;s content, services, and products other than as expressly
              authorized in these Terms.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>Termination</h2>
            <p className='mb-6'>
              We may terminate or suspend your access to the App immediately,
              without prior notice or liability, under our sole discretion, for
              any reason whatsoever and without limitation, including but not
              limited to a breach of the Terms.
            </p>
            <p>
              If you wish to stop using the App, you may simply discontinue
              using it or uninstall it from your device. All provisions of the
              Terms which by their nature should survive termination shall
              survive termination, including, without limitation, ownership
              provisions, warranty disclaimers, indemnity, and limitations of
              liability.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>Governing Law</h2>
            <p>
              These Terms shall be governed by and construed in accordance with
              the laws of the Republic of the Philippines, specifically as
              applied in Davao City, Davao del Sur, without regard to its
              conflict of law provisions. Any legal action or proceeding arising
              under these Terms shall be brought exclusively in the courts
              located in Davao City, Philippines, and you hereby consent to the
              personal jurisdiction and venue therein.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              Dispute Resolution and Arbitration
            </h2>
            <p className='mb-6'>
              Any dispute, controversy, or claim arising out of or relating to
              these Terms, including the validity, invalidity, breach, or
              termination thereof, shall be resolved by arbitration in
              accordance with the Philippine Dispute Resolution Center, Inc.
              (PDRCI) Arbitration Rules in force on the date when the Notice of
              Arbitration is submitted.
            </p>
            <p className='mb-6'>
              The seat of arbitration shall be Davao City, Philippines. The
              arbitral proceedings shall be conducted in English. The
              arbitration shall be conducted by one arbitrator appointed in
              accordance with the PDRCI Rules.
            </p>
            <p className='mb-6'>
              BY AGREEING TO THESE TERMS, YOU ACKNOWLEDGE THAT YOU ARE WAIVING
              THE RIGHT TO A TRIAL BY JURY OR TO PARTICIPATE IN A CLASS ACTION
              LAWSUIT.
            </p>
            <p>
              Notwithstanding the foregoing, {appName} may seek injunctive or
              other equitable relief to protect its intellectual property rights
              in any court of competent jurisdiction.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>Severability</h2>
            <p className='mb-6'>
              If any provision of these Terms is held to be invalid, illegal, or
              unenforceable by a court of competent jurisdiction, such provision
              shall be modified to the minimum extent necessary to make it
              valid, legal, and enforceable while preserving its intent. If no
              such modification is possible, the provision will be severed from
              these Terms without affecting the validity and enforceability of
              the remaining provisions.
            </p>
            <p>
              In the event that any provision is determined to be invalid or
              unenforceable, the parties agree to replace such provision with a
              valid provision that most closely approximates the intent and
              economic effect of the invalid provision, and the remaining
              provisions shall continue in effect.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>
              Updates to These Terms
            </h2>
            <p className='mb-6'>
              We reserve the right, at our sole discretion, to modify or replace
              these Terms at any time. If a revision is material, we will
              provide at least 30 days&apos; notice prior to any new terms
              taking effect. What constitutes a material change will be
              determined at our sole discretion.
            </p>
            <p>
              By continuing to access or use our App after any revisions become
              effective, you agree to be bound by the revised terms. If you do
              not agree to the new terms, you are no longer authorized to use
              the App.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>Entire Agreement</h2>
            <p>
              These Terms, together with our Privacy Policy and Cookie Policy,
              constitute the entire agreement between you and {appName}
              regarding your use of the App and supersede all prior and
              contemporaneous written or oral agreements, understandings,
              communications, and proposals between you and {appName}. Any
              rights not expressly granted herein are reserved by {appName}.
              These Terms may only be modified as set forth in the &quot;Updates
              to These Terms&quot; section.
            </p>
          </section>

          <section>
            <h2 className='mb-6 text-2xl font-semibold'>Contact Us</h2>
            <p className='mb-6'>
              If you have any questions about these Terms, please contact us:
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
