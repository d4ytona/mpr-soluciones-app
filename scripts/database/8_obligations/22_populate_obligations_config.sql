-- 22_populate_obligations_config.sql
-- ============================================================
-- Description: Configures ALL possible obligations for all companies.
--              Only IVA and ISLR are enabled=TRUE as examples.
--              Others can be enabled later as needed.
-- ============================================================

-- Reference:
-- Company 1: empresa demo 1 c.a. (j-12345678-9)
-- Company 2: soluciones integrales s.r.l. (j-98765432-1)
-- Company 3: rachel graphics studio (j-11223344-5)

-- ============================================================
-- EMPRESA DEMO 1 C.A. - Obligaciones
-- ============================================================

INSERT INTO public.obligations_config (company_id, document_type_id, frequency, due_day, enabled, notes, active) VALUES

-- DECLARACIONES TRIBUTARIAS (enabled: solo IVA e ISLR)
((SELECT id FROM public.companies WHERE tax_id = 'j-12345678-9' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'declaracion iva' AND category_type = 'output' LIMIT 1), 'monthly', 15, TRUE, 'ENABLED - Declaración mensual de IVA', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-12345678-9' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'declaracion islr' AND category_type = 'output' LIMIT 1), 'annual', 31, TRUE, 'ENABLED - Declaración anual de ISLR', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-12345678-9' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'retenciones iva' AND category_type = 'output' LIMIT 1), 'monthly', 15, FALSE, 'Retenciones mensuales de IVA', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-12345678-9' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'retenciones islr' AND category_type = 'output' LIMIT 1), 'monthly', 15, FALSE, 'Retenciones mensuales de ISLR', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-12345678-9' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'libros de compras y ventas' AND category_type = 'output' LIMIT 1), 'monthly', 10, FALSE, 'Libro mensual de compras y ventas', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-12345678-9' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'declaracion actividades economicas' AND category_type = 'output' LIMIT 1), 'monthly', 25, FALSE, 'Declaración municipal de actividades económicas', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-12345678-9' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'servicios municipales' AND category_type = 'output' LIMIT 1), 'monthly', 25, FALSE, 'Pago de servicios municipales', TRUE),

-- DECLARACIONES DE PERSONAL
((SELECT id FROM public.companies WHERE tax_id = 'j-12345678-9' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'aportes ivss' AND category_type = 'output' LIMIT 1), 'monthly', 20, FALSE, 'Aportes mensuales IVSS', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-12345678-9' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'aportes inces' AND category_type = 'output' LIMIT 1), 'monthly', 20, FALSE, 'Aportes mensuales INCES', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-12345678-9' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'aportes faov' AND category_type = 'output' LIMIT 1), 'monthly', 20, FALSE, 'Aportes mensuales FAOV', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-12345678-9' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'retenciones islr sueldos' AND category_type = 'output' LIMIT 1), 'monthly', 15, FALSE, 'Retenciones ISLR sobre sueldos', TRUE),

-- ESTADOS FINANCIEROS
((SELECT id FROM public.companies WHERE tax_id = 'j-12345678-9' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'balance general' AND category_type = 'output' LIMIT 1), 'quarterly', 30, FALSE, 'Balance general trimestral', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-12345678-9' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'estado de resultados' AND category_type = 'output' LIMIT 1), 'quarterly', 30, FALSE, 'Estado de resultados trimestral', TRUE),

-- ============================================================
-- SOLUCIONES INTEGRALES S.R.L. - Obligaciones
-- ============================================================

((SELECT id FROM public.companies WHERE tax_id = 'j-98765432-1' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'declaracion iva' AND category_type = 'output' LIMIT 1), 'monthly', 15, TRUE, 'ENABLED - Declaración mensual de IVA', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-98765432-1' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'declaracion islr' AND category_type = 'output' LIMIT 1), 'annual', 31, TRUE, 'ENABLED - Declaración anual de ISLR', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-98765432-1' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'retenciones iva' AND category_type = 'output' LIMIT 1), 'monthly', 15, FALSE, 'Retenciones mensuales de IVA', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-98765432-1' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'retenciones islr' AND category_type = 'output' LIMIT 1), 'monthly', 15, FALSE, 'Retenciones mensuales de ISLR', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-98765432-1' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'libros de compras y ventas' AND category_type = 'output' LIMIT 1), 'monthly', 10, FALSE, 'Libro mensual de compras y ventas', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-98765432-1' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'declaracion actividades economicas' AND category_type = 'output' LIMIT 1), 'monthly', 25, FALSE, 'Declaración municipal de actividades económicas', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-98765432-1' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'aportes ivss' AND category_type = 'output' LIMIT 1), 'monthly', 20, FALSE, 'Aportes mensuales IVSS', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-98765432-1' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'aportes inces' AND category_type = 'output' LIMIT 1), 'monthly', 20, FALSE, 'Aportes mensuales INCES', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-98765432-1' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'balance general' AND category_type = 'output' LIMIT 1), 'quarterly', 30, FALSE, 'Balance general trimestral', TRUE),

-- ============================================================
-- RACHEL GRAPHICS STUDIO - Obligaciones
-- ============================================================

((SELECT id FROM public.companies WHERE tax_id = 'j-11223344-5' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'declaracion iva' AND category_type = 'output' LIMIT 1), 'monthly', 15, TRUE, 'ENABLED - Declaración mensual de IVA', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-11223344-5' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'declaracion islr' AND category_type = 'output' LIMIT 1), 'annual', 31, TRUE, 'ENABLED - Declaración anual de ISLR', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-11223344-5' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'retenciones iva' AND category_type = 'output' LIMIT 1), 'monthly', 15, FALSE, 'Retenciones mensuales de IVA', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-11223344-5' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'retenciones islr' AND category_type = 'output' LIMIT 1), 'monthly', 15, FALSE, 'Retenciones mensuales de ISLR', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-11223344-5' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'libros de compras y ventas' AND category_type = 'output' LIMIT 1), 'monthly', 10, FALSE, 'Libro mensual de compras y ventas', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-11223344-5' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'declaracion actividades economicas' AND category_type = 'output' LIMIT 1), 'monthly', 25, FALSE, 'Declaración municipal de actividades económicas', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-11223344-5' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'aportes ivss' AND category_type = 'output' LIMIT 1), 'monthly', 20, FALSE, 'Aportes mensuales IVSS', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-11223344-5' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'aportes inces' AND category_type = 'output' LIMIT 1), 'monthly', 20, FALSE, 'Aportes mensuales INCES', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-11223344-5' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'aportes faov' AND category_type = 'output' LIMIT 1), 'monthly', 20, FALSE, 'Aportes mensuales FAOV', TRUE),
((SELECT id FROM public.companies WHERE tax_id = 'j-11223344-5' LIMIT 1), (SELECT id FROM public.document_types WHERE name = 'balance general' AND category_type = 'output' LIMIT 1), 'quarterly', 30, FALSE, 'Balance general trimestral', TRUE);
