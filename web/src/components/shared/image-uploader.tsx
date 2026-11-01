'use client';

import Image from 'next/image';
import { useRef, useState } from 'react';
import { FormMessage } from '@/components/shared/form-message';
import { LoadingSpinner } from '@/components/shared/loading-spinner';
import { Button } from '@/components/ui/button';

interface ImageUploaderProps {
  value?: string | null;
  label?: string;
  description?: string;
  onUpload: (file: File) => Promise<string>;
  onRemove?: () => Promise<void> | void;
}

export function ImageUploader({
  value,
  label,
  description,
  onUpload,
  onRemove,
}: ImageUploaderProps) {
  const fileInputRef = useRef<HTMLInputElement | null>(null);
  const [preview, setPreview] = useState<string | null>(value ?? null);
  const [pending, setPending] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleFileChange = async (
    event: React.ChangeEvent<HTMLInputElement>
  ) => {
    const file = event.target.files?.[0];
    if (!file) return;

    setPending(true);
    setError(null);

    try {
      const url = await onUpload(file);
      setPreview(url);
    } catch (err) {
      setError(
        err instanceof Error ? err.message : 'Upload failed. Please try again.'
      );
    } finally {
      setPending(false);
      event.target.value = '';
    }
  };

  const handleRemove = async () => {
    if (!onRemove) {
      setPreview(null);
      return;
    }

    try {
      setPending(true);
      await onRemove();
      setPreview(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unable to remove image.');
    } finally {
      setPending(false);
    }
  };

  return (
    <div className='space-y-3'>
      {label ? (
        <p className='text-foreground text-sm font-medium'>{label}</p>
      ) : null}
      {description ? (
        <p className='text-muted-foreground text-xs'>{description}</p>
      ) : null}

      <div className='flex flex-col items-start gap-3'>
        {preview ? (
          <div className='border-border relative h-24 w-24 overflow-hidden rounded-md border'>
            <Image
              src={preview}
              alt='Uploaded asset'
              fill
              className='object-cover'
            />
          </div>
        ) : (
          <div className='border-border text-muted-foreground flex h-24 w-24 items-center justify-center rounded-md border border-dashed text-xs'>
            No image
          </div>
        )}

        <div className='flex items-center gap-2'>
          <input
            ref={fileInputRef}
            type='file'
            accept='image/*'
            className='hidden'
            onChange={handleFileChange}
          />
          <Button
            type='button'
            variant='outline'
            size='sm'
            onClick={() => fileInputRef.current?.click()}
            disabled={pending}>
            {pending ? (
              <LoadingSpinner
                size='sm'
                text='Uploading'
              />
            ) : (
              'Upload'
            )}
          </Button>
          {preview ? (
            <Button
              type='button'
              variant='ghost'
              size='sm'
              onClick={handleRemove}
              disabled={pending}>
              Remove
            </Button>
          ) : null}
        </div>
      </div>

      <FormMessage type='error'>{error}</FormMessage>
    </div>
  );
}
