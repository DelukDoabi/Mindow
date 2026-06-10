-- Migration: create_user_fcm_tokens
-- Story 5.1: Notification permission & FCM setup
--
-- Stores per-user per-platform FCM registration tokens.
-- One row per (user_id, platform). Upsert on conflict updates the token.
-- Deploy via Supabase Dashboard SQL editor (corporate network workaround).

CREATE TABLE IF NOT EXISTS public.user_fcm_tokens (
  id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid        NOT NULL DEFAULT auth.uid()
                          REFERENCES auth.users(id) ON DELETE CASCADE,
  fcm_token   text        NOT NULL,
  platform    text        NOT NULL
                          CHECK (platform IN ('ios', 'android', 'web', 'other')),
  updated_at  timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT user_fcm_tokens_user_platform_unique UNIQUE (user_id, platform)
);

-- Row Level Security
ALTER TABLE public.user_fcm_tokens ENABLE ROW LEVEL SECURITY;

-- Users can only read their own tokens
CREATE POLICY "user_fcm_tokens_select_own"
  ON public.user_fcm_tokens
  FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own token (user_id defaults to auth.uid())
CREATE POLICY "user_fcm_tokens_insert_own"
  ON public.user_fcm_tokens
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own token
CREATE POLICY "user_fcm_tokens_update_own"
  ON public.user_fcm_tokens
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Index for efficient lookup by user
CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_user_id
  ON public.user_fcm_tokens (user_id);
