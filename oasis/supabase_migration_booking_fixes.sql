-- =============================================================
-- Oasis Spa – Booking fixes migration
-- Run in Supabase Dashboard → SQL Editor → New Query → Run
--
-- Safe to run more than once (every statement is idempotent).
-- =============================================================


-- -------------------------------------------------------------
-- 1. FIX: bookings fail to insert — missing scrub_type column
-- -------------------------------------------------------------
-- lib/services/supabase_service.dart:createBooking() sends a
-- 'scrub_type' field, and lib/pages/admin_page.dart reads it back,
-- but the column was never created. PostgREST rejects the whole
-- insert with:
--   column "scrub_type" of relation "bookings" does not exist
-- which is why no booking gets through.

ALTER TABLE bookings
  ADD COLUMN IF NOT EXISTS scrub_type TEXT;


-- -------------------------------------------------------------
-- 2. FIX: pending bookings did not reserve their slot
-- -------------------------------------------------------------
-- With admin approval, a booking sits in 'pending' until approved.
-- The availability RPC only returned 'confirmed' rows, so a slot
-- already awaiting approval still looked free. Two customers could
-- book the same room/time, and approving the second one would fail
-- against unique_booking_slot.
--
-- Pending bookings now hold their slot while awaiting approval.

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


-- -------------------------------------------------------------
-- 3. FIX: double-booking guard only covered confirmed rows
-- -------------------------------------------------------------
-- Matches the rule above at the database level, so a race between
-- two simultaneous customers cannot put two people in one room.

DROP INDEX IF EXISTS unique_booking_slot;

CREATE UNIQUE INDEX IF NOT EXISTS unique_booking_slot
  ON bookings (booking_date, start_time, room_number)
  WHERE status IN ('pending', 'confirmed');


-- -------------------------------------------------------------
-- 4. Confirmation email on admin approval
-- -------------------------------------------------------------
-- The trigger already exists in supabase_schema.sql and fires on
-- pending → confirmed. It needs the pg_net extension enabled:
--   Dashboard → Database → Extensions → enable "pg_net"
--
-- Verify it is installed by running:
--   SELECT tgname FROM pg_trigger WHERE tgname = 'tr_on_booking_confirmed';
--
-- SECURITY: the Resend API key is currently hard-coded in
-- supabase_schema.sql, which is committed to git. Rotate that key
-- and store the new one in Vault instead of inline SQL:
--   Dashboard → Project Settings → Vault → new secret 'resend_api_key'
-- then read it in the function with:
--   SELECT decrypted_secret INTO resend_api_key
--   FROM vault.decrypted_secrets WHERE name = 'resend_api_key';
