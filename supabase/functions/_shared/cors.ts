// Shared CORS headers for the Mindow Supabase Edge Functions.
//
// The web client (and preflight OPTIONS requests) require permissive CORS for
// `functions.invoke`. Tighten `Access-Control-Allow-Origin` to the production
// web origin before launch.
export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};
