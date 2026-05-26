ALTER TABLE waitlist
  ADD COLUMN IF NOT EXISTS interests text[] NULL;
