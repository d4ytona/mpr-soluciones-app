-- 06_populate_users.sql
-- ============================================================
-- Description: Populates the users table with test users.
--              These users correspond to existing Supabase Auth accounts.
-- ============================================================

INSERT INTO public.users (
    auth_id,
    first_name,
    last_name,
    email,
    phone,
    birth_date,
    id_type,
    id_number,
    role,
    profile_photo_url,
    active
) VALUES
-- Client user
(
    '949d2686-1940-4e48-b27b-a8f90abf11d8',
    'rachel',
    'solano',
    'rachelgraphicss@gmail.com',
    NULL,
    NULL,
    'v',
    12345678,
    'client',
    NULL,
    TRUE
),

-- Boss user
(
    'ab81d562-066a-4c73-96cd-79d8b9215e7b',
    'mayerling',
    'rodriguez',
    'mayerling.rodriguez@mprsoluciones.com',
    NULL,
    NULL,
    'v',
    23456789,
    'boss',
    'https://mprsoluciones.com/profile-picture/mayerling_profile-pic.jpg',
    TRUE
),

-- Accountant user
(
    'd9003b2b-571b-4bbf-b75d-2557b3e8d08c',
    'jose',
    'layett',
    'joselayett@gmail.com',
    NULL,
    NULL,
    'v',
    34567890,
    'accountant',
    'https://mprsoluciones.com/profile-picture/jose_profile-pic.jpg',
    TRUE
);
