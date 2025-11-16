-- 16_populate_output_documents.sql
-- ============================================================
-- Description: Populates output_documents with test data using real document URLs.
--              Uses documents available at mprsoluciones.com.
-- ============================================================

-- Reference:
-- Company 1: empresa demo 1 c.a. (j-12345678-9)
-- Company 2: soluciones integrales s.r.l. (j-98765432-1)
-- Company 3: rachel graphics studio (j-11223344-5)
-- Accountant: jose layett (joselayett@gmail.com)

INSERT INTO public.output_documents (
    company_id,
    document_type_id,
    uploaded_by,
    file_url,
    notes,
    due_date,
    source_input_document_ids,
    period_year,
    period_month,
    obligation_status,
    auto_generated,
    active
) VALUES

-- ============================================================
-- BALANCE GENERAL (Balance Sheet)
-- ============================================================
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-12345678-9' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'output' AND sub_type = 'estados_financieros' AND name = 'balance general' LIMIT 1),
    (SELECT id FROM public.users WHERE email = 'joselayett@gmail.com' LIMIT 1),
    'https://mprsoluciones.com/output-documents/balance%20general.txt',
    'balance general del ejercicio fiscal 2024',
    '2025-03-31',
    NULL,  -- No source input documents yet
    2024,  -- Period year
    12,    -- Period month (December)
    'completed',  -- Already delivered
    FALSE, -- Manually created, not auto-generated
    TRUE
),
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-98765432-1' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'output' AND sub_type = 'estados_financieros' AND name = 'balance general' LIMIT 1),
    (SELECT id FROM public.users WHERE email = 'joselayett@gmail.com' LIMIT 1),
    'https://mprsoluciones.com/output-documents/balance%20general.txt',
    'balance general del ejercicio fiscal 2024',
    '2025-03-31',
    NULL,
    2024,
    12,
    'completed',
    FALSE,
    TRUE
),
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-11223344-5' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'output' AND sub_type = 'estados_financieros' AND name = 'balance general' LIMIT 1),
    (SELECT id FROM public.users WHERE email = 'joselayett@gmail.com' LIMIT 1),
    'https://mprsoluciones.com/output-documents/balance%20general.txt',
    'balance general del ejercicio fiscal 2024',
    '2025-03-31',
    NULL,
    2024,
    12,
    'completed',
    FALSE,
    TRUE
),

-- ============================================================
-- DECLARACIÓN ISLR (Income Tax Declaration)
-- ============================================================
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-12345678-9' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'output' AND sub_type = 'declaraciones_tributarias' AND name = 'declaracion islr' LIMIT 1),
    (SELECT id FROM public.users WHERE email = 'joselayett@gmail.com' LIMIT 1),
    'https://mprsoluciones.com/output-documents/declaracion%20islr.txt',
    'declaración de islr ejercicio fiscal 2024',
    '2025-03-31',
    NULL,
    2024,
    12,
    'completed',
    FALSE,
    TRUE
),
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-98765432-1' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'output' AND sub_type = 'declaraciones_tributarias' AND name = 'declaracion islr' LIMIT 1),
    (SELECT id FROM public.users WHERE email = 'joselayett@gmail.com' LIMIT 1),
    'https://mprsoluciones.com/output-documents/declaracion%20islr.txt',
    'declaración de islr ejercicio fiscal 2024',
    '2025-03-31',
    NULL,
    2024,
    12,
    'completed',
    FALSE,
    TRUE
),
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-11223344-5' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'output' AND sub_type = 'declaraciones_tributarias' AND name = 'declaracion islr' LIMIT 1),
    (SELECT id FROM public.users WHERE email = 'joselayett@gmail.com' LIMIT 1),
    'https://mprsoluciones.com/output-documents/declaracion%20islr.txt',
    'declaración de islr ejercicio fiscal 2024',
    '2025-03-31',
    NULL,
    2024,
    12,
    'completed',
    FALSE,
    TRUE
);
