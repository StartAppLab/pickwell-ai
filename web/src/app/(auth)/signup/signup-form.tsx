'use client';

import { useActionState } from 'react';
import { useFormStatus } from 'react-dom';
import { type SignupState, signupAction } from './actions';
import { FormMessage } from '@/components/shared/form-message';
import { LoadingSpinner } from '@/components/shared/loading-spinner';
import { PasswordInput } from '@/components/shared/password-input';
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

const INITIAL_STATE: SignupState = {};

export function SignupForm({
  className,
  ...props
}: React.ComponentProps<'div'>) {
  const [state, formAction] = useActionState(signupAction, INITIAL_STATE);

  return (
    <div
      className={cn('flex flex-col gap-6', className)}
      {...props}>
      <Card>
        <CardHeader className='text-center'>
          <CardTitle className='text-xl'>Create your account</CardTitle>
          <CardDescription>
            Enter your details below to create your account
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form action={formAction}>
            <FieldGroup>
              <Field>
                <FieldLabel htmlFor='name'>Full Name</FieldLabel>
                <Input
                  id='name'
                  name='name'
                  type='text'
                  placeholder='John Doe'
                  required
                  autoComplete='name'
                />
              </Field>

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

              <Field>
                <FieldLabel htmlFor='password'>Password</FieldLabel>
                <PasswordInput
                  id='password'
                  name='password'
                  required
                  minLength={8}
                  autoComplete='new-password'
                />
                <FieldDescription>
                  Must be at least 8 characters long.
                </FieldDescription>
              </Field>

              <Field>
                <FieldLabel htmlFor='confirmPassword'>
                  Confirm Password
                </FieldLabel>
                <PasswordInput
                  id='confirmPassword'
                  name='confirmPassword'
                  required
                  minLength={8}
                  autoComplete='new-password'
                />
              </Field>

              <FormMessage type='error'>{state.error}</FormMessage>
              <FormMessage type='success'>{state.success}</FormMessage>

              <Field>
                <SubmitButton />
              </Field>

              <FieldDescription className='text-center'>
                Already have an account? <a href='/login'>Login</a>
              </FieldDescription>
            </FieldGroup>
          </form>
        </CardContent>
      </Card>
      <FieldDescription className='px-6 text-center'>
        By creating an account, you agree to our{' '}
        <a
          href='https://startapplab.com/terms'
          target='_blank'
          rel='noopener noreferrer'>
          Terms of Service
        </a>{' '}
        and{' '}
        <a
          href='https://startapplab.com/privacy'
          target='_blank'
          rel='noopener noreferrer'>
          Privacy Policy
        </a>
        .
      </FieldDescription>
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
          text='Creating account...'
        />
      ) : (
        'Create Account'
      )}
    </Button>
  );
}
