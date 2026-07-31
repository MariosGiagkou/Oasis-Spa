-- =============================================================
-- Oasis Spa – Database Schema
-- Run this in Supabase Dashboard → SQL Editor → New Query → Run
-- =============================================================

-- 1. Treatments table
CREATE TABLE IF NOT EXISTS treatments (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  title       TEXT NOT NULL,
  duration_minutes INTEGER NOT NULL,
  price_euros NUMERIC(6,2) NOT NULL,
  description TEXT NOT NULL DEFAULT ''
);

-- 2. Bookings table
CREATE TABLE IF NOT EXISTS bookings (
  id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_name   TEXT NOT NULL,
  customer_email  TEXT NOT NULL,
  treatment_id    BIGINT NOT NULL REFERENCES treatments(id),
  booking_date    DATE NOT NULL,
  start_time      TIME NOT NULL,
  end_time        TIME NOT NULL,
  room_number     INTEGER NOT NULL DEFAULT 1,
  status          TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled')),
  scrub_type      TEXT,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Prevent double-booking: same date + time + room.
-- Pending bookings hold their slot while awaiting admin approval.
CREATE UNIQUE INDEX IF NOT EXISTS unique_booking_slot
  ON bookings (booking_date, start_time, room_number)
  WHERE status IN ('pending', 'confirmed');

-- Grant permissions to standard Supabase roles so the PostgREST API can access them
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL ROUTINES IN SCHEMA public TO anon, authenticated, service_role;

-- 3. Row Level Security (secure access control)
ALTER TABLE treatments ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings   ENABLE ROW LEVEL SECURITY;

-- Anyone can read treatments
CREATE POLICY "Public read treatments"
  ON treatments FOR SELECT
  USING (true);

-- Only authenticated users (admins) can read bookings directly
CREATE POLICY "Admins can read all bookings"
  ON bookings FOR SELECT
  TO authenticated
  USING (true);

-- Allow public inserts so customers can book (only confirmed status)
CREATE POLICY "Public insert bookings"
  ON bookings FOR INSERT
  TO anon
  WITH CHECK (status = 'pending');

-- Allow admins full access to bookings
CREATE POLICY "Admins can insert bookings"
  ON bookings FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Admins can update bookings"
  ON bookings FOR UPDATE
  TO authenticated
  USING (true);

-- 4. Anonymized availability RPC function
CREATE OR REPLACE FUNCTION get_anonymized_bookings(target_date DATE)
RETURNS TABLE (
  start_time TIME,
  end_time TIME,
  room_number INTEGER
) 
SECURITY DEFINER -- Runs with database owner privileges
AS $$
BEGIN
  RETURN QUERY
  SELECT b.start_time, b.end_time, b.room_number
  FROM bookings b
  WHERE b.booking_date = target_date
    AND b.status IN ('pending', 'confirmed');
END;
$$ LANGUAGE plpgsql;

-- 5. Seed treatments from the spa menu
INSERT INTO treatments (title, duration_minutes, price_euros, description) VALUES
  ('Classic Relaxation Massage (60 min)', 60, 65.00,
   'Deeply relaxing full-body massage using nourishing jojoba oil.'),
  ('Classic Relaxation Massage (80 min)', 80, 85.00,
   'Extended deeply relaxing full-body massage using nourishing jojoba oil.'),
  ('Back Relief Massage', 45, 50.00,
   'Targeted treatment to ease tension in the upper body.'),
  ('Sport Massage', 60, 70.00,
   'Targeted treatment to relieve muscle tension and improve flexibility.'),
  ('Head Relaxation Massage', 30, 40.00,
   'Relaxing treatment focused on head, neck, and shoulders.'),
  ('Leg & Foot Relief Massage', 45, 50.00,
   'Soothing massage to relieve tired, swollen, and heavy legs.'),
  ('Foot Reflexology Ritual', 30, 40.00,
   'Targets specific pressure points on the feet to support balance.'),
  ('Oasis Salt Glow Ritual', 90, 110.00,
   'Exfoliating mineral-rich salt scrub and soothing massage.'),
  ('Oasis Salt Glow Scrub', 45, 55.00,
   'Mineral-rich salt exfoliation to smooth and brighten skin.'),
  ('Facial exfoliation ritual', 30, 40.00,
   'Revitalising facial exfoliation to smooth and brighten your skin.'),
  ('Facial Massage', 30, 40.00,
   'Gentle, soothing facial massage designed to restore your natural glow.'),
  ('Oasis Glow Ritual', 45, 55.00,
   'Exfoliating mineral-rich scrub followed by a relaxing body massage.'),
  ('Oasis Special Glow Ritual', 55, 65.00,
   'Our signature premium treatment for deep hydration and skin radiance.');

-- =============================================================
-- 6. Automatic Booking Confirmation Email Trigger (Resend integration)
-- =============================================================
-- Note: Enable the pg_net extension in your Supabase Dashboard first
-- (Database -> Extensions -> Enable pg_net)

CREATE EXTENSION IF NOT EXISTS pg_net;

CREATE OR REPLACE FUNCTION send_booking_confirmation_email()
RETURNS TRIGGER AS $$
DECLARE
  treatment_title TEXT;
  resend_api_key TEXT;
  sender_email TEXT := 'onboarding@resend.dev'; -- change once you verify a domain in Resend
  formatted_date TEXT;
  formatted_time TEXT;
BEGIN
  -- Never hard-code the API key here: this file is committed to git.
  -- Store it in Supabase Vault instead:
  --   Project Settings -> Vault -> Add new secret
  --     Name: resend_api_key
  SELECT decrypted_secret INTO resend_api_key
  FROM vault.decrypted_secrets
  WHERE name = 'resend_api_key';

  IF resend_api_key IS NULL THEN
    RAISE WARNING 'resend_api_key not found in Vault - booking confirmed but no email sent';
    RETURN NEW;
  END IF;

  -- Fetch the treatment title for the booked treatment
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
              '  <li><strong>Room/Personnel Assigned:</strong> Room ' || NEW.room_number || '</li>' ||
              '</ul>' ||
              '<p>If you need to reschedule or cancel your appointment, please contact us at least 24 hours in advance.</p>' ||
              '<p>Best regards,<br>The Oasis Spa Team</p>'
    )
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to run when a pending booking is officially confirmed by the admin
CREATE OR REPLACE TRIGGER tr_on_booking_confirmed
  AFTER UPDATE ON bookings
  FOR EACH ROW
  WHEN (OLD.status = 'pending' AND NEW.status = 'confirmed')
  EXECUTE FUNCTION send_booking_confirmation_email();
