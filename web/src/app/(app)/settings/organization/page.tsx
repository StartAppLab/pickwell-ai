import {
  Building2,
  Users,
  UserPlus,
  PlusIcon,
  Shield,
  Trash2,
  Globe,
} from 'lucide-react';
import { notFound } from 'next/navigation';
import { PageHeader } from '@/components/layout/page-header';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  createOrg,
  inviteMember,
  listMembers,
  loadOrgContext,
  removeMember,
  setDefaultOrg,
} from '@/features/orgs/server/actions';
import { requireAuthState } from '@/lib/auth';
import { formatDate } from '@/lib/utils';

export default async function OrganizationSettingsPage() {
  const { user } = await requireAuthState('/login');
  const orgContext = await loadOrgContext();

  const activeOrg = orgContext.organizations.find(
    (org) => org.id === orgContext.activeOrgId
  );
  const members = activeOrg ? await listMembers(activeOrg.id) : [];

  return (
    <>
      <PageHeader
        title='Organization'
        subtitle='Create teams, manage workspace access, and switch your active context.'
        backHref='/settings'
      />
      <section className='grid gap-6 px-4 pb-12 lg:px-6'>
        {/* Organizations Management Card */}
        <Card>
          <CardHeader>
            <div className='flex items-center justify-between'>
              <div className='space-y-1'>
                <div className='flex items-center gap-2'>
                  <Building2 className='text-primary h-4 w-4' />
                  <CardTitle>Workspaces</CardTitle>
                </div>
                <CardDescription>
                  Manage your organization memberships and default workspaces.
                </CardDescription>
              </div>
              <Dialog>
                <DialogTrigger asChild>
                  <Button size='sm'>
                    <PlusIcon className='mr-2 h-4 w-4' />
                    Create New
                  </Button>
                </DialogTrigger>
                <DialogContent className='sm:max-w-md'>
                  <DialogHeader>
                    <DialogTitle>Create Organization</DialogTitle>
                    <DialogDescription>
                      Spin up a new workspace with its own members and usage.
                    </DialogDescription>
                  </DialogHeader>
                  <form
                    action={createOrgFormAction}
                    className='space-y-4'>
                    <div className='space-y-2'>
                      <Label htmlFor='name'>Workspace Name</Label>
                      <Input
                        id='name'
                        name='name'
                        required
                        placeholder='StartAppLab'
                      />
                    </div>
                    <div className='space-y-2'>
                      <Label htmlFor='slug'>Workspace Slug (optional)</Label>
                      <div className='flex items-center gap-1.5'>
                        <span className='text-muted-foreground text-sm'>/</span>
                        <Input
                          id='slug'
                          name='slug'
                          placeholder='startapplab'
                          className='flex-1'
                        />
                      </div>
                    </div>
                    <div className='flex justify-end gap-2 pt-2'>
                      <Button
                        type='submit'
                        variant='default'>
                        Create Organization
                      </Button>
                    </div>
                  </form>
                </DialogContent>
              </Dialog>
            </div>
          </CardHeader>
          <CardContent className='space-y-4'>
            {orgContext.organizations.length === 0 ? (
              <div className='bg-muted/30 border-border grid place-items-center rounded-xl border border-dashed py-12 text-center'>
                <Building2 className='text-muted-foreground/50 mb-3 h-10 w-10' />
                <p className='text-muted-foreground text-sm font-medium'>
                  No organizations found.
                </p>
                <p className='text-muted-foreground/70 text-xs'>
                  Create your first workspace to get started.
                </p>
              </div>
            ) : (
              <div className='grid gap-3'>
                {orgContext.organizations.map((org) => (
                  <form
                    key={org.id}
                    action={setDefaultOrgFormAction}
                    className={`border-border flex items-center justify-between gap-4 rounded-xl border p-4 transition-all ${
                      orgContext.activeOrgId === org.id
                        ? 'bg-primary/5 ring-primary/20 ring-1'
                        : 'hover:bg-muted/50'
                    }`}>
                    <input
                      type='hidden'
                      name='orgId'
                      value={org.id}
                    />
                    <div className='flex items-center gap-3'>
                      <div className='bg-background border-border flex h-10 w-10 items-center justify-center rounded-lg border shadow-sm'>
                        <Building2 className='text-muted-foreground h-5 w-5' />
                      </div>
                      <div className='space-y-0.5'>
                        <p className='text-foreground text-sm font-bold'>
                          {org.name}
                        </p>
                        {org.slug && (
                          <div className='text-muted-foreground flex items-center gap-1 text-xs'>
                            <Globe className='h-3 w-3' />
                            <span>/{org.slug}</span>
                          </div>
                        )}
                      </div>
                    </div>
                    {orgContext.activeOrgId === org.id ? (
                      <Badge
                        variant='default'
                        className='h-7 rounded-md px-3'>
                        Active
                      </Badge>
                    ) : (
                      <Button
                        type='submit'
                        variant='outline'
                        size='sm'
                        className='h-8'>
                        Set Active
                      </Button>
                    )}
                  </form>
                ))}
              </div>
            )}
          </CardContent>
        </Card>

        {activeOrg && (
          <div className='grid gap-6'>
            {/* Team Members Management Card */}
            <Card>
              <CardHeader>
                <div className='flex items-center gap-2'>
                  <Users className='text-primary h-4 w-4' />
                  <CardTitle>Team Members</CardTitle>
                </div>
                <CardDescription>
                  Anyone with an invite has access to resources in{' '}
                  <span className='text-foreground font-bold'>
                    {activeOrg.name}
                  </span>
                  .
                </CardDescription>
              </CardHeader>
              <CardContent className='space-y-6'>
                <div className='border-border overflow-hidden rounded-xl border'>
                  <div className='overflow-x-auto'>
                    <table className='w-full text-left text-sm'>
                      <thead className='bg-muted/50 border-border border-b'>
                        <tr className='text-muted-foreground text-xs font-semibold tracking-wider uppercase'>
                          <th className='px-6 py-4'>Team Member</th>
                          <th className='px-6 py-4'>Access Role</th>
                          <th className='px-6 py-4'>Joined Date</th>
                          <th className='px-6 py-4 text-right'>Action</th>
                        </tr>
                      </thead>
                      <tbody className='divide-border bg-card divide-y'>
                        {members.length === 0 ? (
                          <tr>
                            <td
                              colSpan={4}
                              className='bg-muted/10 text-muted-foreground px-6 py-12 text-center text-sm'>
                              No members in this workspace yet.
                            </td>
                          </tr>
                        ) : (
                          members.map((member) => (
                            <tr
                              key={member.userId}
                              className='hover:bg-muted/30 transition-colors'>
                              <td className='px-6 py-4'>
                                <span className='text-foreground font-medium'>
                                  {member.email ?? 'Pending Invitation'}
                                </span>
                              </td>
                              <td className='px-6 py-4'>
                                <Badge
                                  className='h-6 rounded-md px-2 text-[10px]'
                                  variant={
                                    member.role === 'owner'
                                      ? 'default'
                                      : 'secondary'
                                  }>
                                  {member.role.toUpperCase()}
                                </Badge>
                              </td>
                              <td className='text-muted-foreground px-6 py-4 text-xs font-medium'>
                                {formatDate(member.joinedAt)}
                              </td>
                              <td className='px-6 py-4 text-right'>
                                {canRemove(
                                  member.userId,
                                  member.role,
                                  user.id,
                                  activeOrg.membershipRole
                                ) ? (
                                  <form action={removeMemberFormAction}>
                                    <input
                                      type='hidden'
                                      name='orgId'
                                      value={activeOrg.id}
                                    />
                                    <input
                                      type='hidden'
                                      name='userId'
                                      value={member.userId}
                                    />
                                    <Button
                                      type='submit'
                                      variant='ghost'
                                      size='icon'
                                      className='text-destructive hover:bg-destructive/10 hover:text-destructive h-8 w-8'>
                                      <Trash2 className='h-4 w-4' />
                                    </Button>
                                  </form>
                                ) : (
                                  <Shield className='text-muted-foreground/30 ml-auto h-4 w-4' />
                                )}
                              </td>
                            </tr>
                          ))
                        )}
                      </tbody>
                    </table>
                  </div>
                </div>

                {/* Invitation Section */}
                <div className='bg-primary/5 border-primary/10 rounded-xl border p-6'>
                  <div className='mb-4 flex items-center gap-2'>
                    <div className='bg-primary/10 flex h-8 w-8 items-center justify-center rounded-lg'>
                      <UserPlus className='text-primary h-4 w-4' />
                    </div>
                    <div className='space-y-0.5'>
                      <h4 className='text-foreground text-sm font-bold'>
                        Invite Teammate
                      </h4>
                      <p className='text-muted-foreground text-xs'>
                        New members will receive an email to join this
                        workspace.
                      </p>
                    </div>
                  </div>
                  <form
                    action={inviteMemberFormAction}
                    className='flex flex-col gap-4 sm:flex-row sm:items-end'>
                    <input
                      type='hidden'
                      name='orgId'
                      value={activeOrg.id}
                    />
                    <div className='flex-1 space-y-2'>
                      <Label
                        htmlFor='invite-email'
                        className='text-xs'>
                        Email Address
                      </Label>
                      <Input
                        id='invite-email'
                        name='email'
                        type='email'
                        required
                        placeholder='teammate@company.com'
                        className='bg-background h-10'
                      />
                    </div>
                    <div className='space-y-2'>
                      <Label
                        htmlFor='invite-role'
                        className='text-xs'>
                        Workspace Role
                      </Label>
                      <Select
                        name='role'
                        defaultValue='member'>
                        <SelectTrigger className='bg-background h-10 w-full sm:w-[140px]'>
                          <SelectValue placeholder='Select Role' />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value='member'>Member</SelectItem>
                          <SelectItem value='admin'>Admin</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    <Button
                      type='submit'
                      className='h-10 px-6'>
                      Send Request
                    </Button>
                  </form>
                </div>
              </CardContent>
            </Card>
          </div>
        )}
      </section>
    </>
  );
}

async function createOrgFormAction(formData: FormData) {
  'use server';

  const name = formData.get('name')?.toString().trim();
  if (!name) {
    throw new Error('Organization name is required.');
  }
  const slug = formData.get('slug')?.toString().trim();
  await createOrg({ name, slug });
}

async function setDefaultOrgFormAction(formData: FormData) {
  'use server';

  const orgId = formData.get('orgId')?.toString();
  if (!orgId) {
    throw notFound();
  }
  await setDefaultOrg({ orgId });
}

async function inviteMemberFormAction(formData: FormData) {
  'use server';

  const orgId = formData.get('orgId')?.toString();
  const email = formData.get('email')?.toString();
  const role = formData.get('role')?.toString();
  if (!orgId || !email) {
    throw new Error('Missing invitation details.');
  }
  await inviteMember({
    orgId,
    email,
    role: role === 'admin' ? 'admin' : 'member',
  });
}

async function removeMemberFormAction(formData: FormData) {
  'use server';

  const orgId = formData.get('orgId')?.toString();
  const userId = formData.get('userId')?.toString();
  if (!orgId || !userId) {
    throw new Error('Missing removal details.');
  }
  await removeMember({ orgId, userId });
}

function canRemove(
  targetUserId: string,
  role: string,
  currentUserId: string,
  currentRole: string | null
): boolean {
  if (!currentRole || currentRole === 'member') {
    return false;
  }
  if (role === 'owner') {
    return false;
  }
  if (targetUserId === currentUserId) {
    return false;
  }
  return true;
}
