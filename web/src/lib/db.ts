import type {
  SupabaseClient as GenericSupabaseClient,
  PostgrestError,
} from '@supabase/supabase-js';
import type { Database } from '@/types/database';

export type SupabaseClient = GenericSupabaseClient<Database, 'public'>;

export type Organization = Database['public']['Tables']['organizations']['Row'];
export type Membership =
  Database['public']['Tables']['organization_members']['Row'];
export type BillingCustomer =
  Database['public']['Tables']['billing_customers']['Row'];

export async function insertAuditLog(
  client: SupabaseClient,
  entry: {
    orgId?: string | null;
    userId?: string | null;
    action: string;
    meta?: Record<string, unknown> | null;
  }
): Promise<void> {
  const { error } = await client.from('audit_logs').insert({
    org_id: entry.orgId ?? null,
    user_id: entry.userId ?? null,
    action: entry.action,
    meta: entry.meta ?? null,
  });

  if (error) {
    throw new Error(`Failed to append audit log: ${error.message}`);
  }
}

export async function fetchMemberships(
  client: SupabaseClient,
  userId: string
): Promise<Membership[]> {
  const { data, error } = await client.rpc('list_memberships_for_user', {
    member: userId,
  });
  if (error) {
    throw new Error(`Unable to load memberships: ${error.message}`);
  }
  return (data as Membership[] | null) ?? [];
}

export async function fetchOrganizationsForUser(
  client: SupabaseClient,
  userId: string
): Promise<Organization[]> {
  const [ownedRes, memberships] = await Promise.all([
    client.from('organizations').select('*').eq('owner_id', userId),
    fetchMemberships(client, userId),
  ]);

  if (ownedRes.error) {
    throw new Error(`Unable to load organizations: ${ownedRes.error.message}`);
  }

  const owned = ownedRes.data ?? [];
  const memberOrgIds = new Set(
    memberships.map((membership) => membership.org_id)
  );
  const memberOrgs: Organization[] = [];

  if (memberOrgIds.size > 0) {
    const { data, error } = await client
      .from('organizations')
      .select('*')
      .in('id', Array.from(memberOrgIds));

    if (error) {
      throw new Error(`Unable to load member organizations: ${error.message}`);
    }

    if (data) {
      memberOrgs.push(...data);
    }
  }

  const map = new Map<string, Organization>();
  for (const org of [...owned, ...memberOrgs]) {
    map.set(org.id, org);
  }

  return Array.from(map.values()).sort((a, b) => a.name.localeCompare(b.name));
}

export async function resolveActiveOrgId(
  client: SupabaseClient,
  userId: string,
  explicitOrgId?: string | null
): Promise<string | null> {
  const memberships = await fetchMemberships(client, userId);
  const memberOrgIds = new Set(
    memberships.map((membership) => membership.org_id)
  );

  if (explicitOrgId) {
    if (!memberOrgIds.has(explicitOrgId)) {
      throw new Error('You do not have access to the requested organization.');
    }
    return explicitOrgId;
  }

  if (memberOrgIds.size === 0) {
    return null;
  }

  const { data: profile, error } = (await client
    .from('profiles')
    .select('default_org_id')
    .eq('id', userId)
    .maybeSingle()) as {
    data: Pick<
      Database['public']['Tables']['profiles']['Row'],
      'default_org_id'
    >;
    error: PostgrestError | null;
  };

  if (error) {
    throw new Error(`Unable to load profile: ${error.message}`);
  }

  if (profile?.default_org_id && memberOrgIds.has(profile.default_org_id)) {
    return profile.default_org_id;
  }

  const firstMembership = memberships[0];
  return firstMembership?.org_id ?? null;
}
