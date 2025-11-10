-- 04_create_users_table.sql
-- ============================================================
-- Description: Stores user accounts with profile and identification info,
--              linked to Supabase Auth via auth_id.
-- ============================================================
DROP TABLE IF EXISTS public.users
CREATE TABLE public.users (
    id BIGSERIAL PRIMARY KEY,                                                       -- Internal unique identifier
    auth_id UUID UNIQUE NOT NULL,                                                   -- UUID from Auth system (Supabase)
    first_name TEXT NOT NULL,                                                       -- User first name
    last_name TEXT NOT NULL,                                                        -- User last name
    email TEXT,                                                                     -- Optional contact email (not for login)
    phone TEXT,                                                                     -- Contact phone number
    birth_date DATE,                                                                -- Date of birth
    id_type TEXT NOT NULL CHECK (id_type IN ('V', 'E', 'P')),                       -- Type of Venezuelan ID (Venezuelan, Foreigner, Passport)
    id_number BIGINT NOT NULL,                                                      -- ID number, numeric only
    role TEXT NOT NULL CHECK (role IN ('client', 'accountant', 'boss', 'admin')),   -- Role of the user
    profile_photo_url TEXT,                                                         -- Link to profile photo (stored in R2)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),                              -- Record creation timestamp
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()                               -- Last update timestamp
    active BOOLEAN DEFAULT TRUE,                                                    -- Soft delete flag: TRUE = active, FALSE = deleted
    deleted_at TIMESTAMPTZ DEFAULT NULL                                             -- Timestamp when the record was soft deleted

);
