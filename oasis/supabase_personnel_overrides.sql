-- =============================================================
-- OASIS SPA — Move staffing settings to the server
--
-- Supabase Dashboard → SQL Editor → New query
--   → paste this entire file → Run
--
-- Safe to run more than once.
-- =============================================================
--
-- WHY THIS IS NEEDED
--
-- Staffing overrides used to be saved with SharedPreferences, which
-- is storage local to a single browser. The admin set "1 employee on
-- Tuesday" on their own device, but a customer opening the site had
-- an empty store and always fell back to the default of 3 staff.
-- So admin staffing settings had no effect on what customers could
-- actually book.
--
-- Storing them in the database makes them shared: the admin writes,
-- every customer reads.
-- =============================================================


-- -------------------------------------------------------------
-- 1. Table
-- -------------------------------------------------------------
-- override_key is either:
--   'YYYY-MM-DD'                → daily default for that date
--   'YYYY-MM-DD_HH:MM:SS'       → override for one time slot

CREATE TABLE IF NOT EXISTS personnel_overrides (
  override_key    TEXT PRIMARY KEY,
  personnel_count INTEGER NOT NULL CHECK (personnel_count >= 0),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- -------------------------------------------------------------
-- 2. Permissions
-- -------------------------------------------------------------

GRANT SELECT ON personnel_overrides TO anon, authenticated;
GRANT ALL    ON personnel_overrides TO authenticated, service_role;

ALTER TABLE personnel_overrides ENABLE ROW LEVEL SECURITY;

-- Customers must be able to READ staffing levels, otherwise the
-- booking page cannot work out which slots are available.
-- Nothing sensitive is exposed - only a count per date/slot.
DROP POLICY IF EXISTS "Public read personnel overrides" ON personnel_overrides;
CREATE POLICY "Public read personnel overrides"
  ON personnel_overrides FOR SELECT
  USING (true);

-- Only signed-in admins may change them.
DROP POLICY IF EXISTS "Admins manage personnel overrides" ON personnel_overrides;
CREATE POLICY "Admins manage personnel overrides"
  ON personnel_overrides FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);


-- -------------------------------------------------------------
-- 3. Verify
-- -------------------------------------------------------------

SELECT 'personnel_overrides table' AS check_name,
       count(*)::text AS result
FROM information_schema.tables
WHERE table_name = 'personnel_overrides'

UNION ALL

SELECT 'policies on table',
       count(*)::text
FROM pg_policies
WHERE tablename = 'personnel_overrides';

-- Expect: table = 1, policies = 2


-- -------------------------------------------------------------
-- Note on existing settings
-- -------------------------------------------------------------
-- Any staffing overrides you set before this change live in your
-- browser's local storage and are not migrated. They were never
-- visible to customers anyway. Just re-enter them in the admin
-- view once - from now on they save to the database and apply to
-- everyone.
