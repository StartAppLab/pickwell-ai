'use client';

import { useActionState } from 'react';
import { useFormStatus } from 'react-dom';
import {
  type LoginState,
  appleSignInAction,
  githubSignInAction,
  googleSignInAction,
  loginAction,
} from './actions';
import { FormMessage } from '@/components/shared/form-message';
import { LoadingSpinner } from '@/components/shared/loading-spinner';
import { PasswordInput } from '@/components/shared/password-input';
import { SSOButton } from '@/components/shared/sso-button';
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
  FieldSeparator,
} from '@/components/ui/field';
import { Input } from '@/components/ui/input';
import { cn } from '@/lib/utils';

const INITIAL_STATE: LoginState = {};

export function LoginForm({
  className,
  initialError,
  ...props
}: {
  className?: string;
  initialError?: string | null;
} & React.ComponentProps<'div'>) {
  const [state, formAction] = useActionState(loginAction, INITIAL_STATE);

  return (
    <div
      className={cn('flex flex-col gap-6', className)}
      {...props}>
      <Card>
        <CardHeader className='text-center'>
          <CardTitle className='text-xl'>Sign in to your account</CardTitle>
          <CardDescription>
            Enter your email below to sign in to your account
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
                  placeholder='hello@startapplab.com'
                  required
                  autoComplete='email'
                />
              </Field>

              <Field>
                <div className='flex items-center'>
                  <FieldLabel htmlFor='password'>Password</FieldLabel>
                  <a
                    href='/forgot-password'
                    className='hover:text-primary ml-auto text-sm underline-offset-4 hover:underline'>
                    Forgot your password?
                  </a>
                </div>
                <PasswordInput
                  id='password'
                  name='password'
                  required
                  minLength={6}
                  autoComplete='current-password'
                />
              </Field>

              <FormMessage type='error'>
                {state.error || initialError}
              </FormMessage>
              <FormMessage type='success'>{state.success}</FormMessage>

              <Field>
                <SubmitButton />
              </Field>

              <FieldSeparator className='*:data-[slot=field-separator-content]:bg-card'>
                Or continue with
              </FieldSeparator>

              <Field className='grid gap-3'>
                <SSOButton
                  provider='google'
                  action={googleSignInAction}
                />
                <SSOButton
                  provider='apple'
                  action={appleSignInAction}
                />
                <SSOButton
                  provider='github'
                  action={githubSignInAction}
                />
              </Field>

              <FieldDescription className='text-center'>
                Don&apos;t have an account? <a href='/signup'>Sign up</a>
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
          text='Signing in...'
        />
      ) : (
        'Sign in'
      )}
    </Button>
  );
}
