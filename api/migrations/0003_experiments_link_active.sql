-- Adds two columns to experiment_cards:
--   link       — optional external URL rendered on the public card. Empty = no link.
--   is_active  — admin-controlled visibility flag. Public /api/site filters
--                to is_active = TRUE; admin /api/admin/experiments returns all rows.

ALTER TABLE experiment_cards
    ADD COLUMN IF NOT EXISTS link      TEXT    NOT NULL DEFAULT '';

ALTER TABLE experiment_cards
    ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE;
