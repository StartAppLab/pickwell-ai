'use client';

import { useActionState } from 'react';
import { type ProfileState, updateProfileAction } from './actions';
import { FormMessage } from '@/components/shared/form-message';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

interface ProfileFormProps {
  initialValues: {
    first_name: string | null;
    last_name: string | null;
    phone: string | null;
    role: string | null;
  };
}

const INITIAL_STATE: ProfileState = {};

export function ProfileForm({ initialValues }: ProfileFormProps) {
  const [state, formAction] = useActionState(
    updateProfileAction,
    INITIAL_STATE
  );

  return (
    <form
      action={formAction}
      className='space-y-6'>
      <fieldset className='grid gap-4 md:grid-cols-2'>
        <div className='space-y-2'>
          <Label htmlFor='first_name'>First name</Label>
          <Input
            id='first_name'
            name='first_name'
            defaultValue={initialValues.first_name ?? ''}
            placeholder='Jamie'
          />
        </div>
        <div className='space-y-2'>
          <Label htmlFor='last_name'>Last name</Label>
          <Input
            id='last_name'
            name='last_name'
            defaultValue={initialValues.last_name ?? ''}
            placeholder='Doe'
          />
        </div>
      </fieldset>
      <fieldset className='grid gap-4 md:grid-cols-2'>
        <div className='space-y-2'>
          <Label htmlFor='phone'>Phone</Label>
          <Input
            id='phone'
            name='phone'
            defaultValue={initialValues.phone ?? ''}
            placeholder='(555) 123-4567'
          />
        </div>
        <div className='space-y-2'>
          <Label htmlFor='role'>Role</Label>
          <Input
            id='role'
            name='role'
            defaultValue={initialValues.role ?? ''}
            placeholder='Founder'
          />
        </div>
      </fieldset>
      <FormMessage type='error'>{state.error}</FormMessage>
      <FormMessage type='success'>{state.success}</FormMessage>
      <Button
        type='submit'
        variant='default'>
        Save changes
      </Button>
    </form>
  );
}
