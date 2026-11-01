import { BackButton } from '@/components/shared/back-button';

export function PageHeader({
  title,
  subtitle,
  backHref,
}: {
  title: string;
  subtitle?: string;
  backHref?: string;
}) {
  return (
    <div className='space-y-2 px-4 lg:px-6'>
      {backHref && (
        <BackButton
          href={backHref}
          className='mb-8'
        />
      )}
      <h1 className='text-foreground text-3xl font-bold tracking-tight'>
        {title}
      </h1>
      {subtitle ? <p className='text-muted-foreground'>{subtitle}</p> : null}
    </div>
  );
}
