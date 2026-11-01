import type { Database } from '@/types/database';

export type OrganizationRow =
  Database['public']['Tables']['organizations']['Row'];
export type MembershipRow =
  Database['public']['Tables']['organization_members']['Row'];

export type OrgRole = MembershipRow['role'];

export interface OrganizationSummary extends OrganizationRow {
  membershipRole: OrgRole | null;
}

export interface OrgMemberSummary {
  userId: string;
  email: string | null;
  role: OrgRole;
  joinedAt: string;
}

export interface OrgContextValue {
  organizations: OrganizationSummary[];
  activeOrgId: string | null;
  defaultOrgId: string | null;
  setActiveOrg: (orgId: string) => Promise<void>;
  refresh: () => Promise<void>;
}
