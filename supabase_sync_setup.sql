-- =============================================================================
-- Dayfocus Sync Setup - Run this in Supabase SQL Editor
-- =============================================================================

-- 1. Create user_profiles table to track premium status
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_profiles (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  is_premium BOOLEAN NOT NULL DEFAULT FALSE,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Users can only read/write their own profile
CREATE POLICY "Users can view own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile"
  ON user_profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = user_id);

-- 2. Add RLS policies to existing tables (if not already present)
-- -----------------------------------------------------------------------------

-- day_configs
ALTER TABLE day_configs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can manage own day_configs" ON day_configs;
CREATE POLICY "Users can manage own day_configs"
  ON day_configs FOR ALL
  USING (auth.uid() = user_id);

-- priorities
ALTER TABLE priorities ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can manage own priorities" ON priorities;
CREATE POLICY "Users can manage own priorities"
  ON priorities FOR ALL
  USING (auth.uid() = user_id);

-- time_blocks
ALTER TABLE time_blocks ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can manage own time_blocks" ON time_blocks;
CREATE POLICY "Users can manage own time_blocks"
  ON time_blocks FOR ALL
  USING (auth.uid() = user_id);

-- brain_dump_notes
ALTER TABLE brain_dump_notes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can manage own brain_dump_notes" ON brain_dump_notes;
CREATE POLICY "Users can manage own brain_dump_notes"
  ON brain_dump_notes FOR ALL
  USING (auth.uid() = user_id);

-- user_settings
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can manage own user_settings" ON user_settings;
CREATE POLICY "Users can manage own user_settings"
  ON user_settings FOR ALL
  USING (auth.uid() = user_id);

-- 3. Cleanup function - deletes data older than 30 days for free users
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION cleanup_free_user_old_data()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  cutoff_date DATE := CURRENT_DATE - INTERVAL '30 days';
BEGIN
  -- Get free users (not premium or no profile = free)
  -- Delete old day_configs and cascade will handle related data via FK
  -- But since FKs might not cascade, we delete explicitly

  -- Delete old brain_dump_notes for free users
  DELETE FROM brain_dump_notes
  WHERE day_config_id IN (
    SELECT dc.id FROM day_configs dc
    LEFT JOIN user_profiles up ON dc.user_id = up.user_id
    WHERE dc.date < cutoff_date
    AND (up.is_premium IS NULL OR up.is_premium = FALSE)
  );

  -- Delete old time_blocks for free users
  DELETE FROM time_blocks
  WHERE day_config_id IN (
    SELECT dc.id FROM day_configs dc
    LEFT JOIN user_profiles up ON dc.user_id = up.user_id
    WHERE dc.date < cutoff_date
    AND (up.is_premium IS NULL OR up.is_premium = FALSE)
  );

  -- Delete old priorities for free users
  DELETE FROM priorities
  WHERE day_config_id IN (
    SELECT dc.id FROM day_configs dc
    LEFT JOIN user_profiles up ON dc.user_id = up.user_id
    WHERE dc.date < cutoff_date
    AND (up.is_premium IS NULL OR up.is_premium = FALSE)
  );

  -- Delete old day_configs for free users
  DELETE FROM day_configs
  WHERE date < cutoff_date
  AND user_id IN (
    SELECT dc.user_id FROM day_configs dc
    LEFT JOIN user_profiles up ON dc.user_id = up.user_id
    WHERE (up.is_premium IS NULL OR up.is_premium = FALSE)
  );

  RAISE NOTICE 'Cleanup completed for data older than %', cutoff_date;
END;
$$;

-- 4. Schedule the cleanup job (requires pg_cron extension)
-- -----------------------------------------------------------------------------
-- Enable pg_cron if not already enabled (run as superuser in Supabase dashboard)
-- CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule cleanup to run daily at 3 AM UTC
-- SELECT cron.schedule(
--   'cleanup-free-user-data',
--   '0 3 * * *',
--   'SELECT cleanup_free_user_old_data();'
-- );

-- To view scheduled jobs: SELECT * FROM cron.job;
-- To remove: SELECT cron.unschedule('cleanup-free-user-data');

-- =============================================================================
-- MANUAL TEST: Run cleanup manually
-- SELECT cleanup_free_user_old_data();
-- =============================================================================
