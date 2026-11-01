import { Users, UserPlus, Mail } from 'lucide-react';
import { MemberDirectoryClient } from './member-directory-client';
import { PageHeader } from '@/components/layout/page-header';
import { Button } from '@/components/ui/button';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { loadOrgContext, listMembers } from '@/features/orgs/server/actions';

export default async function TeamsPage() {
  const orgContext = await loadOrgContext();
  const activeOrg = orgContext.organizations.find(
    (org) => org.id === orgContext.activeOrgId
  );
  const members = activeOrg ? await listMembers(activeOrg.id) : [];

  return (
    <>
      <PageHeader
        title='Teams'
        subtitle='Manage your workspace members and their access levels.'
      />

      <section className='grid gap-6 px-4 pb-12 lg:px-6'>
        {/* Teams Overview & Invitation */}
        <div className='grid gap-6 lg:grid-cols-[1.5fr,1fr]'>
          <Card className='border-border/60 bg-muted/5 flex flex-col shadow-none'>
            <CardHeader className='pb-4'>
              <div className='flex items-center gap-2'>
                <Users className='text-primary h-4 w-4' />
                <CardTitle className='text-base'>Team Statistics</CardTitle>
              </div>
              <CardDescription>
                Overview of member distribution for{' '}
                <span className='text-foreground font-bold'>
                  {activeOrg?.name ?? 'your workspace'}
                </span>
                .
              </CardDescription>
            </CardHeader>
            <CardContent className='flex-1'>
              <div className='grid grid-cols-2 gap-3 sm:grid-cols-4'>
                <div className='border-border/50 bg-background rounded-xl border p-4 shadow-sm'>
                  <p className='text-muted-foreground text-[10px] font-bold tracking-wider uppercase'>
                    Total
                  </p>
                  <p className='mt-1 text-2xl font-bold'>{members.length}</p>
                </div>
                <div className='border-border/50 bg-background rounded-xl border p-4 shadow-sm'>
                  <p className='text-muted-foreground text-[10px] font-bold tracking-wider uppercase'>
                    Admins
                  </p>
                  <p className='mt-1 text-2xl font-bold'>
                    {
                      members.filter(
                        (m) => m.role === 'admin' || m.role === 'owner'
                      ).length
                    }
                  </p>
                </div>
                <div className='border-border/50 bg-background rounded-xl border p-4 shadow-sm'>
                  <p className='text-muted-foreground text-[10px] font-bold tracking-wider uppercase'>
                    Pending
                  </p>
                  <p className='mt-1 text-2xl font-bold text-yellow-500'>
                    {members.filter((m) => !m.email).length}
                  </p>
                </div>
                <div className='border-border/50 bg-background text-primary rounded-xl border p-4 shadow-sm'>
                  <p className='text-muted-foreground text-[10px] font-bold tracking-wider uppercase'>
                    Active
                  </p>
                  <p className='mt-1 text-2xl font-bold'>
                    {Math.round(
                      (members.filter((m) => m.email).length /
                        (members.length || 1)) *
                        100
                    )}
                    %
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Quick Invitation */}
          <Card className='border-primary/10 bg-primary/5 shadow-none'>
            <CardHeader className='pb-4'>
              <div className='flex items-center gap-2'>
                <UserPlus className='text-primary h-4 w-4' />
                <CardTitle className='text-base font-bold'>
                  Invite Member
                </CardTitle>
              </div>
              <CardDescription>
                Add teammates by email to collaborate.
              </CardDescription>
            </CardHeader>
            <CardContent className='space-y-4'>
              <div className='space-y-2'>
                <Label
                  htmlFor='team-invite-email'
                  className='text-xs'>
                  Email address
                </Label>
                <div className='relative'>
                  <Mail className='text-muted-foreground absolute top-1/2 left-3 h-3.5 w-3.5 -translate-y-1/2' />
                  <Input
                    id='team-invite-email'
                    placeholder='colleague@company.com'
                    className='bg-background border-border/60 h-10 pl-9 shadow-none'
                  />
                </div>
              </div>
              <div className='space-y-2'>
                <Label
                  htmlFor='team-invite-role'
                  className='text-xs'>
                  Workspace role
                </Label>
                <Select defaultValue='member'>
                  <SelectTrigger
                    id='team-invite-role'
                    className='bg-background border-border/60 h-10 shadow-none'>
                    <SelectValue placeholder='Select role' />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value='member'>Member</SelectItem>
                    <SelectItem value='admin'>Admin</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <Button
                className='h-10 w-full font-bold'
                size='sm'>
                Send Invitation
              </Button>
            </CardContent>
          </Card>
        </div>

        {/* Member Directory */}
        <div className='pt-4'>
          <MemberDirectoryClient members={members} />
        </div>
      </section>
    </>
  );
}
