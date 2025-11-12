-- 04_create_users_table.sql
-- ============================================================
-- Description: Stores user accounts with profile and identification info,
--              linked to Supabase Auth via auth_id.
-- ============================================================
DROP TABLE IF EXISTS public.users;

CREATE TABLE public.users (
    id BIGSERIAL PRIMARY KEY,                                                       -- Unique identifier
    auth_id UUID UNIQUE NOT NULL,                                                   -- UUID from Supabase Auth system
    first_name TEXT NOT NULL,                                                       -- User first name
    last_name TEXT NOT NULL,                                                        -- User last name
    email TEXT,                                                                     -- Optional contact email (not for authentication)
    phone TEXT,                                                                     -- Contact phone number
    birth_date DATE,                                                                -- Date of birth
    id_type TEXT NOT NULL CHECK (id_type IN ('v', 'e', 'p')),                       -- Venezuelan ID type: v=venezuelan, e=foreigner, p=passport
    id_number BIGINT NOT NULL,                                                      -- ID number (numeric only)
    role TEXT NOT NULL CHECK (role IN ('client', 'accountant', 'boss', 'admin')),   -- User role in the system
    profile_photo_url TEXT,                                                         -- Cloudflare R2 Storage URL for profile photo
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),                                  -- Record creation timestamp
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),                                  -- Last update timestamp
    active BOOLEAN NOT NULL DEFAULT TRUE,                                           -- Soft delete flag: TRUE = active, FALSE = deleted
    deleted_at TIMESTAMPTZ                                                          -- Timestamp when the record was soft deleted
);
