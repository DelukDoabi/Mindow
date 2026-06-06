// GDPR data export Edge Function (NFR-10).
//
// Authenticates the caller via their JWT and returns their personal data as
// JSON. The full payload (Preoccupations + derived data) is gathered once
// those tables land with the Epic 2 sync engine; this scaffold establishes the
// authenticated contract and the response shape.
//
// Deploy: `supabase functions deploy account-export`.

import { createClient } from 'jsr:@supabase/supabase-js@2';
import { corsHeaders } from '../_shared/cors.ts';

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  const authHeader = req.headers.get('Authorization');
  if (!authHeader) {
    return new Response(JSON.stringify({ error: 'Missing Authorization' }), {
      status: 401,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }

  // Auth-scoped client: RLS ensures the caller only ever reads their own rows.
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    { global: { headers: { Authorization: authHeader } } },
  );

  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser();

  if (userError || !user) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), {
      status: 401,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }

  // Epic 2: gather the user's Preoccupations and derived data here, e.g.
  //   const { data: preoccupations } = await supabase
  //     .from('preoccupations').select('*').eq('user_id', user.id);
  const exportPayload = {
    exportedAt: new Date().toISOString(),
    user: { id: user.id, email: user.email },
    preoccupations: [] as unknown[],
    derived: {} as Record<string, unknown>,
  };

  return new Response(JSON.stringify(exportPayload), {
    status: 200,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
});
