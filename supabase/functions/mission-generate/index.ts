import { createClient } from 'jsr:@supabase/supabase-js@2';
import { corsHeaders } from '../_shared/cors.ts';

type MissionCandidate = {
  id: string;
  content: string;
  mental_weight_kg: number | null;
  estimated_duration_minutes: number | null;
  created_at: string;
};

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

function toMissionDate(timeZone: string): string {
  try {
    return new Intl.DateTimeFormat('en-CA', {
      timeZone,
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    }).format(new Date());
  } catch {
    return new Intl.DateTimeFormat('en-CA', {
      timeZone: 'UTC',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
    }).format(new Date());
  }
}

async function deterministicMissionId(
  userId: string,
  missionDate: string,
  preoccupationId: string,
): Promise<string> {
  const input = `${userId}:${missionDate}:${preoccupationId}`;
  const bytes = new TextEncoder().encode(input);
  const digest = await crypto.subtle.digest('SHA-256', bytes);
  const hex = Array.from(new Uint8Array(digest))
    .map((value) => value.toString(16).padStart(2, '0'))
    .join('');
  return `mission-${hex.slice(0, 24)}`;
}

function selectCandidate(candidates: MissionCandidate[]): MissionCandidate | null {
  const eligible = candidates.filter((candidate) => candidate.mental_weight_kg != null);
  if (eligible.length === 0) return null;

  const sorted = [...eligible].sort((a, b) => {
    const weightCompare = (b.mental_weight_kg as number) - (a.mental_weight_kg as number);
    if (weightCompare !== 0) return weightCompare;

    const durationA = a.estimated_duration_minutes ?? 30;
    const durationB = b.estimated_duration_minutes ?? 30;
    const durationCompare = durationA - durationB;
    if (durationCompare !== 0) return durationCompare;

    const createdCompare = Date.parse(a.created_at) - Date.parse(b.created_at);
    if (createdCompare !== 0) return createdCompare;

    return a.id.localeCompare(b.id);
  });

  return sorted[0];
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  const authHeader = req.headers.get('Authorization');
  if (!authHeader) {
    return jsonResponse({ error: 'Missing Authorization' }, 401);
  }

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
    return jsonResponse({ error: 'Unauthorized' }, 401);
  }

  let body: { profile_timezone?: unknown; candidates?: unknown };
  try {
    body = await req.json();
  } catch {
    body = {};
  }

  const profileTimezone =
    typeof body.profile_timezone === 'string' && body.profile_timezone.length > 0
      ? body.profile_timezone
      : 'UTC';

  const candidates = Array.isArray(body.candidates)
    ? body.candidates as MissionCandidate[]
    : [];

  const missionDate = toMissionDate(profileTimezone);
  const selected = selectCandidate(candidates);

  if (selected == null) {
    return jsonResponse({ mission_date: missionDate, mission: null });
  }

  const missionId = await deterministicMissionId(user.id, missionDate, selected.id);

  return jsonResponse({
    mission_date: missionDate,
    mission: {
      id: missionId,
      preoccupation_id: selected.id,
      preoccupation_content: selected.content,
      mission_date: missionDate,
      estimated_kg_gain: selected.mental_weight_kg,
      estimated_duration_minutes: selected.estimated_duration_minutes ?? 30,
      created_at: new Date().toISOString(),
    },
  });
});
