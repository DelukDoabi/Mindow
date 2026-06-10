// AI Analysis Edge Function with crisis-gate (FR-6, NFR-8).
//
// Provider: Groq — GROQ_API_KEY Edge secret required; GROQ_MODEL optional.
// The API key NEVER leaves the Edge runtime (OWASP).
//
// Request:  { "content": string, "language": "fr" | "en" }
// Response: { "is_crisis": true }
//        |  { "category", "mental_weight_kg", "effort_score",
//             "estimated_duration_minutes", "weight_model_version" }
//
// Deploy: CI-only (corporate network blocks Supabase CLI — see deploy-edge-functions.yml).

import { createClient } from 'jsr:@supabase/supabase-js@2';
import { corsHeaders } from '../_shared/cors.ts';

// ---------------------------------------------------------------------------
// Groq configuration
// ---------------------------------------------------------------------------

const AI_API_KEY = Deno.env.get('GROQ_API_KEY');
const MODEL      = Deno.env.get('GROQ_MODEL') ?? 'llama-3.3-70b-versatile';
const CHAT_URL   = 'https://api.groq.com/openai/v1/chat/completions';
const WEIGHT_MODEL_VERSION = `groq-${MODEL}-2026-06`;

console.log(`[ai-analyze] model=${MODEL}`);

// ---------------------------------------------------------------------------
// Domain constants
// ---------------------------------------------------------------------------

// The fixed nine categories (prd.md Glossary / §8.3). The model MUST pick one.
const CATEGORIES = [
  'Administratif',
  'Famille',
  'Santé',
  'Travail',
  'Finance',
  'Maison',
  'Personnel',
  'Voyage',
  'Autre',
] as const;

// Fast pre-filter: conservative FR/EN signals of self-harm, suicide, or abuse.
// A hit does NOT auto-classify as crisis — it triggers LLM confirmation below,
// which rules out false positives (e.g. "ce projet me tue").
const CRISIS_PATTERNS: RegExp[] = [
  /\bsuicide\b/i,
  /\bsuicidaire\b/i,
  /me\s+suicider/i,
  /\bme\s+tuer\b/i,
  /en\s+finir\b/i,
  /\bmourir\b/i,
  /\bplus\s+envie\s+de\s+vivre\b/i,
  /\bautomutilation\b/i,
  /me\s+faire\s+du\s+mal/i,
  /\bkill\s+myself\b/i,
  /\bend\s+my\s+life\b/i,
  /\bwant\s+to\s+die\b/i,
  /\bself[-\s]?harm\b/i,
  /\bhurt\s+myself\b/i,
  /\bsuicidal\b/i,
  /\babus(e|é|ée|és)\b/i,
  /\bviol(ence|ent|enté)\b/i,
  /\bbattu(e|es)?\b/i,
];

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

function preFilterFlags(content: string): boolean {
  return CRISIS_PATTERNS.some((p) => p.test(content));
}

function clampInt(value: unknown, min: number, max: number, fallback: number): number {
  const n = Math.round(Number(value));
  return Number.isFinite(n) ? Math.min(max, Math.max(min, n)) : fallback;
}

// ---------------------------------------------------------------------------
// Core LLM call — module-level AI_API_KEY / CHAT_URL / MODEL are used.
// ---------------------------------------------------------------------------

async function callModel(
  systemPrompt: string,
  userContent: string,
): Promise<Record<string, unknown>> {
  const maxAttempts = 3;
  let lastError: Error = new Error('callModel: no attempt made');

  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      console.log(`[ai-analyze] attempt ${attempt + 1}/${maxAttempts} → ${CHAT_URL}`);
      const response = await fetch(CHAT_URL, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${AI_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: MODEL,
          temperature: 0,
          response_format: { type: 'json_object' },
          messages: [
            { role: 'system', content: systemPrompt },
            { role: 'user',   content: userContent  },
          ],
        }),
      });

      console.log(`[ai-analyze] response status: ${response.status}`);

      if (response.status === 429) {
        const retryAfter = response.headers.get('Retry-After');
        const delayMs    = retryAfter
          ? parseInt(retryAfter, 10) * 1000
          : 1000 * Math.pow(2, attempt);
        console.warn(`[ai-analyze] 429 rate-limit, retrying in ${delayMs}ms`);
        await new Promise((r) => setTimeout(r, delayMs));
        lastError = new Error('Rate limited (429)');
        continue;
      }

      if (!response.ok) {
        let body = '<unreadable>';
        try { body = await response.text(); } catch { /* ignore */ }
        const msg = `Provider error ${response.status}: ${body}`;
        console.error(`[ai-analyze] ${msg}`);
        throw new Error(msg);
      }

      const data = await response.json();
      const raw  = data?.choices?.[0]?.message?.content;
      if (typeof raw !== 'string') {
        throw new Error(`Provider returned no content. data=${JSON.stringify(data)}`);
      }
      return JSON.parse(raw) as Record<string, unknown>;
    } catch (err) {
      lastError = err instanceof Error ? err : new Error(String(err));
      if (attempt < maxAttempts - 1) {
        console.warn(`[ai-analyze] attempt ${attempt + 1} failed: ${lastError.message} — retrying`);
      }
    }
  }

  throw lastError;
}

// ---------------------------------------------------------------------------
// Crisis confirmation (second half of the gate)
// ---------------------------------------------------------------------------

async function confirmCrisis(content: string, language: string): Promise<boolean> {
  const system =
    'You are a safety classifier for a mental-load journaling app. ' +
    'Decide whether the user message expresses ACUTE personal distress: ' +
    'suicidal thoughts, intent to self-harm, or being a victim of abuse/violence. ' +
    'Figurative venting ("this project is killing me") is NOT a crisis. ' +
    `The message is in ${language}. ` +
    'Respond ONLY as JSON: {"is_crisis": boolean}';
  const result = await callModel(system, content);
  return result['is_crisis'] === true;
}

// ---------------------------------------------------------------------------
// Weighing
// ---------------------------------------------------------------------------

async function weigh(content: string, language: string): Promise<Record<string, unknown>> {
  const system =
    'You weigh a single worry for a "mental backpack" app. ' +
    `Reply in JSON only, with EXACTLY these keys: category, mental_weight_kg, effort_score, estimated_duration_minutes.\n` +
    `- category: one of ${JSON.stringify(CATEGORIES)} — use "Autre" if unsure.\n` +
    '- mental_weight_kg: integer 1-20 (1-5 light/quick, 6-12 moderate, 13-20 heavy/looming).\n' +
    '- effort_score: integer 1-5 (1=trivial, 5=very effortful).\n' +
    '- estimated_duration_minutes: integer minutes of focused time to resolve.\n' +
    `The worry is in ${language}. Calibrate so weights are comparable across users and time.`;

  const result   = await callModel(system, content);
  const category = (CATEGORIES as readonly string[]).includes(result['category'] as string)
    ? (result['category'] as string)
    : 'Autre';

  return {
    category,
    mental_weight_kg:           clampInt(result['mental_weight_kg'],           1,     20, 3),
    effort_score:               clampInt(result['effort_score'],               1,      5, 3),
    estimated_duration_minutes: clampInt(result['estimated_duration_minutes'], 1, 24 * 60, 30),
    weight_model_version: WEIGHT_MODEL_VERSION,
  };
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  // --- Auth ---
  const authHeader = req.headers.get('Authorization');
  if (!authHeader) {
    return jsonResponse({ error: 'Missing Authorization' }, 401);
  }

  // Auth-scoped client: confirms the caller is a real authenticated user.
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    { global: { headers: { Authorization: authHeader } } },
  );
  try {
    const { data, error: userError } = await supabase.auth.getUser();
    if (userError || !data.user) {
      return jsonResponse({ error: 'Unauthorized' }, 401);
    }
  } catch (err) {
    console.error('[ai-analyze] auth check failed:', err);
    return jsonResponse({ error: 'Unauthorized' }, 401);
  }

  // --- API key guard ---
  if (!AI_API_KEY) {
    console.error('[ai-analyze] GROQ_API_KEY secret is not set.');
    return jsonResponse({ error: 'AI unavailable' }, 503);
  }

  // --- Parse body ---
  let body: { content?: unknown; language?: unknown };
  try {
    body = await req.json();
  } catch {
    return jsonResponse({ error: 'Invalid JSON' }, 400);
  }
  const content  = typeof body.content  === 'string' ? body.content.trim() : '';
  const language = body.language === 'en' ? 'en' : 'fr';
  if (content.length === 0) {
    return jsonResponse({ error: 'Missing content' }, 400);
  }

  // --- Crisis gate first, then weigh ---
  try {
    if (preFilterFlags(content)) {
      console.log('[ai-analyze] pre-filter triggered → LLM crisis confirmation');
      if (await confirmCrisis(content, language)) {
        console.log('[ai-analyze] crisis confirmed → returning is_crisis:true');
        return jsonResponse({ is_crisis: true });
      }
      console.log('[ai-analyze] crisis not confirmed → proceeding to weigh');
    }

    const result = await weigh(content, language);
    console.log('[ai-analyze] weight assigned:', JSON.stringify(result));
    return jsonResponse(result);
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    console.error('[ai-analyze] fatal error:', msg);
    return jsonResponse({ error: 'Analysis failed' }, 502);
  }
});
