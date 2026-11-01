export default function Loading() {
  return (
    <div className='bg-background fixed inset-0 z-50 flex items-center justify-center transition-opacity duration-300'>
      <div className='flex flex-col items-center gap-4'>
        {/* Modern premium loader using CSS animations */}
        <div className='relative flex h-12 w-12 items-center justify-center'>
          <div className='border-primary/20 absolute h-full w-full rounded-full border-4'></div>
          <div className='border-primary absolute h-full w-full animate-spin rounded-full border-4 border-t-transparent'></div>
        </div>
        <p className='text-muted-foreground animate-pulse text-sm font-medium'>
          Loading StartAppLab...
        </p>
      </div>
    </div>
  );
}
