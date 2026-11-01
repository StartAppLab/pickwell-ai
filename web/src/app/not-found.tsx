import { FileQuestion } from 'lucide-react';
import Link from 'next/link';
import { Button } from '@/components/ui/button';

export default function NotFound() {
  return (
    <div className='flex min-h-svh flex-col items-center justify-center gap-6 px-6 text-center'>
      <div className='bg-muted flex h-20 w-20 items-center justify-center rounded-2xl'>
        <FileQuestion className='text-muted-foreground h-10 w-10' />
      </div>
      <div className='space-y-2'>
        <h1 className='text-foreground text-3xl font-bold tracking-tight'>
          Page not found
        </h1>
        <p className='text-muted-foreground max-w-[400px] whitespace-pre-wrap'>
          Sorry, we couldn&apos;t find the page you&apos;re looking for. It
          might have been moved or deleted.
        </p>
      </div>
      <div className='flex gap-3'>
        <Button
          asChild
          variant='outline'>
          <Link href='/'>Go back home</Link>
        </Button>
        <Button asChild>
          <Link href='/dashboard'>Go to dashboard</Link>
        </Button>
      </div>
    </div>
  );
}
