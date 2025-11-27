-- 37_populate_required_inputs.sql
-- ============================================================
-- Description: Populates common requirement mappings between
--              output documents (obligations) and input documents.
-- ============================================================

-- ============================================================
-- Helper function to get document type ID
-- ============================================================
CREATE OR REPLACE FUNCTION get_doc_type_id(
    p_category VARCHAR,
    p_sub_type VARCHAR,
    p_name TEXT
) RETURNS BIGINT AS $$
BEGIN
    RETURN (
        SELECT id FROM public.document_types
        WHERE category_type = p_category
        AND sub_type = p_sub_type
        AND name = p_name
        LIMIT 1
    );
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- DECLARACIÓN IVA - Required Inputs
-- ============================================================
INSERT INTO public.output_required_inputs (
    output_document_type_id,
    required_input_document_type_id,
    is_mandatory,
    notes
) VALUES
-- Facturas emitidas (ventas)
(
    get_doc_type_id('output', 'declaraciones_tributarias', 'declaracion iva'),
    get_doc_type_id('input', 'ventas_e_ingresos', 'facturas emitidas'),
    TRUE,
    'Facturas de ventas del período'
),
-- Facturas de proveedores (compras)
(
    get_doc_type_id('output', 'declaraciones_tributarias', 'declaracion iva'),
    get_doc_type_id('input', 'compras_y_gastos', 'facturas de proveedores'),
    TRUE,
    'Facturas de compras del período'
),
-- Notas de crédito emitidas
(
    get_doc_type_id('output', 'declaraciones_tributarias', 'declaracion iva'),
    get_doc_type_id('input', 'ventas_e_ingresos', 'notas de credito emitidas'),
    FALSE,
    'Notas de crédito del período (si aplica)'
),
-- Notas de débito emitidas
(
    get_doc_type_id('output', 'declaraciones_tributarias', 'declaracion iva'),
    get_doc_type_id('input', 'ventas_e_ingresos', 'notas de debito emitidas'),
    FALSE,
    'Notas de débito del período (si aplica)'
);

-- ============================================================
-- LIBRO DE COMPRAS Y VENTAS - Required Inputs
-- ============================================================
INSERT INTO public.output_required_inputs (
    output_document_type_id,
    required_input_document_type_id,
    is_mandatory,
    notes
) VALUES
-- Facturas emitidas
(
    get_doc_type_id('output', 'libros_contables', 'libro de compras y ventas'),
    get_doc_type_id('input', 'ventas_e_ingresos', 'facturas emitidas'),
    TRUE,
    'Todas las facturas de ventas'
),
-- Facturas de proveedores
(
    get_doc_type_id('output', 'libros_contables', 'libro de compras y ventas'),
    get_doc_type_id('input', 'compras_y_gastos', 'facturas de proveedores'),
    TRUE,
    'Todas las facturas de compras'
);

-- ============================================================
-- RETENCIONES IVA - Required Inputs
-- ============================================================
INSERT INTO public.output_required_inputs (
    output_document_type_id,
    required_input_document_type_id,
    is_mandatory,
    notes
) VALUES
-- Facturas de proveedores (para retenciones practicadas)
(
    get_doc_type_id('output', 'declaraciones_tributarias', 'retenciones iva'),
    get_doc_type_id('input', 'compras_y_gastos', 'facturas de proveedores'),
    TRUE,
    'Facturas sobre las que se practicaron retenciones'
),
-- Retenciones recibidas
(
    get_doc_type_id('output', 'declaraciones_tributarias', 'retenciones iva'),
    get_doc_type_id('input', 'ventas_e_ingresos', 'retenciones recibidas'),
    FALSE,
    'Comprobantes de retenciones recibidas (si aplica)'
);

-- ============================================================
-- DECLARACIÓN ISLR - Required Inputs
-- ============================================================
INSERT INTO public.output_required_inputs (
    output_document_type_id,
    required_input_document_type_id,
    is_mandatory,
    notes
) VALUES
-- Estados financieros (Balance General)
(
    get_doc_type_id('output', 'declaraciones_tributarias', 'declaracion islr'),
    get_doc_type_id('output', 'estados_financieros', 'balance general'),
    TRUE,
    'Balance General del ejercicio fiscal'
),
-- Facturas emitidas
(
    get_doc_type_id('output', 'declaraciones_tributarias', 'declaracion islr'),
    get_doc_type_id('input', 'ventas_e_ingresos', 'facturas emitidas'),
    TRUE,
    'Todas las facturas de ventas del año fiscal'
),
-- Facturas de proveedores
(
    get_doc_type_id('output', 'declaraciones_tributarias', 'declaracion islr'),
    get_doc_type_id('input', 'compras_y_gastos', 'facturas de proveedores'),
    TRUE,
    'Todas las facturas de compras del año fiscal'
),
-- Nómina
(
    get_doc_type_id('output', 'declaraciones_tributarias', 'declaracion islr'),
    get_doc_type_id('input', 'nomina', 'recibos de pago de nomina'),
    TRUE,
    'Nómina del año fiscal'
);

-- ============================================================
-- BALANCE GENERAL - Required Inputs
-- ============================================================
INSERT INTO public.output_required_inputs (
    output_document_type_id,
    required_input_document_type_id,
    is_mandatory,
    notes
) VALUES
-- Estados de cuenta bancarios
(
    get_doc_type_id('output', 'estados_financieros', 'balance general'),
    get_doc_type_id('input', 'bancarios_y_financieros', 'estados de cuenta'),
    TRUE,
    'Estados de cuenta del período'
),
-- Conciliaciones bancarias
(
    get_doc_type_id('output', 'estados_financieros', 'balance general'),
    get_doc_type_id('input', 'bancarios_y_financieros', 'conciliaciones bancarias'),
    TRUE,
    'Conciliaciones bancarias del período'
),
-- Inventarios físicos
(
    get_doc_type_id('output', 'estados_financieros', 'balance general'),
    get_doc_type_id('input', 'inventarios_y_activos', 'inventarios fisicos'),
    FALSE,
    'Inventario físico (si aplica)'
);

-- Drop helper function
DROP FUNCTION get_doc_type_id(VARCHAR, VARCHAR, TEXT);
