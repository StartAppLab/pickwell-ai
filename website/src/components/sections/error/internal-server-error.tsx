import { CtaButton } from '@/components/shared/cta-button';
import { trackButtonClick } from '@/lib/analytics';

const sectionConfig = {
  content: {
    errorCode: '500',
    title: 'Internal Server Error',
    description:
      "Sorry, something went wrong on our server. We're working to fix the issue. Please try again later.",
    buttons: {
      backToHome: 'Back to Home',
      refreshPage: 'Refresh Page',
    },
  },
};

export const InternalServerError = () => {
  return (
    <div className='mx-auto flex h-[calc(80vh-4rem)] max-w-screen flex-col items-center justify-center px-8 pt-16'>
      <div className='space-y-8 text-center'>
        <div className='space-y-2'>
          <h1 className='text-primary text-7xl font-semibold tracking-tight'>
            {sectionConfig.content.errorCode}
          </h1>
          <h2 className='text-foreground text-2xl font-medium'>
            {sectionConfig.content.title}
          </h2>
        </div>
        <p className='text-muted-foreground max-w-md text-base'>
          {sectionConfig.content.description}
        </p>
        <div className='flex flex-col items-center justify-center gap-4 sm:flex-row sm:gap-8'>
          <CtaButton
            ctaButtonTitle={sectionConfig.content.buttons.backToHome}
            onClick={async () => {
              await trackButtonClick('500_back_to_home', undefined, {
                page: '500',
                destination: '/#',
              });
              window.location.href = '/#';
            }}
          />
          <CtaButton
            ctaButtonTitle={sectionConfig.content.buttons.refreshPage}
            variant='outline'
            onClick={async () => {
              await trackButtonClick('500_refresh_page', undefined, {
                page: '500',
                action: 'page_reload',
              });
              window.location.reload();
            }}
          />
        </div>
      </div>
    </div>
  );
};
