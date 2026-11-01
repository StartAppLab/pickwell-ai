import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.117.3'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

// Creates an in-app notification for the verified caller. This does not send push.
Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })
  if (req.method !== 'POST') return Response.json({ error: 'Method not allowed' }, { status: 405, headers: corsHeaders })
  const client = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!, {
    global: { headers: { Authorization: req.headers.get('Authorization') ?? '' } },
  })
  const { data: { user }, error: authError } = await client.auth.getUser()
  if (authError || !user) return Response.json({ error: 'Unauthorized' }, { status: 401, headers: corsHeaders })
  try {
    const { type, title, message, data } = await req.json()
    if (!['like', 'comment', 'follow', 'mention'].includes(type) || typeof title !== 'string' ||
        title.length < 1 || title.length > 200 || (message != null && (typeof message !== 'string' || message.length > 2000))) {
      return Response.json({ error: 'Invalid notification' }, { status: 400, headers: corsHeaders })
    }
    const { data: notification, error } = await client.from('notifications').insert({
      user_id: user.id, type, title, message, data: data ?? null,
    }).select().single()
    if (error) throw error
    return Response.json({ notification }, { headers: corsHeaders })
  } catch (_) {
    return Response.json({ error: 'Unable to create notification' }, { status: 400, headers: corsHeaders })
  }
})
