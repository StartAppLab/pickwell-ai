import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';

const appName = 'StartAppNotes';

const sectionConfig = {
  sectionId: 'about',
  content: {
    title: 'About Us',
  },
};

export const About = () => {
  return (
    <section className='px-4 py-20 md:px-8 md:py-24'>
      <div className='mx-auto max-w-3xl'>
        <h1 className='mb-8 text-4xl font-semibold tracking-tight'>
          {sectionConfig.content.title}
        </h1>

        <div className='space-y-10'>
          <section>
            <h2 className='mb-4 text-2xl font-semibold'>Our Mission</h2>
            <p className='mb-4'>
              At {appName}, we believe that organizing your thoughts should be
              effortless and delightful. Our mission is to empower individuals
              and teams with simple, beautiful tools that make capturing and
              organizing ideas fast and accessible. Available on iOS and
              Android, your notes go wherever you go.
            </p>
            <p>
              We&apos;re committed to breaking down the barriers between complex
              productivity apps and everyday users, making it easy to capture
              your thoughts and find them later. Your data syncs seamlessly
              across all your devices, with your privacy always protected.
            </p>
          </section>

          <section>
            <h2 className='mb-4 text-2xl font-semibold'>Our Story</h2>
            <p className='mb-4'>
              {appName} started as a simple idea: note-taking should be
              beautiful, fast, and work everywhere. We were frustrated by apps
              that were either too complex or too basic, and we wanted to create
              something that struck the perfect balance between power and
              simplicity.
            </p>
            <p className='mb-4'>
              Inspired by the best productivity tools, we built {appName} to be
              the notes app we always wanted. By combining powerful organization
              features with an intuitive, beautiful interface, we&apos;ve
              developed an app that helps you capture ideas the moment they
              strike and find them whenever you need them.
            </p>
            <p>
              Today, {appName} helps thousands of users organize their thoughts,
              whether they&apos;re capturing quick ideas, writing detailed
              notes, or managing complex projects. Everything syncs seamlessly
              across your devices.
            </p>
          </section>

          <section>
            <h2 className='mb-4 text-2xl font-semibold'>What We Do</h2>
            <p className='mb-4'>
              {appName} is a beautifully designed notes app that allows users
              to:
            </p>
            <ul className='mb-4 list-disc space-y-2 pl-6'>
              <li>Capture ideas quickly with a simple, intuitive interface</li>
              <li>Organize notes with folders, tags, and smart search</li>
              <li>Sync seamlessly across all your devices</li>
              <li>Format notes with rich text and markdown support</li>
              <li>Protect sensitive notes with biometric security</li>
              <li>Access your notes offline, anywhere</li>
              <li>Customize the look with beautiful themes</li>
              <li>Export and share notes in multiple formats</li>
            </ul>
            <p>
              Our cross-platform approach means your notes are always with you.
              Capture on your phone, edit on your tablet, review on your
              desktop. Your data syncs securely and stays private.
            </p>
          </section>

          <section>
            <h2 className='mb-4 text-2xl font-semibold'>Our Values</h2>
            <div className='grid gap-4 sm:grid-cols-2'>
              <Card>
                <CardHeader>
                  <CardTitle>Transparency</CardTitle>
                </CardHeader>
                <CardContent>
                  <p>
                    We believe in complete honesty about our features and how
                    our app works.
                  </p>
                </CardContent>
              </Card>
              <Card>
                <CardHeader>
                  <CardTitle>Accessibility</CardTitle>
                </CardHeader>
                <CardContent>
                  <p>
                    Note-taking should be easy and accessible for everyone,
                    regardless of technical background.
                  </p>
                </CardContent>
              </Card>
              <Card>
                <CardHeader>
                  <CardTitle>Empowerment</CardTitle>
                </CardHeader>
                <CardContent>
                  <p>
                    We aim to give users the tools they need to organize their
                    thoughts and achieve their goals.
                  </p>
                </CardContent>
              </Card>
              <Card>
                <CardHeader>
                  <CardTitle>Privacy</CardTitle>
                </CardHeader>
                <CardContent>
                  <p>
                    Your notes are personal. We protect your data with
                    encryption and never sell your information.
                  </p>
                </CardContent>
              </Card>
            </div>
          </section>

          <section>
            <h2 className='mb-4 text-2xl font-semibold'>Our Team</h2>
            <p className='mb-4'>
              {appName} is built by a small, passionate team dedicated to
              creating the best note-taking experience:
            </p>
            <ul className='mb-4 list-disc space-y-1 pl-6'>
              <li>A dedicated developer building the technical foundation</li>
              <li>
                A multi-talented designer handling UX, support, and operations
              </li>
              <li>
                Our{' '}
                {Math.max(
                  0,
                  Math.floor(
                    (new Date().getTime() - new Date('2024-06-30').getTime()) /
                      (1000 * 60 * 60 * 24 * 30.44)
                  )
                )}{' '}
                month-old daughter who inspires us everyday
              </li>
              <li>Our four furry family members:</li>
              <ul className='ml-6 list-disc space-y-1'>
                <li>Popoy the Chow Chow</li>
                <li>Pocchi the Beagle-Shitzu</li>
                <li>Sofie the Mixed Poodle</li>
                <li>Chloe the Chow Chow</li>
              </ul>
            </ul>
            <p>
              As a team, we work together to make note-taking more accessible
              and beautiful for everyone, driven by our commitment to helping
              users organize their thoughts and ideas.
            </p>
          </section>

          <section>
            <h2 className='mb-4 text-2xl font-semibold'>Join Our Journey</h2>
            <p className='mb-4'>
              We&apos;re just getting started on our mission to transform how
              people capture and organize their ideas. Whether you&apos;re a
              user of our app, a potential partner, or someone interested in
              joining our team, we&apos;d love to connect with you.
            </p>
            <p>
              Have questions or want to learn more?{' '}
              <a
                href='/contact'
                className='text-primary underline'>
                Contact us
              </a>{' '}
              or follow us on social media to stay updated on our latest
              developments.
            </p>
          </section>
        </div>
      </div>
    </section>
  );
};
