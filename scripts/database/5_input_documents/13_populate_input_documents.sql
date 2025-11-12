-- 13_populate_input_documents.sql
-- ============================================================
-- Description: Populates input_documents with test data using real document URLs.
--              Uses documents available at mprsoluciones.com.
-- ============================================================

-- Reference:
-- Company 1: empresa demo 1 c.a. (j-12345678-9)
-- Company 2: soluciones integrales s.r.l. (j-98765432-1)
-- Company 3: rachel graphics studio (j-11223344-5)

INSERT INTO public.input_documents (
    company_id,
    document_type_id,
    title,
    file_url,
    active
) VALUES

-- ============================================================
-- FACTURAS EMITIDAS (Issued Invoices)
-- ============================================================
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-12345678-9' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'input' AND sub_type = 'ventas_e_ingresos' AND name = 'facturas emitidas' LIMIT 1),
    'factura emitida - empresa demo 1',
    'https://mprsoluciones.com/input-documents/facturas%20emitidas.txt',
    TRUE
),
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-98765432-1' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'input' AND sub_type = 'ventas_e_ingresos' AND name = 'facturas emitidas' LIMIT 1),
    'factura emitida - soluciones integrales',
    'https://mprsoluciones.com/input-documents/facturas%20emitidas.txt',
    TRUE
),
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-11223344-5' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'input' AND sub_type = 'ventas_e_ingresos' AND name = 'facturas emitidas' LIMIT 1),
    'factura emitida - rachel graphics',
    'https://mprsoluciones.com/input-documents/facturas%20emitidas.txt',
    TRUE
),

-- ============================================================
-- FACTURAS DE PROVEEDORES (Supplier Invoices)
-- ============================================================
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-12345678-9' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'input' AND sub_type = 'compras_y_gastos' AND name = 'facturas de proveedores' LIMIT 1),
    'factura proveedor - empresa demo 1',
    'https://mprsoluciones.com/input-documents/facturas%20de%20proveedores.txt',
    TRUE
),
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-98765432-1' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'input' AND sub_type = 'compras_y_gastos' AND name = 'facturas de proveedores' LIMIT 1),
    'factura proveedor - soluciones integrales',
    'https://mprsoluciones.com/input-documents/facturas%20de%20proveedores.txt',
    TRUE
),
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-11223344-5' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'input' AND sub_type = 'compras_y_gastos' AND name = 'facturas de proveedores' LIMIT 1),
    'factura proveedor - rachel graphics',
    'https://mprsoluciones.com/input-documents/facturas%20de%20proveedores.txt',
    TRUE
),

-- ============================================================
-- RECIBOS DE PAGO DE NÓMINA (Payroll Receipts)
-- ============================================================
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-12345678-9' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'input' AND sub_type = 'nomina' AND name = 'recibos de pago de nomina' LIMIT 1),
    'recibo de nómina - empresa demo 1',
    'https://mprsoluciones.com/input-documents/recibos%20de%20pago%20de%20nomina.txt',
    TRUE
),
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-98765432-1' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'input' AND sub_type = 'nomina' AND name = 'recibos de pago de nomina' LIMIT 1),
    'recibo de nómina - soluciones integrales',
    'https://mprsoluciones.com/input-documents/recibos%20de%20pago%20de%20nomina.txt',
    TRUE
),
(
    (SELECT id FROM public.companies WHERE tax_id = 'j-11223344-5' LIMIT 1),
    (SELECT id FROM public.document_types WHERE category_type = 'input' AND sub_type = 'nomina' AND name = 'recibos de pago de nomina' LIMIT 1),
    'recibo de nómina - rachel graphics',
    'https://mprsoluciones.com/input-documents/recibos%20de%20pago%20de%20nomina.txt',
    TRUE
);
