-- 08_populate_companies.sql
-- ============================================================
-- Description: Populates the companies table with test companies.
--              Uses the users created in 06_populate_users.sql.
-- ============================================================

INSERT INTO public.companies (
    name,
    tax_id,
    address,
    phone,
    email,
    created_by,
    active
) VALUES
-- Company 1 - Created by boss
(
    'empresa demo 1 c.a.',
    'j-12345678-9',
    'av. principal, caracas, venezuela',
    '+58-212-1234567',
    'contacto@empresademo1.com',
    (SELECT id FROM public.users WHERE email = 'mayerling.rodriguez@mprsoluciones.com' LIMIT 1),
    TRUE
),

-- Company 2 - Created by accountant
(
    'soluciones integrales s.r.l.',
    'j-98765432-1',
    'calle comercio, valencia, venezuela',
    '+58-241-9876543',
    'info@solucionesintegrales.com',
    (SELECT id FROM public.users WHERE email = 'joselayett@gmail.com' LIMIT 1),
    TRUE
),

-- Company 3 - Rachel's company (created by boss)
(
    'rachel graphics studio',
    'j-11223344-5',
    'centro empresarial, maracaibo, venezuela',
    '+58-261-1122334',
    'rachelgraphicss@gmail.com',
    (SELECT id FROM public.users WHERE email = 'mayerling.rodriguez@mprsoluciones.com' LIMIT 1),
    TRUE
);
