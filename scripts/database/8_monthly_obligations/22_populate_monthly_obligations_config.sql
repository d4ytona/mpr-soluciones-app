-- 22_populate_monthly_obligations_config.sql
-- ============================================================
-- Description: Configures automatic obligation generation for all companies.
-- ============================================================

-- Reference:
-- Company 1: empresa demo 1 c.a. (j-12345678-9)
-- Company 2: soluciones integrales s.r.l. (j-98765432-1)
-- Company 3: rachel graphics studio (j-11223344-5)

INSERT INTO public.monthly_obligations_config (
    company_id,
    document_type_id,
    frequency,
    due_day,
    enabled,
    notes,
    active
) VALUES

-- ============================================================
-- EMPRESA DEMO 1 C.A. - Obligaciones
-- ============================================================

-- Declaración IVA (Monthly, due 15th)
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-12345678-9' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'output' AND sub_type = 'declaraciones_tributarias' AND name = 'declaracion iva' LIMIT 1),
    'monthly',
    15,
    TRUE,
    'declaracion mensual de iva',
    TRUE
),

-- Libro de Compras y Ventas (Monthly, due 10th)
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-12345678-9' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'output' AND sub_type = 'libros_contables' AND name = 'libro de compras y ventas' LIMIT 1),
    'monthly',
    10,
    TRUE,
    'libro mensual de compras y ventas',
    TRUE
),

-- Retenciones IVA (Monthly, due 15th)
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-12345678-9' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'output' AND sub_type = 'declaraciones_tributarias' AND name = 'retenciones iva' LIMIT 1),
    'monthly',
    15,
    TRUE,
    'declaracion mensual de retenciones de iva',
    TRUE
),

-- Declaración ISLR (Annual, due March 31st)
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-12345678-9' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'output' AND sub_type = 'declaraciones_tributarias' AND name = 'declaracion islr' LIMIT 1),
    'annual',
    31,
    TRUE,
    'declaracion anual de islr, vence 31 de marzo',
    TRUE
),

-- ============================================================
-- SOLUCIONES INTEGRALES S.R.L. - Obligaciones
-- ============================================================

-- Declaración IVA (Monthly, due 15th)
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-98765432-1' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'output' AND sub_type = 'declaraciones_tributarias' AND name = 'declaracion iva' LIMIT 1),
    'monthly',
    15,
    TRUE,
    'declaracion mensual de iva',
    TRUE
),

-- Libro de Compras y Ventas (Monthly, due 10th)
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-98765432-1' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'output' AND sub_type = 'libros_contables' AND name = 'libro de compras y ventas' LIMIT 1),
    'monthly',
    10,
    TRUE,
    'libro mensual de compras y ventas',
    TRUE
),

-- Declaración ISLR (Annual, due March 31st)
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-98765432-1' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'output' AND sub_type = 'declaraciones_tributarias' AND name = 'declaracion islr' LIMIT 1),
    'annual',
    31,
    TRUE,
    'declaracion anual de islr, vence 31 de marzo',
    TRUE
),

-- ============================================================
-- RACHEL GRAPHICS STUDIO - Obligaciones
-- ============================================================

-- Declaración IVA (Monthly, due 15th)
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-11223344-5' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'output' AND sub_type = 'declaraciones_tributarias' AND name = 'declaracion iva' LIMIT 1),
    'monthly',
    15,
    TRUE,
    'declaracion mensual de iva',
    TRUE
),

-- Libro de Compras y Ventas (Monthly, due 10th)
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-11223344-5' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'output' AND sub_type = 'libros_contables' AND name = 'libro de compras y ventas' LIMIT 1),
    'monthly',
    10,
    TRUE,
    'libro mensual de compras y ventas',
    TRUE
),

-- Retenciones IVA (Monthly, due 15th)
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-11223344-5' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'output' AND sub_type = 'declaraciones_tributarias' AND name = 'retenciones iva' LIMIT 1),
    'monthly',
    15,
    TRUE,
    'declaracion mensual de retenciones de iva',
    TRUE
),

-- Balance General (Quarterly, due last day of quarter)
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-11223344-5' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'output' AND sub_type = 'estados_financieros' AND name = 'balance general' LIMIT 1),
    'quarterly',
    30,
    TRUE,
    'balance general trimestral',
    TRUE
);
