-- 19_populate_legal_documents.sql
-- ============================================================
-- Description: Populates legal_documents with test data using real document URLs.
--              Uses documents available at mprsoluciones.com.
-- ============================================================

-- Reference:
-- Company 1: empresa demo 1 c.a. (j-12345678-9)
-- Company 2: soluciones integrales s.r.l. (j-98765432-1)
-- Company 3: rachel graphics studio (j-11223344-5)

INSERT INTO public.legal_documents (
    company_id,
    document_type_id,
    file_url,
    expiration_date,
    active
) VALUES

-- ============================================================
-- RIF (Tax Identification)
-- ============================================================
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-12345678-9' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'legal' AND sub_type = 'constitucion' AND name = 'rif' LIMIT 1),
    'https://mprsoluciones.com/legal_documents/rif.txt',
    '2025-12-31',
    TRUE
),
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-98765432-1' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'legal' AND sub_type = 'constitucion' AND name = 'rif' LIMIT 1),
    'https://mprsoluciones.com/legal_documents/rif.txt',
    '2025-12-31',
    TRUE
),
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-11223344-5' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'legal' AND sub_type = 'constitucion' AND name = 'rif' LIMIT 1),
    'https://mprsoluciones.com/legal_documents/rif.txt',
    '2025-12-31',
    TRUE
),

-- ============================================================
-- CÉDULA DE IDENTIDAD (ID Card - Legal Representative)
-- ============================================================
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-12345678-9' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'legal' AND sub_type = 'representante_legal' AND name = 'cedula de identidad' LIMIT 1),
    'https://mprsoluciones.com/legal_documents/cedula%20de%20identidad.txt',
    NULL,
    TRUE
),
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-98765432-1' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'legal' AND sub_type = 'representante_legal' AND name = 'cedula de identidad' LIMIT 1),
    'https://mprsoluciones.com/legal_documents/cedula%20de%20identidad.txt',
    NULL,
    TRUE
),
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-11223344-5' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'legal' AND sub_type = 'representante_legal' AND name = 'cedula de identidad' LIMIT 1),
    'https://mprsoluciones.com/legal_documents/cedula%20de%20identidad.txt',
    NULL,
    TRUE
),

-- ============================================================
-- REGISTRO IVSS (Social Security Registration)
-- ============================================================
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-12345678-9' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'legal' AND sub_type = 'registros_y_autorizaciones' AND name = 'registro ivss' LIMIT 1),
    'https://mprsoluciones.com/legal_documents/registro%20ivss.txt',
    '2025-12-31',
    TRUE
),
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-98765432-1' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'legal' AND sub_type = 'registros_y_autorizaciones' AND name = 'registro ivss' LIMIT 1),
    'https://mprsoluciones.com/legal_documents/registro%20ivss.txt',
    '2025-12-31',
    TRUE
),
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-11223344-5' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'legal' AND sub_type = 'registros_y_autorizaciones' AND name = 'registro ivss' LIMIT 1),
    'https://mprsoluciones.com/legal_documents/registro%20ivss.txt',
    '2025-12-31',
    TRUE
);
