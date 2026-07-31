-- =============================================================
-- OASIS SPA — COMPLETE SETUP (run this one file)
--
-- Supabase Dashboard → SQL Editor → New query
--   → paste this entire file → Run
--
-- Safe to run as many times as you like.
-- Does NOT touch your treatments menu (no risk of duplicates).
--
-- Supersedes: supabase_migration_booking_fixes.sql
--             supabase_email_trigger.sql
--
-- ⚠ BEFORE RUNNING, do the one-time Vault step in PART 4 below,
--   or emails will install correctly but send nothing.
-- =============================================================


-- =============================================================
-- PART 1 — FIX: bookings currently fail to save
-- =============================================================
-- The app sends a 'scrub_type' value when creating a booking, but
-- the column does not exist, so Postgres rejects every insert with
--   column "scrub_type" of relation "bookings" does not exist
-- This is why no booking gets through.

ALTER TABLE bookings
  ADD COLUMN IF NOT EXISTS scrub_type TEXT;


-- =============================================================
-- PART 2 — FIX: pending bookings did not reserve their slot
-- =============================================================
-- With admin approval, a booking waits as 'pending'. Availability
-- only looked at 'confirmed', so a slot awaiting approval still
-- appeared free — two customers could take the same room and time,
-- and approving the second would fail.
-- Pending bookings now hold their slot until you decide.

CREATE OR REPLACE FUNCTION get_anonymized_bookings(target_date DATE)
RETURNS TABLE (
  start_time TIME,
  end_time TIME,
  room_number INTEGER
)
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT b.start_time, b.end_time, b.room_number
  FROM bookings b
  WHERE b.booking_date = target_date
    AND b.status IN ('pending', 'confirmed');
END;
$$ LANGUAGE plpgsql;


-- =============================================================
-- PART 3 — FIX: double-booking guard
-- =============================================================
-- Enforces the same rule in the database, so two people can never
-- end up in one room even if they book at the exact same moment.
--
-- NOTE: if this errors with "could not create unique index", you
-- already have clashing bookings. Find them with:
--
--   SELECT booking_date, start_time, room_number, count(*)
--   FROM bookings
--   WHERE status IN ('pending','confirmed')
--   GROUP BY booking_date, start_time, room_number
--   HAVING count(*) > 1;
--
-- Cancel the unwanted duplicates, then re-run this file.

DROP INDEX IF EXISTS unique_booking_slot;

CREATE UNIQUE INDEX IF NOT EXISTS unique_booking_slot
  ON bookings (booking_date, start_time, room_number)
  WHERE status IN ('pending', 'confirmed');


-- =============================================================
-- PART 4 — Confirmation email when you approve a booking
-- =============================================================
-- ONE-TIME SETUP BEFORE THIS WORKS:
--
--  a) Rotate your Resend key — the old one was committed to git.
--     https://resend.com/api-keys  (delete old, create new)
--
--  b) Supabase → Project Settings → Vault → Add new secret
--       Name:   resend_api_key
--       Secret: re_xxxxxxxxxxxx   (your NEW key)
--
--  c) Sender address must be verified in Resend. A plain Gmail
--     address will NOT send. If you have no domain yet, change
--     sender_email below to:  onboarding@resend.dev

CREATE EXTENSION IF NOT EXISTS pg_net;

CREATE OR REPLACE FUNCTION send_booking_confirmation_email()
RETURNS TRIGGER AS $$
DECLARE
  treatment_title TEXT;
  resend_api_key  TEXT;
  sender_email    TEXT := 'onboarding@resend.dev';  -- ← change once you verify a domain
  formatted_date  TEXT;
  formatted_time  TEXT;
BEGIN
  SELECT decrypted_secret INTO resend_api_key
  FROM vault.decrypted_secrets
  WHERE name = 'resend_api_key';

  IF resend_api_key IS NULL THEN
    RAISE WARNING 'resend_api_key not found in Vault — booking confirmed but no email sent';
    RETURN NEW;
  END IF;

  SELECT title INTO treatment_title
  FROM treatments
  WHERE id = NEW.treatment_id;

  IF treatment_title IS NULL THEN
    treatment_title := 'Spa Treatment';
  END IF;

  formatted_date := to_char(NEW.booking_date, 'FMDay, FMDD FMMonth YYYY');
  formatted_time := to_char(NEW.start_time, 'HH12:MI AM');

  PERFORM net.http_post(
    url := 'https://api.resend.com/emails',
    headers := jsonb_build_object(
      'Authorization', 'Bearer ' || resend_api_key,
      'Content-Type', 'application/json'
    ),
    body := jsonb_build_object(
      'from', 'Oasis Spa <' || sender_email || '>',
      'to', ARRAY[NEW.customer_email],
      'subject', 'Booking Confirmed — Oasis Spa',
      'html', '<h2>Your Appointment is Confirmed!</h2>' ||
              '<p>Dear <strong>' || NEW.customer_name || '</strong>,</p>' ||
              '<p>Thank you for choosing Oasis Spa. We look forward to welcoming you.</p>' ||
              '<p><strong>Booking Details:</strong></p>' ||
              '<ul>' ||
              '  <li><strong>Service:</strong> ' || treatment_title || '</li>' ||
              '  <li><strong>Date:</strong> ' || formatted_date || '</li>' ||
              '  <li><strong>Time:</strong> ' || formatted_time || '</li>' ||
              '</ul>' ||
              '<p>To reschedule or cancel, please contact us at least 24 hours in advance.</p>' ||
              '<p>Best regards,<br>The Oasis Spa Team</p>'
    )
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER tr_on_booking_confirmed
  AFTER UPDATE ON bookings
  FOR EACH ROW
  WHEN (OLD.status = 'pending' AND NEW.status = 'confirmed')
  EXECUTE FUNCTION send_booking_confirmation_email();


-- =============================================================
-- PART 5 — Verify everything landed
-- =============================================================
-- Expect: scrub_type column present, trigger present.

SELECT 'scrub_type column' AS check_name,
       count(*)::text AS result
FROM information_schema.columns
WHERE table_name = 'bookings' AND column_name = 'scrub_type'

UNION ALL

SELECT 'email trigger',
       count(*)::text
FROM pg_trigger
WHERE tgname = 'tr_on_booking_confirmed'

UNION ALL

SELECT 'vault key set',
       count(*)::text
FROM vault.decrypted_secrets
WHERE name = 'resend_api_key';

-- All three should read 1.
-- If "vault key set" is 0, do PART 4 step (b) — bookings will still
-- work, you just won't get confirmation emails.


-- =============================================================
-- Troubleshooting: did an email actually send?
-- =============================================================
-- Emails send asynchronously. After approving a booking:
--
--   SELECT id, status_code, error_msg, created
--   FROM net._http_response
--   ORDER BY created DESC LIMIT 5;
--
--   200      = sent
--   401/403  = wrong or missing API key
--   422      = sender address not verified in Resend
