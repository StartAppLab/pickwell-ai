'use server';

import type { PostgrestError } from '@supabase/supabase-js';
import { revalidatePath } from 'next/cache';
import { z } from 'zod';
import type {
  OrgMemberSummary,
  OrgRole,
  OrganizationSummary,
} from '@/features/orgs/types';
import { requireAuthState } from '@/lib/auth';
import {
  fetchMemberships,
  fetchOrganizationsForUser,
  insertAuditLog,
} from '@/lib/db';
import { createSupabaseServerClient } from '@/lib/supabase-server';
import { slugify } from '@/lib/utils';
import { emailSchema, uuidSchema, validateInput } from '@/lib/validation';
import type { Database } from '@/types/database';

interface OrgContextPayload {
  organizations: OrganizationSummary[];
  activeOrgId: string | null;
  defaultOrgId: string | null;
}

const createOrgSchema = z.object({
  name: z.string().min(2).max(120),
  slug: z.string().optional(),
});

const inviteMemberSchema = z.object({
  orgId: uuidSchema,
  email: emailSchema,
  role: z.enum(['owner', 'admin', 'member']).default('member'),
});

const removeMemberSchema = z.object({
  orgId: uuidSchema,
  userId: uuidSchema,
});

const setDefaultOrgSchema = z.object({
  orgId: uuidSchema,
});

export async function loadOrgContext(): Promise<OrgContextPayload> {
  const { user, profile } = await requireAuthState('/login');
  const supabase = await createSupabaseServerClient();

  const [organizations, memberships] = await Promise.all([
    fetchOrganizationsForUser(supabase, user.id),
    fetchMemberships(supabase, user.id),
  ]);

  const membershipRole = new Map<string, OrgRole>();
  for (const membership of memberships) {
    membershipRole.set(membership.org_id, membership.role);
  }

  for (const org of organizations) {
    if (org.owner_id === user.id) {
      membershipRole.set(org.id, 'owner');
    }
  }

  const summaries: OrganizationSummary[] = organizations.map((org) => ({
    ...org,
    membershipRole: membershipRole.get(org.id) ?? null,
  }));

  const defaultOrgId = profile?.default_org_id ?? null;
  const candidate =
    summaries.find((org) => org.id === defaultOrgId) ?? summaries[0];

  return {
    organizations: summaries,
    activeOrgId: candidate?.id ?? null,
    defaultOrgId,
  };
}

export async function createOrg(input: unknown): Promise<OrgContextPayload> {
  const payload = await validateInput(createOrgSchema, input);
  const { user, profile } = await requireAuthState('/login');
  const supabase = await createSupabaseServerClient();

  const slug = payload.slug ? slugify(payload.slug) : slugify(payload.name);

  const { data: organization, error } = await supabase
    .from('organizations')
    .insert({
      name: payload.name,
      slug,
      owner_id: user.id,
    })
    .select('*')
    .single();

  if (error || !organization) {
    throw new Error(
      `Unable to create organization: ${error?.message ?? 'Unknown error'}`
    );
  }

  const { error: membershipError } = await supabase
    .from('organization_members')
    .upsert({
      org_id: organization.id,
      user_id: user.id,
      role: 'owner',
    });

  if (membershipError) {
    throw new Error(`Unable to assign ownership: ${membershipError.message}`);
  }

  if (!profile?.default_org_id) {
    const { error: profileUpdateError } = await supabase
      .from('profiles')
      .update({
        default_org_id: organization.id,
        updated_at: new Date().toISOString(),
      })
      .eq('id', user.id);

    if (profileUpdateError) {
      throw new Error(
        `Unable to set default organization: ${profileUpdateError.message}`
      );
    }
  }

  await insertAuditLog(supabase, {
    action: 'org.created',
    userId: user.id,
    orgId: organization.id,
    meta: { name: payload.name, slug },
  });

  revalidatePath('/dashboard');
  return loadOrgContext();
}

export async function inviteMember(input: unknown): Promise<void> {
  const payload = await validateInput(inviteMemberSchema, input);
  const { user } = await requireAuthState('/login');
  const supabase = await createSupabaseServerClient();

  const memberships = await fetchMemberships(supabase, user.id);
  const membership = memberships.find((row) => row.org_id === payload.orgId);

  if (
    !membership ||
    (membership.role !== 'owner' && membership.role !== 'admin')
  ) {
    throw new Error(
      'You do not have permission to invite members to this org.'
    );
  }

  const { data: profile } = (await supabase
    .from('profiles')
    .select('id, email')
    .ilike('email', payload.email)
    .maybeSingle()) as {
    data: Pick<
      Database['public']['Tables']['profiles']['Row'],
      'id' | 'email'
    > | null;
    error: PostgrestError | null;
  };

  if (!profile?.id) {
    throw new Error(
      'No user found with that email. Ask them to sign up first.'
    );
  }

  const { error } = await supabase.from('organization_members').upsert({
    org_id: payload.orgId,
    user_id: profile.id,
    role: payload.role,
  });

  if (error) {
    throw new Error(`Unable to invite member: ${error.message}`);
  }

  await insertAuditLog(supabase, {
    orgId: payload.orgId,
    userId: user.id,
    action: 'org.member.invited',
    meta: { invitee: profile.email, role: payload.role },
  });

  revalidatePath(`/settings/organization`);
}

export async function removeMember(input: unknown): Promise<void> {
  const payload = await validateInput(removeMemberSchema, input);
  const { user } = await requireAuthState('/login');
  const supabase = await createSupabaseServerClient();

  const memberships = await fetchMemberships(supabase, user.id);
  const membership = memberships.find((row) => row.org_id === payload.orgId);

  if (!membership || membership.role === 'member') {
    throw new Error('You do not have permission to remove members.');
  }

  if (payload.userId === user.id) {
    throw new Error('Use the leave organization flow to remove yourself.');
  }

  const { error } = await supabase
    .from('organization_members')
    .delete()
    .eq('org_id', payload.orgId)
    .eq('user_id', payload.userId);

  if (error) {
    throw new Error(`Unable to remove member: ${error.message}`);
  }

  await insertAuditLog(supabase, {
    orgId: payload.orgId,
    userId: user.id,
    action: 'org.member.removed',
    meta: { removedUserId: payload.userId },
  });

  revalidatePath(`/settings/organization`);
}

export async function setDefaultOrg(
  input: unknown
): Promise<OrgContextPayload> {
  const payload = await validateInput(setDefaultOrgSchema, input);
  const { user } = await requireAuthState('/login');
  const supabase = await createSupabaseServerClient();

  const memberships = await fetchMemberships(supabase, user.id);
  const owns = memberships.some((row) => row.org_id === payload.orgId);
  if (!owns) {
    throw new Error('You are not a member of that organization.');
  }

  const { error } = await supabase
    .from('profiles')
    .update({
      default_org_id: payload.orgId,
      updated_at: new Date().toISOString(),
    })
    .eq('id', user.id);

  if (error) {
    throw new Error(`Unable to set default organization: ${error.message}`);
  }

  await insertAuditLog(supabase, {
    orgId: payload.orgId,
    userId: user.id,
    action: 'org.default.updated',
  });

  revalidatePath('/dashboard');
  return loadOrgContext();
}

export async function listMembers(orgId: unknown): Promise<OrgMemberSummary[]> {
  const parsedOrgId = await validateInput(uuidSchema, orgId);
  const { user } = await requireAuthState('/login');
  const supabase = await createSupabaseServerClient();

  const memberships = await fetchMemberships(supabase, user.id);
  const membership = memberships.find((row) => row.org_id === parsedOrgId);

  if (!membership) {
    throw new Error('You do not have access to this organization.');
  }

  const { data, error } = (await supabase
    .from('organization_members')
    .select('*')
    .eq('org_id', parsedOrgId)) as {
    data: Database['public']['Tables']['organization_members']['Row'][] | null;
    error: PostgrestError | null;
  };

  if (error) {
    throw new Error(`Unable to load members: ${error.message}`);
  }

  const userIds = (data ?? []).map((row) => row.user_id);
  const profilesMap = new Map<string, { email: string | null }>();

  if (userIds.length > 0) {
    const { data: profiles, error: profilesError } = (await supabase
      .from('profiles')
      .select('id, email')
      .in('id', userIds)) as {
      data:
        | Pick<
            Database['public']['Tables']['profiles']['Row'],
            'id' | 'email'
          >[]
        | null;
      error: PostgrestError | null;
    };

    if (profilesError) {
      throw new Error(
        `Unable to load member profiles: ${profilesError.message}`
      );
    }

    for (const profile of profiles ?? []) {
      profilesMap.set(profile.id, { email: profile.email });
    }
  }

  return (data ?? []).map((row) => ({
    userId: row.user_id,
    email: profilesMap.get(row.user_id)?.email ?? null,
    role: row.role,
    joinedAt: row.created_at,
  }));
}
