export function LoginShowcase() {
  return (
    <div className='bg-background relative flex h-full min-h-screen w-full'>
      <div className='text-foreground relative z-10 flex h-full flex-col justify-center p-16'>
        <div className='mb-12'>
          <div className='bg-accent text-accent-foreground border-border inline-flex items-center gap-2 rounded-full border px-4 py-2 text-xs font-medium tracking-wider uppercase shadow-sm'>
            Built with StartAppLab
          </div>
        </div>

        <div className='max-w-2xl'>
          <h1 className='text-foreground mb-6 text-5xl leading-tight font-bold tracking-tight'>
            Launch Your Mobile App in
            <span className='text-primary'> 5 minutes</span>
          </h1>
          <p className='text-muted-foreground mb-12 text-xl leading-relaxed'>
            Publish mobile apps with a complete landing page, dashboard,
            backend, and database — all with one command.
          </p>

          {/* Key Features */}
          <div className='space-y-4'>
            <div className='flex items-center gap-3'>
              <div className='bg-primary/10 border-primary/20 flex h-8 w-8 shrink-0 items-center justify-center rounded-lg border'>
                <div className='bg-primary h-4 w-4 rounded'></div>
              </div>
              <span className='text-foreground text-lg'>
                Landing Page + Dashboard + Backend
              </span>
            </div>
            <div className='flex items-center gap-3'>
              <div className='bg-primary/10 border-primary/20 flex h-8 w-8 shrink-0 items-center justify-center rounded-lg border'>
                <div className='bg-primary h-4 w-4 rounded'></div>
              </div>
              <span className='text-foreground text-lg'>
                Auth, Billing, & User Management
              </span>
            </div>
            <div className='flex items-center gap-3'>
              <div className='bg-primary/10 border-primary/20 flex h-8 w-8 shrink-0 items-center justify-center rounded-lg border'>
                <div className='bg-primary h-4 w-4 rounded'></div>
              </div>
              <span className='text-foreground text-lg'>
                Production-Ready & Scalable
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
