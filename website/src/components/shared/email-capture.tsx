import { useEffect, useState, useRef } from 'react';
import { Button } from '@/components/ui/button';
import { trackButtonClick } from '@/lib/analytics';
import { supabase } from '@/lib/supabase';

const isValidEmail = (email: string): boolean => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

const formatCountdown = (seconds: number): string => {
  const minutes = Math.floor(seconds / 60);
  const remainingSeconds = seconds % 60;
  return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
};

// Constants for rate limiting
const COOLDOWN_DURATION = 60000; // 1 minute in milliseconds
const STORAGE_KEY = 'pickwell-email-timestamp';

interface EmailCaptureProps {
  placeholder?: string;
  buttonText?: string;
  successMessage?: string;
}

const EmailCapture: React.FC<EmailCaptureProps> = ({
  placeholder = 'Enter your email address',
  buttonText = 'Sign up for updates',
  successMessage = 'Thank you for joining the waitlist!',
}) => {
  const [email, setEmail] = useState<string>('');
  const [message, setMessage] = useState<string>('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSuccess, setIsSuccess] = useState(false);
  const [isInCooldown, setIsInCooldown] = useState(false);
  const [countdown, setCountdown] = useState<number>(0);
  const timeoutIdRef = useRef<number | null>(null);
  const intervalIdRef = useRef<number | null>(null);

  // Check localStorage on component mount and handle countdown
  useEffect(() => {
    const lastSubmitTime = localStorage.getItem(STORAGE_KEY);
    if (!lastSubmitTime) return;

    const timeElapsed = Date.now() - parseInt(lastSubmitTime);
    if (timeElapsed >= COOLDOWN_DURATION) return;

    // Use requestAnimationFrame to avoid synchronous cascading renders
    const mountRafId = requestAnimationFrame(() => {
      setIsInCooldown(true);
      const remainingTime = COOLDOWN_DURATION - timeElapsed;
      const remainingSeconds = Math.ceil(remainingTime / 1000);
      setCountdown(remainingSeconds);

      // Start timers inside the callback
      timeoutIdRef.current = window.setTimeout(() => {
        setIsInCooldown(false);
        setIsSuccess(false);
        setCountdown(0);
        setMessage('');
        timeoutIdRef.current = null; // Clear ref after timeout
      }, remainingTime);

      intervalIdRef.current = window.setInterval(() => {
        setCountdown((prev) => {
          if (prev <= 1) {
            if (intervalIdRef.current)
              window.clearInterval(intervalIdRef.current);
            intervalIdRef.current = null; // Clear ref after interval
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
    });

    return () => {
      cancelAnimationFrame(mountRafId);
      if (timeoutIdRef.current) {
        window.clearTimeout(timeoutIdRef.current);
        timeoutIdRef.current = null;
      }
      if (intervalIdRef.current) {
        window.clearInterval(intervalIdRef.current);
        intervalIdRef.current = null;
      }
    };
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    await trackButtonClick('join_beta');

    e.preventDefault();
    setMessage('');

    if (!email || !isValidEmail(email)) {
      setMessage('Please enter a valid email address');
      return;
    }

    if (isSubmitting || isInCooldown) {
      setMessage('Please wait before submitting again.');
      return;
    }

    setIsSubmitting(true);
    localStorage.setItem(STORAGE_KEY, Date.now().toString());

    try {
      // Get the current domain as the source
      const source = window.location.hostname;

      // Check if email and source combination already exists
      const { data: existingRecord, error: checkError } = await supabase
        .from('emails')
        .select('email, source')
        .eq('email', email)
        .eq('source', source)
        .maybeSingle();

      if (checkError) {
        window.console.error('Error checking for existing email:', checkError);
        setMessage('An unexpected error occurred. Please try again.');
        setIsSubmitting(false);
        localStorage.removeItem(STORAGE_KEY);
        return;
      }

      // If record exists with same email and source, it's a duplicate
      if (existingRecord) {
        setMessage('This email has already been registered from this source.');
        setIsSubmitting(false);
        localStorage.removeItem(STORAGE_KEY);
        return;
      }

      // Insert new record
      const { error } = await supabase.from('emails').insert([
        {
          email,
          source,
        },
      ]);

      if (error) {
        setMessage('Error: Email already exists or invalid.');
        setIsSubmitting(false);
        localStorage.removeItem(STORAGE_KEY);
      } else {
        setIsSuccess(true);
        setMessage(successMessage);
        setEmail('');
        setIsSubmitting(false);
        setIsInCooldown(true);

        // Start countdown timer
        const remainingSeconds = Math.ceil(COOLDOWN_DURATION / 1000);
        setCountdown(remainingSeconds);

        // Set timeout for cooldown
        window.setTimeout(() => {
          setIsInCooldown(false);
          setIsSuccess(false);
          setCountdown(0);
          setMessage('');
        }, COOLDOWN_DURATION);

        // Start countdown interval
        const intervalId = window.setInterval(() => {
          setCountdown((prev) => {
            if (prev <= 1) {
              window.clearInterval(intervalId);
              return 0;
            }
            return prev - 1;
          });
        }, 1000);
      }
    } catch (error) {
      window.console.error('Error submitting email:', error);
      setMessage('An unexpected error occurred. Please try again.');
      setIsSubmitting(false);
      localStorage.removeItem(STORAGE_KEY);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <div className='mb-3'>
        <input
          className={`input-field h-12 w-full ${message && !isSuccess ? 'border-destructive' : ''}`}
          type='email'
          value={email}
          placeholder={placeholder}
          aria-label='Email input'
          disabled={isSubmitting || isInCooldown}
          onChange={(e) => setEmail(e.target.value)}
        />
        {message && (
          <p
            className={`mt-1 text-center text-sm ${isSuccess ? 'text-green-500' : 'text-destructive'}`}>
            {message}
          </p>
        )}
      </div>
      <Button
        className='contained-button h-12 w-full'
        aria-label='Submit button'
        disabled={isSubmitting || isInCooldown}
        onClick={handleSubmit}>
        {isSubmitting
          ? 'Submitting...'
          : isInCooldown
            ? `Submitted! (${formatCountdown(countdown)})`
            : buttonText}
      </Button>
    </form>
  );
};

export default EmailCapture;
