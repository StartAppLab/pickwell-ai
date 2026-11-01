import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.117.3'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}
const json = (body: unknown, status = 200) => Response.json(body, { status, headers: corsHeaders })

// The caller can delete only their own verified account. Never accept a user ID
// from the request body, and never put the service-role key in the mobile app.
Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405)
  const authorization = req.headers.get('Authorization')
  if (!authorization?.startsWith('Bearer ')) return json({ error: 'Unauthorized' }, 401)
  const url = Deno.env.get('SUPABASE_URL')!
  const caller = createClient(url, Deno.env.get('SUPABASE_ANON_KEY')!, {
    global: { headers: { Authorization: authorization } },
    auth: { persistSession: false, autoRefreshToken: false },
  })
  const { data: { user }, error: authError } = await caller.auth.getUser()
  if (authError || !user) return json({ error: 'Unauthorized' }, 401)

  const admin = createClient(url, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!, {
    auth: { persistSession: false, autoRefreshToken: false },
  })
  try {
    // Supabase requires deleting owned storage objects before deleting a user.
    // Only visit the authenticated caller's folder; projects adding buckets must
    // extend this list. Removing each page makes retries safe and idempotent.
    async function removeFolder(bucket: string, prefix: string): Promise<void> {
      while (true) {
        const { data, error } = await admin.storage.from(bucket).list(prefix, { limit: 100 })
        if (error) throw error
        if (!data?.length) return
        const files: string[] = []
        for (const entry of data) {
          const path = `${prefix}/${entry.name}`
          if (entry.id) files.push(path)
          else await removeFolder(bucket, path)
        }
        if (files.length) {
          const { error: deleteError } = await admin.storage.from(bucket).remove(files)
          if (deleteError) throw deleteError
        }
      }
    }
    for (const bucket of ['images', 'documents', 'avatars']) await removeFolder(bucket, user.id)
    const { error } = await admin.auth.admin.deleteUser(user.id)
    if (error) throw error
    return json({ deleted: true })
  } catch (_) {
    return json({ error: 'Unable to delete account. Please try again.' }, 500)
  }
})
