import { CtaButton } from '@/components/shared/cta-button';
import { trackButtonClick } from '@/lib/analytics';

const sectionConfig = {
  content: {
    errorCode: '404',
    title: 'Page Not Found',
    description:
      "We couldn't find the page you're looking for. It might have been moved or doesn't exist.",
    buttons: {
      backToHome: 'Back to Home',
      goBack: 'Go Back',
    },
  },
};

export const PageNotFound = () => {
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
              await trackButtonClick('404_back_to_home', undefined, {
                page: '404',
                destination: '/#',
              });
              window.location.href = '/#';
            }}
          />
          <CtaButton
            ctaButtonTitle={sectionConfig.content.buttons.goBack}
            variant='outline'
            onClick={async () => {
              await trackButtonClick('404_go_back', undefined, {
                page: '404',
                action: 'history_back',
              });
              window.history.back();
            }}
          />
        </div>
      </div>
    </div>
  );
};
