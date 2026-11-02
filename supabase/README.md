# Supabase Project Structure

This backend is optional for the consumer Flutter starter. Run CLI commands from
the repository root. Supabase authentication, profile editing, account deletion,
and storage use the migrations in this directory. The posts/comments/likes schema
is sample content, not a mandatory consumer data model.

```sh
supabase start
supabase db reset
supabase test db
supabase functions serve delete-account
```

Docker is required for the local stack. Apply migrations and deploy delete-account
to the generated app's own backend before enabling production account deletion.
The native auth callback and Supabase redirect allowlist must match; see
../mobile/README.md. Storage uploads use `<userId>/...` paths. Roles are managed by
the server; owners can edit profile fields but cannot promote themselves.

The consumer migration creates images, documents, and avatars buckets and their
RLS policies. It also allows self notifications. Storage policy files outside the
migration directory are no longer an installation step.

## Pickwell catalog foundation

The additive T02.1 migration, server-only published projection, private jobs and
explicit synthetic demo seed are documented in
[PICKWELL_CATALOG_FOUNDATION.md](../docs/PICKWELL_CATALOG_FOUNDATION.md).
The new seed runs alongside existing sample content on local reset. Its demo
barcode is `2900000000018` (canonical `02900000000018`); never present its fictional
facts as a real food analysis. Full local Supabase validation has passed with
experimental Native Runtime (CLI 2.122.0, PostgreSQL 15.19), without Docker. The
linked evidence describes the isolated setup and named-stack command details.

## Optional premium backend access

[modules/subscriptions/README.md](modules/subscriptions/README.md) provides an
explicitly installed entitlement schema, RLS helper, RevenueCat webhook,
authenticated refresh endpoint, and protected-operation example. It requires
signed-in Supabase users for paid backend access. The default migrations and
functions remain unaffected until the module is installed. Client billing flags
and local guards do not authorize server operations.

## 📁 Directory Structure

```
supabase/
├── config.toml                 # Supabase configuration
├── seed.sql                    # Main seed file
├── migrations/                 # Database migrations
│   ├── 20240101000000_initial_schema.sql
│   └── 20240101000001_rls_policies.sql
├── seed/                       # Seed data files
│   ├── 01_categories.sql
│   ├── 02_tags.sql
│   └── 03_sample_posts.sql
├── functions/                  # Edge functions
│   ├── hello-world/
│   │   └── index.ts
│   ├── send-notification/
│   │   └── index.ts
│   └── process-image/
│       └── index.ts
├── storage/                    # Storage configuration
│   ├── buckets/
│   │   ├── images.json
│   │   └── documents.json
│   └── objects/
│       └── avatars/
│           └── default-avatar.png
└── policies/                   # Additional policies
    └── storage_policies.sql
```

## 🚀 Getting Started

### 1. Initialize Supabase
```bash
supabase init
```

### 2. Start Local Development
```bash
supabase start
```

### 3. Apply Migrations
```bash
supabase db reset
```

### 4. Run Seed Data
```bash
supabase db seed
```

## 📊 Database Schema

### Core Tables
- **profiles** - User profiles extending auth.users
- **posts** - Blog posts with status and publishing
- **comments** - Nested comments system
- **likes** - Post likes with unique constraints
- **follows** - User following relationships
- **notifications** - User notifications system

### Content Management
- **categories** - Post categories with colors
- **tags** - Flexible tagging system
- **post_categories** - Many-to-many relationship
- **post_tags** - Many-to-many relationship

### Features
- ✅ Row Level Security (RLS) policies
- ✅ Automatic timestamps with triggers
- ✅ User signup handling
- ✅ Slug generation for posts
- ✅ Comprehensive indexing

## 🔧 Edge Functions

### hello-world
Simple greeting function for testing.

### send-notification
Creates an in-app database notification for the verified caller only. It does not deliver remote push.

### delete-account
Verifies the caller, deletes their files from the consumer buckets, and deletes
their auth account. Extend cleanup for new buckets or external user data. It never
accepts a target user ID from the request body.

### process-image
An authenticated image-copy scaffold accepts `source_path` inside the caller's
`<userId>/...` folder. It uses caller-scoped storage permissions and never fetches
arbitrary URLs. Nonempty `transformations` are rejected until a real transformer
is added; the response explicitly reports `transformed: false`.

## 📦 Storage Buckets

### images
- **Public**: Yes
- **Size limit**: 50MB
- **Types**: JPEG, PNG, GIF, WebP
- **Use case**: User uploads, post images

### documents
- **Public**: No
- **Size limit**: 50MB
- **Types**: PDF, DOC, DOCX, TXT, CSV
- **Use case**: Private document storage

## 🔐 Security

### Row Level Security
All tables have comprehensive RLS policies:
- Users can only access their own data
- Public content is readable by everyone
- Admin users have elevated permissions

### Storage Policies
- Public images are accessible to everyone
- Users can only manage their own files
- Proper folder structure for user isolation

## 🎯 Usage Examples

### Create a Post
```sql
insert into posts (user_id, title, content, status)
values (auth.uid(), 'My Post', 'Content here', 'published');
```

### Get User's Posts
```sql
select * from posts 
where user_id = auth.uid() 
order by created_at desc;
```

### Follow a User
```sql
insert into follows (follower_id, following_id)
values (auth.uid(), 'user-uuid-here');
```

### Upload an Image
```javascript
const { data, error } = await supabase.storage
  .from('images')
  .upload(`${userId}/${fileName}`, file)
```

## 🔄 Migration Workflow

1. Create new migration: `supabase migration new migration_name`
2. Write SQL in the generated file
3. Apply migration: `supabase db push`
4. Update seed data if needed

## 📝 Notes

- All timestamps use UTC timezone
- UUIDs are used for all primary keys
- Proper foreign key constraints maintain data integrity
- Indexes are optimized for common query patterns
- Triggers handle automatic timestamp updates

## 🆘 Troubleshooting

### Common Issues
- **RLS blocking queries**: Check your policies and user authentication
- **Storage uploads failing**: Verify bucket policies and file size limits
- **Functions not working**: Check Deno permissions and environment variables

### Useful Commands
```bash
# Check database status
supabase status

# View logs
supabase logs

# Reset database
supabase db reset

# Generate types
supabase gen types typescript --local > types/database.types.ts
```
