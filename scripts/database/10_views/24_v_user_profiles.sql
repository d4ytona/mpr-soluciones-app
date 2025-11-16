-- 24_v_user_profiles.sql
-- ============================================================
-- Description: User profiles with formatted data for easy frontend consumption.
-- ============================================================

DROP VIEW IF EXISTS public.v_user_profiles CASCADE;

CREATE VIEW public.v_user_profiles AS
SELECT
    u.id,
    u.auth_id,
    u.first_name,
    u.last_name,
    u.first_name || ' ' || u.last_name as full_name,
    u.email,
    u.role,
    u.id_type,
    u.id_number,
    u.id_type || '-' || u.id_number as formatted_id,
    u.phone,
    u.birth_date,
    u.profile_photo_url,
    u.active,
    u.created_at,
    u.updated_at
FROM public.users u
WHERE u.active = TRUE;

-- Usage:
-- SELECT * FROM v_user_profiles;
-- SELECT * FROM v_user_profiles WHERE role = 'accountant';
