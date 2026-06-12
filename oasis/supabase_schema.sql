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
  status          TEXT NOT NULL DEFAULT 'confirmed' CHECK (status IN ('confirmed', 'cancelled')),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Prevent double-booking: same date + time + room
CREATE UNIQUE INDEX IF NOT EXISTS unique_booking_slot
  ON bookings (booking_date, start_time, room_number)
  WHERE status = 'confirmed';

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
  WITH CHECK (status = 'confirmed');

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
    AND b.status = 'confirmed';
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
