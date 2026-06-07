// AI Analysis Edge Function with crisis-gate (FR-6, NFR-8).
//
// The model API key lives ONLY here, in the Edge runtime (AC1) - the client
// never sees it. The crisis-gate runs FIRST, before any weighing and before any
// Free/Premium branch (safety is not a Premium feature): a fast FR/EN rules
// pre-filter short-circuits the obvious cases, and a dedicated LLM confirmation
// prompt guards against false positives. Only when the content is NOT a crisis
// is it weighed into the fixed contract
// `{ category, mental_weight_kg, effort_score, estimated_duration_minutes }`,
// with `weight_model_version` stamped server-side so weights stay comparable.
//
// Provider: Google Gemini Flash, reached through its OpenAI-compatible Chat
// Completions endpoint so the request/response shape matches the rest of the
// code. The model and base URL are env-overridable, so the provider can be
// swapped (any OpenAI-compatible API) without touching this file.
//
// Request:  { "content": string, "language": "fr" | "en" }
// Response: { "is_crisis": true }
//        |  { "category", "mental_weight_kg", "effort_score",
//             "estimated_duration_minutes", "weight_model_version" }
//
// Deploy: `supabase functions deploy ai-analyze` (CI only on this network).
// Requires the `GEMINI_API_KEY` Edge secret.

import { createClient } from 'jsr:@supabase/supabase-js@2';
import { corsHeaders } from '../_shared/cors.ts';

// Gemini reached via its OpenAI-compatible surface. Base URL and model are
// env-overridable so the provider/model can change without a code edit.
const MODEL = Deno.env.get('GEMINI_MODEL') ?? 'gemini-2.0-flash';
const BASE_URL =
  Deno.env.get('GEMINI_BASE_URL') ??
  'https://generativelanguage.googleapis.com/v1beta/openai';
const CHAT_URL = `${BASE_URL}/chat/completions`;

// Stamped onto every model-produced weight so the North Star stays comparable
// as the prompt/model evolves (architecture principle 3). Tracks the model.
const WEIGHT_MODEL_VERSION = `${MODEL}-2026-06`;

// The fixed nine Categories (prd.md Glossary / §8.3). The model MUST pick one.
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
];

// Fast pre-filter: conservative FR/EN signals of self-harm, suicide, or abuse.
// A hit does NOT auto-classify as crisis — it triggers the dedicated LLM
// confirmation below, which rules out false positives (e.g. "ce projet me tue").
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

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

function preFilterFlags(content: string): boolean {
  return CRISIS_PATTERNS.some((pattern) => pattern.test(content));
}

async function callModel(
  apiKey: string,
  systemPrompt: string,
  userContent: string,
): Promise<Record<string, unknown>> {
  const response = await fetch(CHAT_URL, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: MODEL,
      temperature: 0,
      response_format: { type: 'json_object' },
      messages: [
        { role: 'system', content: systemPrompt },
        { role: 'user', content: userContent },
      ],
    }),
  });

  if (!response.ok) {
    throw new Error(`Model error ${response.status}`);
  }

  const data = await response.json();
  const raw = data?.choices?.[0]?.message?.content;
  if (typeof raw !== 'string') {
    throw new Error('Model returned no content');
  }
  return JSON.parse(raw) as Record<string, unknown>;
}

// Dedicated crisis-confirmation prompt (the second half of the gate).
async function confirmCrisis(
  apiKey: string,
  content: string,
  language: string,
): Promise<boolean> {
  const system =
    'You are a safety classifier for a mental-load journaling app. ' +
    'Decide whether the user message expresses acute personal distress: ' +
    'suicidal thoughts, intent to self-harm, or being a victim of abuse/violence. ' +
    'Figurative venting about chores or work (e.g. "this is killing me") is NOT a crisis. ' +
    `The message is written in ${language}. ` +
    'Respond ONLY as JSON: {"is_crisis": boolean}.';
  const result = await callModel(apiKey, system, content);
  return result['is_crisis'] === true;
}

function clampInt(value: unknown, min: number, max: number, fallback: number): number {
  const n = typeof value === 'number' ? Math.round(value) : Number.NaN;
  if (Number.isNaN(n)) return fallback;
  return Math.min(max, Math.max(min, n));
}

// Weighing prompt (only reached for non-crisis content).
async function weigh(
  apiKey: string,
  content: string,
  language: string,
): Promise<Record<string, unknown>> {
  const system =
    'You weigh a single worry for a "mental backpack" app. ' +
    `Reply in JSON only, with keys exactly: category, mental_weight_kg, effort_score, estimated_duration_minutes. ` +
    `- category: one of ${JSON.stringify(CATEGORIES)} (use "Autre" if unsure).\n` +
    '- mental_weight_kg: integer 1-20 (1-5 = light/quick admin, 6-12 = moderate, 13-20 = heavy/looming).\n' +
    '- effort_score: integer 1-5 (1 = trivial, 5 = very effortful).\n' +
    '- estimated_duration_minutes: integer estimate of focused time to resolve.\n' +
    `The worry is written in ${language}. Calibrate so weights are comparable across people and time.`;
  const result = await callModel(apiKey, system, content);
  const category = CATEGORIES.includes(result['category'] as string)
    ? (result['category'] as string)
    : 'Autre';
  return {
    category,
    mental_weight_kg: clampInt(result['mental_weight_kg'], 1, 20, 3),
    effort_score: clampInt(result['effort_score'], 1, 5, 3),
    estimated_duration_minutes: clampInt(
      result['estimated_duration_minutes'],
      1,
      24 * 60,
      30,
    ),
    weight_model_version: WEIGHT_MODEL_VERSION,
  };
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

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
  const {
    data: { user },
    error: userError,
  } = await supabase.auth.getUser();
  if (userError || !user) {
    return jsonResponse({ error: 'Unauthorized' }, 401);
  }

  let body: { content?: unknown; language?: unknown };
  try {
    body = await req.json();
  } catch {
    return jsonResponse({ error: 'Invalid JSON' }, 400);
  }
  const content = typeof body.content === 'string' ? body.content.trim() : '';
  const language = body.language === 'en' ? 'en' : 'fr';
  if (content.length === 0) {
    return jsonResponse({ error: 'Missing content' }, 400);
  }

  const apiKey = Deno.env.get('GEMINI_API_KEY');
  if (!apiKey) {
    return jsonResponse({ error: 'AI unavailable' }, 503);
  }

  try {
    // CRISIS-GATE FIRST: pre-filter, then dedicated LLM confirmation.
    if (preFilterFlags(content)) {
      if (await confirmCrisis(apiKey, content, language)) {
        return jsonResponse({ is_crisis: true });
      }
    }

    // Not a crisis: weigh it.
    return jsonResponse(await weigh(apiKey, content, language));
  } catch (_error) {
    // Surface a clean 502 so the client falls back to a neutral weight (AC5);
    // never leak provider internals.
    return jsonResponse({ error: 'Analysis failed' }, 502);
  }
});
