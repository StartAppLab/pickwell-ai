'use client';

import {
  createContext,
  useContext,
  useMemo,
  useState,
  useTransition,
} from 'react';
import { loadOrgContext, setDefaultOrg } from '@/features/orgs/server/actions';
import type {
  OrgContextValue,
  OrganizationSummary,
} from '@/features/orgs/types';

interface OrgProviderProps {
  children: React.ReactNode;
  initialOrganizations: OrganizationSummary[];
  initialActiveOrgId: string | null;
  initialDefaultOrgId: string | null;
}

interface OrgContextInternalState {
  organizations: OrganizationSummary[];
  activeOrgId: string | null;
  defaultOrgId: string | null;
}

const OrgContext = createContext<OrgContextValue | undefined>(undefined);

export function OrgProvider({
  children,
  initialOrganizations,
  initialActiveOrgId,
  initialDefaultOrgId,
}: OrgProviderProps) {
  // Create a stable key from initial props to detect when they change
  const initialKey = useMemo(
    () =>
      JSON.stringify({
        orgs: initialOrganizations.map((o) => o.id),
        activeId: initialActiveOrgId,
        defaultId: initialDefaultOrgId,
      }),
    [initialOrganizations, initialActiveOrgId, initialDefaultOrgId]
  );

  const [stateKey, setStateKey] = useState(initialKey);
  const [state, setState] = useState<OrgContextInternalState>({
    organizations: initialOrganizations,
    activeOrgId: initialActiveOrgId,
    defaultOrgId: initialDefaultOrgId,
  });

  // Sync state when initial props change (detected via key comparison)
  if (initialKey !== stateKey) {
    setStateKey(initialKey);
    setState({
      organizations: initialOrganizations,
      activeOrgId: initialActiveOrgId,
      defaultOrgId: initialDefaultOrgId,
    });
  }

  const commit = (next: {
    organizations: OrganizationSummary[];
    activeOrgId: string | null;
    defaultOrgId: string | null;
  }) => {
    setState({
      organizations: next.organizations,
      activeOrgId: next.activeOrgId,
      defaultOrgId: next.defaultOrgId,
    });
  };

  const [, startTransition] = useTransition();

  const setActiveOrg: OrgContextValue['setActiveOrg'] = async (orgId) => {
    startTransition(async () => {
      const next = await setDefaultOrg({ orgId });
      commit(next);
    });
  };

  const refresh: OrgContextValue['refresh'] = async () => {
    startTransition(async () => {
      const next = await loadOrgContext();
      commit(next);
    });
  };

  const value: OrgContextValue = {
    organizations: state.organizations,
    activeOrgId: state.activeOrgId,
    defaultOrgId: state.defaultOrgId,
    setActiveOrg,
    refresh,
  };

  return <OrgContext.Provider value={value}>{children}</OrgContext.Provider>;
}

export function useOrgContext(): OrgContextValue {
  const context = useContext(OrgContext);
  if (!context) {
    throw new Error('useOrgContext must be used within OrgProvider');
  }
  return context;
}
