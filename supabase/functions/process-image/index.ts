import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.117.3'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}
const json = (body: unknown, status = 200) => Response.json(body, { status, headers: corsHeaders })

// Safe extension scaffold: copy an authenticated user's stored image. Add an
// actual image transformer before accepting transformations. Never fetch an
// arbitrary caller-supplied URL or upload through a service-role client here.
Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })
  if (req.method !== 'POST') return json({ error: 'Method not allowed' }, 405)
  const client = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!, {
    global: { headers: { Authorization: req.headers.get('Authorization') ?? '' } },
  })
  const { data: { user }, error: authError } = await client.auth.getUser()
  if (authError || !user) return json({ error: 'Unauthorized' }, 401)
  try {
    const { source_path, transformations } = await req.json()
    if (typeof source_path !== 'string' || !source_path.startsWith(`${user.id}/`) ||
        source_path.includes('..') || source_path.includes('\\')) {
      return json({ error: 'Use an image path inside your own storage folder' }, 400)
    }
    if (transformations != null && Object.keys(transformations).length) {
      return json({ error: 'Image transformations are not implemented' }, 501)
    }
    const { data: image, error: downloadError } = await client.storage.from('images').download(source_path)
    if (downloadError || !image) throw downloadError
    const extensions: Record<string, string> = {
      'image/jpeg': 'jpg', 'image/png': 'png', 'image/gif': 'gif', 'image/webp': 'webp',
    }
    const extension = extensions[image.type]
    if (!extension || image.size > 52428800) return json({ error: 'Unsupported image' }, 400)
    const path = `${user.id}/copies/${crypto.randomUUID()}.${extension}`
    const { error } = await client.storage.from('images').upload(path, image, { contentType: image.type })
    if (error) throw error
    const { data } = client.storage.from('images').getPublicUrl(path)
    return json({ path, image_url: data.publicUrl, transformed: false })
  } catch (_) {
    return json({ error: 'Unable to copy image' }, 400)
  }
})
