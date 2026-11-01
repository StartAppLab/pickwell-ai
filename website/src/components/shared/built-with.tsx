export const BuiltWith = () => {
  return (
    <div className='flex items-center justify-center lg:justify-start'>
      <div className='border-primary text-primary hover:bg-primary/10 hover:text-primary w-fit rounded-[4px] border px-2 py-1 text-sm transition-colors'>
        <a
          href='https://startapplab.com/'
          target='_blank'
          rel='noopener noreferrer'>
          Built with <span className='font-semibold'>StartAppLab</span>
        </a>
      </div>
    </div>
  );
};
