-- =============================================================
-- Oasis Spa – Confirmation email on admin approval
--
-- Sends the customer an email the moment an admin changes a
-- booking from 'pending' to 'confirmed'.
--
-- HOW TO RUN:
--   Supabase Dashboard → SQL Editor → New query
--   → paste this whole file → Run
--
-- Safe to run more than once.
--
-- ⚠ DO NOT re-run supabase_schema.sql to get this — that file
--   ends with INSERT INTO treatments and would duplicate your
--   entire treatment menu.
-- =============================================================


-- -------------------------------------------------------------
-- STEP 1 — Is the trigger already installed?
-- -------------------------------------------------------------
-- Run just this line first. If it returns a row, you already
-- have it and can stop here. If it returns nothing, continue.

SELECT tgname AS installed_trigger
FROM pg_trigger
WHERE tgname = 'tr_on_booking_confirmed';


-- -------------------------------------------------------------
-- STEP 2 — Enable pg_net (lets Postgres make web requests)
-- -------------------------------------------------------------
-- Without this the trigger cannot reach Resend.
-- You can also enable it via Dashboard → Database → Extensions.

CREATE EXTENSION IF NOT EXISTS pg_net;


-- -------------------------------------------------------------
-- STEP 3 — Put your Resend API key in Vault (do this once)
-- -------------------------------------------------------------
-- ⚠ Your old key was committed to git in supabase_schema.sql.
--   Rotate it at https://resend.com/api-keys, then store the NEW
--   key here instead of pasting it into SQL.
--
--   Dashboard → Project Settings → Vault → Add new secret
--     Name:   resend_api_key
--     Secret: re_xxxxxxxxxxxxxxxxxxxx   (your new key)


-- -------------------------------------------------------------
-- STEP 4 — Create the email function
-- -------------------------------------------------------------

CREATE OR REPLACE FUNCTION send_booking_confirmation_email()
RETURNS TRIGGER AS $$
DECLARE
  treatment_title TEXT;
  resend_api_key  TEXT;
  sender_email    TEXT := 'Mariosyiangou99@gmail.com';  -- must be verified in Resend
  formatted_date  TEXT;
  formatted_time  TEXT;
BEGIN
  -- Read the key from Vault rather than hard-coding it
  SELECT decrypted_secret INTO resend_api_key
  FROM vault.decrypted_secrets
  WHERE name = 'resend_api_key';

  IF resend_api_key IS NULL THEN
    RAISE WARNING 'resend_api_key not found in Vault - no email sent';
    RETURN NEW;
  END IF;

  SELECT title INTO treatment_title
  FROM treatments
  WHERE id = NEW.treatment_id;

  IF treatment_title IS NULL THEN
    treatment_title := 'Spa Treatment';
  END IF;

  formatted_date := to_char(NEW.booking_date, 'Day, DD Month YYYY');
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
      'subject', 'Booking Confirmed - Oasis Spa',
      'html', '<h2>Your Appointment is Confirmed!</h2>' ||
              '<p>Dear <strong>' || NEW.customer_name || '</strong>,</p>' ||
              '<p>Thank you for choosing Oasis Spa. We are looking forward to welcoming you.</p>' ||
              '<p><strong>Booking Details:</strong></p>' ||
              '<ul>' ||
              '  <li><strong>Service:</strong> ' || treatment_title || '</li>' ||
              '  <li><strong>Date:</strong> ' || formatted_date || '</li>' ||
              '  <li><strong>Time:</strong> ' || formatted_time || '</li>' ||
              '</ul>' ||
              '<p>If you need to reschedule or cancel, please contact us at least 24 hours in advance.</p>' ||
              '<p>Best regards,<br>The Oasis Spa Team</p>'
    )
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- -------------------------------------------------------------
-- STEP 5 — Attach the trigger
-- -------------------------------------------------------------

CREATE OR REPLACE TRIGGER tr_on_booking_confirmed
  AFTER UPDATE ON bookings
  FOR EACH ROW
  WHEN (OLD.status = 'pending' AND NEW.status = 'confirmed')
  EXECUTE FUNCTION send_booking_confirmation_email();


-- -------------------------------------------------------------
-- STEP 6 — Confirm it worked
-- -------------------------------------------------------------
-- Should now return one row:

SELECT tgname AS installed_trigger
FROM pg_trigger
WHERE tgname = 'tr_on_booking_confirmed';


-- -------------------------------------------------------------
-- Troubleshooting: did the email actually send?
-- -------------------------------------------------------------
-- pg_net calls are asynchronous. After approving a booking, check:
--
--   SELECT id, status_code, error_msg, created
--   FROM net._http_response
--   ORDER BY created DESC
--   LIMIT 5;
--
-- status_code 200 = sent. 401/403 = bad or unrotated API key.
-- 422 = sender address not verified in Resend.
