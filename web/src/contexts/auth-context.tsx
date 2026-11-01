'use client';

import type { Session, User } from '@supabase/supabase-js';
import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react';
import { ensureProfile } from '@/lib/database';
import { env } from '@/lib/env';
import { createSupabaseBrowserClient } from '@/lib/supabase-client';

interface AuthContextValue {
  user: User | null;
  session: Session | null;
  loading: boolean;
  signIn: (email: string, password: string) => Promise<{ error?: string }>;
  signInWithGoogle: () => Promise<{ error?: string }>;
  signUp: (email: string, password: string) => Promise<{ error?: string }>;
  forgotPassword: (email: string) => Promise<{ error?: string }>;
  signOut: () => Promise<void>;
  resetSessionTimer: () => void;
  showSessionWarning: boolean;
  sessionWarningTimeRemaining: number;
  extendSession: () => void;
  dismissSessionWarning: () => void;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

const SESSION_TIMEOUT_MS = 30 * 60 * 1000;
const WARNING_WINDOW_MS = 2 * 60 * 1000;

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const supabase = useMemo(() => createSupabaseBrowserClient(), []);
  const [user, setUser] = useState<User | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [loading, setLoading] = useState(true);
  const [showSessionWarning, setShowSessionWarning] = useState(false);
  const [sessionWarningTimeRemaining, setSessionWarningTimeRemaining] =
    useState(0);

  const sessionTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const warningTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const countdownIntervalRef = useRef<ReturnType<typeof setInterval> | null>(
    null
  );

  const clearTimers = useCallback(() => {
    if (sessionTimeoutRef.current) clearTimeout(sessionTimeoutRef.current);
    if (warningTimeoutRef.current) clearTimeout(warningTimeoutRef.current);
    if (countdownIntervalRef.current)
      clearInterval(countdownIntervalRef.current);
  }, []);

  const signOut = useCallback(async () => {
    try {
      const { error } = await supabase.auth.signOut();
      if (error) {
        console.error('Client sign out error:', error);
      }
    } catch (error) {
      console.error('Client sign out exception:', error);
    } finally {
      clearTimers();
      // Force a page reload to ensure clean state
      window.location.href = '/';
    }
  }, [clearTimers, supabase]);

  const resetSessionTimer = useCallback(() => {
    if (!user) return;

    clearTimers();
    setShowSessionWarning(false);

    warningTimeoutRef.current = setTimeout(() => {
      setShowSessionWarning(true);
      setSessionWarningTimeRemaining(Math.floor(WARNING_WINDOW_MS / 1000));

      countdownIntervalRef.current = setInterval(() => {
        setSessionWarningTimeRemaining((prev) => {
          if (prev <= 1) {
            clearInterval(countdownIntervalRef.current ?? undefined);
            signOut();
            return 0;
          }
          return prev - 1;
        });
      }, 1000);
    }, SESSION_TIMEOUT_MS - WARNING_WINDOW_MS);

    sessionTimeoutRef.current = setTimeout(() => {
      signOut();
    }, SESSION_TIMEOUT_MS);
  }, [user, clearTimers, signOut]);

  const extendSession = useCallback(() => {
    setShowSessionWarning(false);
    resetSessionTimer();
  }, [resetSessionTimer]);

  const dismissSessionWarning = useCallback(() => {
    setShowSessionWarning(false);
    signOut();
  }, [signOut]);

  useEffect(() => {
    if (!user) {
      clearTimers();
      setShowSessionWarning(false);
      setSessionWarningTimeRemaining(0);
      return;
    }

    resetSessionTimer();

    const activityEvents = [
      'mousedown',
      'mousemove',
      'keydown',
      'scroll',
      'touchstart',
    ] as const;
    const onActivity = () => resetSessionTimer();
    activityEvents.forEach((event) =>
      document.addEventListener(event, onActivity, true)
    );

    return () => {
      activityEvents.forEach((event) =>
        document.removeEventListener(event, onActivity, true)
      );
    };
  }, [user, resetSessionTimer, clearTimers]);

  useEffect(() => {
    let mounted = true;

    const getInitialSession = async () => {
      try {
        const { data } = await supabase.auth.getSession();
        if (!mounted) return;
        setSession(data.session);
        setUser(data.session?.user ?? null);
      } catch (error) {
        console.error('Error loading session', error);
      } finally {
        if (mounted) setLoading(false);
      }
    };

    getInitialSession();

    const { data: listener } = supabase.auth.onAuthStateChange(
      async (event, newSession) => {
        setSession(newSession);
        setUser(newSession?.user ?? null);

        if (event === 'SIGNED_IN' && newSession?.user) {
          try {
            await ensureProfile(
              newSession.user.id,
              newSession.user.email ?? ''
            );
          } catch (error) {
            console.error('Failed to ensure profile exists', error);
          }
        }

        if (event === 'SIGNED_OUT') {
          clearTimers();
        }

        setLoading(false);
      }
    );

    return () => {
      mounted = false;
      listener.subscription.unsubscribe();
      clearTimers();
    };
  }, [clearTimers, supabase]);

  const signIn = useCallback(
    async (email: string, password: string) => {
      try {
        const { error } = await supabase.auth.signInWithPassword({
          email,
          password,
        });
        if (error) {
          return { error: error.message };
        }
        return {};
      } catch (error) {
        console.error('Error during sign-in', error);
        return { error: 'Unable to sign in. Please try again.' };
      }
    },
    [supabase]
  );

  const signInWithGoogle = useCallback(async () => {
    try {
      const origin =
        typeof window !== 'undefined'
          ? window.location.origin
          : env.NEXT_PUBLIC_SITE_URL;
      const { data, error } = await supabase.auth.signInWithOAuth({
        provider: 'google',
        ...(origin && {
          options: {
            redirectTo: `${origin}/auth/callback`,
          },
        }),
      });

      if (error) {
        return { error: error.message };
      }

      if (!data.url && origin) {
        window.location.href = `${origin}/auth/callback`;
      }

      return {};
    } catch (error) {
      console.error('Error during Google sign-in', error);
      return { error: 'Unable to sign in with Google right now.' };
    }
  }, [supabase]);

  const signUp = useCallback(
    async (email: string, password: string) => {
      try {
        const { data, error } = await supabase.auth.signUp({
          email,
          password,
          options: {
            emailRedirectTo: `${window.location.origin}/auth/callback`,
          },
        });

        if (error) {
          return { error: error.message };
        }

        if (data.user) {
          await ensureProfile(data.user.id, data.user.email ?? email);
        }

        return {};
      } catch (error) {
        console.error('Error during sign-up', error);
        return { error: 'Unable to sign up. Please try again.' };
      }
    },
    [supabase]
  );

  const forgotPassword = useCallback(
    async (email: string) => {
      try {
        const origin =
          typeof window !== 'undefined'
            ? window.location.origin
            : env.NEXT_PUBLIC_SITE_URL;
        const { error } = await supabase.auth.resetPasswordForEmail(email, {
          ...(origin && { redirectTo: `${origin}/auth/reset-password` }),
        });

        if (error) {
          return { error: error.message };
        }

        return {};
      } catch (error) {
        console.error('Error requesting password reset', error);
        return { error: 'Unable to send reset link. Please try again.' };
      }
    },
    [supabase]
  );

  const value = useMemo<AuthContextValue>(
    () => ({
      user,
      session,
      loading,
      signIn,
      signInWithGoogle,
      signUp,
      forgotPassword,
      signOut,
      resetSessionTimer,
      showSessionWarning,
      sessionWarningTimeRemaining,
      extendSession,
      dismissSessionWarning,
    }),
    [
      user,
      session,
      loading,
      signIn,
      signInWithGoogle,
      signUp,
      forgotPassword,
      signOut,
      resetSessionTimer,
      showSessionWarning,
      sessionWarningTimeRemaining,
      extendSession,
      dismissSessionWarning,
    ]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
