'use client';

import { useActionState } from 'react';
import { useFormStatus } from 'react-dom';
import { type ForgotPasswordState, requestResetAction } from './actions';
import { FormMessage } from '@/components/shared/form-message';
import { LoadingSpinner } from '@/components/shared/loading-spinner';
import { Button } from '@/components/ui/button';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import {
  Field,
  FieldDescription,
  FieldGroup,
  FieldLabel,
} from '@/components/ui/field';
import { Input } from '@/components/ui/input';
import { cn } from '@/lib/utils';

const INITIAL_STATE: ForgotPasswordState = {};

export function ForgotPasswordForm({
  className,
  ...props
}: React.ComponentProps<'div'>) {
  const [state, formAction] = useActionState(requestResetAction, INITIAL_STATE);

  return (
    <div
      className={cn('flex flex-col gap-6', className)}
      {...props}>
      <Card>
        <CardHeader className='text-center'>
          <CardTitle className='text-xl'>Reset your password</CardTitle>
          <CardDescription>
            Enter your email address and we&apos;ll send you a link to reset
            your password
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form action={formAction}>
            <FieldGroup>
              <Field>
                <FieldLabel htmlFor='email'>Email</FieldLabel>
                <Input
                  id='email'
                  name='email'
                  type='email'
                  placeholder='john@example.com'
                  required
                  autoComplete='email'
                />
              </Field>

              <FormMessage type='error'>{state.error}</FormMessage>
              <FormMessage type='success'>{state.success}</FormMessage>

              <Field>
                <SubmitButton />
              </Field>

              <FieldDescription className='text-center'>
                Remember your password? <a href='/login'>Login</a>
              </FieldDescription>
            </FieldGroup>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}

function SubmitButton() {
  const { pending } = useFormStatus();

  return (
    <Button
      type='submit'
      disabled={pending}>
      {pending ? (
        <LoadingSpinner
          size='sm'
          text='Sending reset link...'
        />
      ) : (
        'Send Reset Link'
      )}
    </Button>
  );
}
