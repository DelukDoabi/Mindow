// Send-Notification Edge Function (Story 5.2).
//
// Dispatches FCM push notifications for one of four MVP notification types:
//   daily_mission | streak | achievement | mental_load_reduced
//
// Auth:    Supabase service-role JWT only — this function is server-to-server.
//          Any other caller receives 403. (AC: #7)
// Returns: { sent: true, platform } | { sent: false, reason: "no_token" }
//
// Required Supabase secret (Dashboard → Edge Functions → Secrets):
//   FIREBASE_SERVICE_ACCOUNT_JSON — full JSON of the Firebase service account
//   key (Firebase Console → Project Settings → Service Accounts → Generate
//   new private key). NEVER commit this to the repository.
//
// FCM HTTP v1 API: OAuth 2.0 token obtained from the service account JSON via
// a self-signed RS256 JWT — no external library needed in Deno.
//
// Deploy: CI only (corporate network blocks Supabase CLI locally).
//   See .github/workflows/deploy-edge-functions.yml

import { createClient } from 'jsr:@supabase/supabase-js@2';
import { corsHeaders } from '../_shared/cors.ts';

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

type NotificationType =
  | 'daily_mission'
  | 'streak'
  | 'achievement'
  | 'mental_load_reduced';

type MessageTemplate = { title: string; body: string };

type ServiceAccount = {
  private_key: string;
  client_email: string;
  project_id: string;
};

// ---------------------------------------------------------------------------
// Notification messages — all copy reviewed against tone guardrails:
// No guilt ("tu as raté"), no urgency ("dernière chance"), no red alarms.
// (UX-DR16, UX-DR19, AC: #2)
// ---------------------------------------------------------------------------

const MESSAGES: Record<NotificationType, Record<string, MessageTemplate>> = {
  daily_mission: {
    fr: {
      title: 'Ta mission du jour',
      body: "Une petite victoire t'attend aujourd'hui.",
    },
    en: {
      title: 'Your daily mission',
      body: 'A small win is waiting for you today.',
    },
  },
  streak: {
    fr: {
      title: 'Continue comme ça !',
      body: '{days} jours de suite — tu avances.',
    },
    en: {
      title: 'Keep it up!',
      body: "{days} days in a row — you're moving forward.",
    },
  },
  achievement: {
    fr: { title: 'Nouveau badge 🌱', body: 'Tu as débloqué : {name}' },
    en: { title: 'New badge 🌱', body: 'You unlocked: {name}' },
  },
  mental_load_reduced: {
    fr: {
      title: "Ton sac s'allège",
      body: '{kg} kg de préoccupations en moins cette semaine.',
    },
    en: {
      title: 'Your load lightened',
      body: '{kg} kg fewer worries this week.',
    },
  },
};

const SUPPORTED_TYPES = new Set<string>([
  'daily_mission',
  'streak',
  'achievement',
  'mental_load_reduced',
]);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

/** Replaces `{key}` placeholders in [template] with values from [context]. */
function interpolate(
  template: string,
  context: Record<string, string | number>,
): string {
  return template.replace(
    /\{(\w+)\}/g,
    (_, key: string) => (key in context ? String(context[key]) : `{${key}}`),
  );
}

/** Converts a Uint8Array to a Base64url-encoded string (RFC 4648 §5). */
function base64urlEncode(input: Uint8Array): string {
  let str = '';
  for (const byte of input) {
    str += String.fromCharCode(byte);
  }
  return btoa(str).replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
}

/**
 * Exchanges a Firebase service account JSON for a short-lived OAuth 2.0
 * access token scoped to FCM.
 *
 * Flow: create a self-signed RS256 JWT → POST to Google token endpoint →
 * receive { access_token }.
 */
async function getOAuthToken(serviceAccount: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const enc = new TextEncoder();

  const headerB64 = base64urlEncode(
    enc.encode(JSON.stringify({ alg: 'RS256', typ: 'JWT' })),
  );
  const payloadB64 = base64urlEncode(
    enc.encode(
      JSON.stringify({
        iss: serviceAccount.client_email,
        scope: 'https://www.googleapis.com/auth/firebase.messaging',
        aud: 'https://oauth2.googleapis.com/token',
        iat: now,
        exp: now + 3600,
      }),
    ),
  );

  const signingInput = `${headerB64}.${payloadB64}`;

  // Import the PEM PKCS8 private key into Web Crypto.
  const pemBody = serviceAccount.private_key
    .replace(/-----[^-]+-----/g, '')
    .replace(/\s/g, '');
  const derBytes = Uint8Array.from(atob(pemBody), (c) => c.charCodeAt(0));
  const privateKey = await crypto.subtle.importKey(
    'pkcs8',
    derBytes,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );

  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    privateKey,
    enc.encode(signingInput),
  );

  const jwt = `${signingInput}.${base64urlEncode(new Uint8Array(signature))}`;

  const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body:
      'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer' +
      `&assertion=${jwt}`,
  });

  const tokenData = (await tokenRes.json()) as { access_token?: string };
  if (!tokenData.access_token) {
    throw new Error(
      `OAuth token fetch failed: ${JSON.stringify(tokenData)}`,
    );
  }
  return tokenData.access_token;
}

// ---------------------------------------------------------------------------
// Handler
// ---------------------------------------------------------------------------

Deno.serve(async (req) => {
  // Respond to CORS preflight (required by Supabase functions.invoke).
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  // --- Service-role gate (AC: #7) ---
  // This function MUST NOT be callable by Flutter clients. Only internal
  // server-side callers that hold the Supabase service-role key are allowed.
  const authHeader = req.headers.get('Authorization');
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!authHeader || authHeader !== `Bearer ${serviceRoleKey}`) {
    return jsonResponse({ error: 'Forbidden' }, 403);
  }

  // --- Parse body ---
  let body: {
    user_id?: unknown;
    notification_type?: unknown;
    language?: unknown;
    context?: unknown;
  };
  try {
    body = (await req.json()) as typeof body;
  } catch {
    return jsonResponse({ error: 'Invalid JSON body' }, 400);
  }

  const userId =
    typeof body.user_id === 'string' ? body.user_id : null;
  const rawType =
    typeof body.notification_type === 'string' ? body.notification_type : null;
  const language =
    typeof body.language === 'string' &&
    (body.language === 'fr' || body.language === 'en')
      ? body.language
      : 'fr';
  const context: Record<string, string | number> =
    body.context != null &&
    typeof body.context === 'object' &&
    !Array.isArray(body.context)
      ? (body.context as Record<string, string | number>)
      : {};

  if (!userId || !rawType || !SUPPORTED_TYPES.has(rawType)) {
    return jsonResponse(
      { error: 'Missing or invalid user_id / notification_type' },
      400,
    );
  }

  const notificationType = rawType as NotificationType;

  // --- Fetch FCM token (AC: #8) ---
  // Use service-role client so RLS is bypassed for the server-side lookup.
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  );

  const { data: tokenRow, error: tokenError } = await supabase
    .from('user_fcm_tokens')
    .select('fcm_token, platform')
    .eq('user_id', userId)
    .maybeSingle();

  if (tokenError) {
    console.error('[send-notification] token lookup error:', tokenError.message);
    return jsonResponse({ error: 'Failed to fetch FCM token' }, 500);
  }

  // No token → permission was not granted for this user (AC: #8).
  if (!tokenRow?.fcm_token) {
    return jsonResponse({ sent: false, reason: 'no_token' });
  }

  const fcmToken = tokenRow.fcm_token as string;
  const platform = tokenRow.platform as string;

  // --- Build notification copy (AC: #1) ---
  const langMessages = MESSAGES[notificationType];
  const template = langMessages[language] ?? langMessages['fr'];
  const title = interpolate(template.title, context);
  const bodyText = interpolate(template.body, context);

  // --- Obtain FCM OAuth access token ---
  const serviceAccountJson = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_JSON');
  if (!serviceAccountJson) {
    console.error('[send-notification] FIREBASE_SERVICE_ACCOUNT_JSON not set');
    return jsonResponse(
      { error: 'FIREBASE_SERVICE_ACCOUNT_JSON secret not configured' },
      500,
    );
  }

  let serviceAccount: ServiceAccount;
  try {
    serviceAccount = JSON.parse(serviceAccountJson) as ServiceAccount;
  } catch {
    return jsonResponse(
      { error: 'Failed to parse FIREBASE_SERVICE_ACCOUNT_JSON' },
      500,
    );
  }

  let accessToken: string;
  try {
    accessToken = await getOAuthToken(serviceAccount);
  } catch (err) {
    console.error('[send-notification] OAuth error:', err);
    return jsonResponse({ error: 'Failed to obtain FCM OAuth token' }, 500);
  }

  // --- Call FCM HTTP v1 API ---
  const projectId = serviceAccount.project_id;
  const fcmUrl = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

  const fcmRes = await fetch(fcmUrl, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      message: {
        token: fcmToken,
        notification: { title, body: bodyText },
        // data payload read by NotificationHandler on the Flutter side
        data: { type: notificationType },
      },
    }),
  });

  if (!fcmRes.ok) {
    const errText = await fcmRes.text();
    console.error('[send-notification] FCM HTTP error:', fcmRes.status, errText);
    return jsonResponse({ error: `FCM call failed: ${fcmRes.status}` }, 502);
  }

  return jsonResponse({ sent: true, platform });
});
