export function GreetingCard({ firstName }: { firstName: string }) {
  return (
    <div className='px-4 lg:px-6'>
      <div className='mb-6'>
        <h1 className='text-3xl font-bold tracking-tight'>
          Welcome back, {firstName || 'User'}!
        </h1>
        <p className='text-muted-foreground'>
          Here&apos;s what&apos;s happening with your dashboard today.
        </p>
      </div>
    </div>
  );
}
