-- 10_seed_document_types.sql
-- ============================================================
-- Description: Seeds all document types (legal, input, output).
-- ============================================================

INSERT INTO public.document_types (category_type, sub_type, name, active) VALUES
-- ============================================================
-- LEGAL DOCUMENTS
-- ============================================================

-- documentos de constitución
('legal', 'constitucion', 'rif', TRUE),
('legal', 'constitucion', 'documento constitutivo y estatutos', TRUE),
('legal', 'constitucion', 'actas de asamblea de accionistas', TRUE),
('legal', 'constitucion', 'licencia de actividades economicas', TRUE),
('legal', 'constitucion', 'patente de industria y comercio', TRUE),

-- representantes legales
('legal', 'representante_legal', 'cedula de identidad', TRUE),
('legal', 'representante_legal', 'rif personal', TRUE),
('legal', 'representante_legal', 'poder notariado', TRUE),

-- registros y autorizaciones
('legal', 'registros_y_autorizaciones', 'registro ivss', TRUE),
('legal', 'registros_y_autorizaciones', 'registro inces', TRUE),
('legal', 'registros_y_autorizaciones', 'registro faov', TRUE),
('legal', 'registros_y_autorizaciones', 'registro rupdae', TRUE),
('legal', 'registros_y_autorizaciones', 'registro rnet', TRUE),
('legal', 'registros_y_autorizaciones', 'autorizacion de libros contables', TRUE),
('legal', 'registros_y_autorizaciones', 'permiso sanitario', TRUE),
('legal', 'registros_y_autorizaciones', 'registro de importador', TRUE),
('legal', 'registros_y_autorizaciones', 'registro de exportador', TRUE),
('legal', 'registros_y_autorizaciones', 'certificaciones iso', TRUE),

-- documentos bancarios empresariales
('legal', 'bancarios', 'certificacion bancaria', TRUE),
('legal', 'bancarios', 'estados de cuenta bancarios', TRUE),
('legal', 'bancarios', 'firmas autorizadas', TRUE),
('legal', 'bancarios', 'poderes bancarios', TRUE),

-- ============================================================
-- INPUT DOCUMENTS (DOCUMENTOS DE ENTRADA)
-- ============================================================

-- ventas e ingresos
('input', 'ventas_e_ingresos', 'facturas emitidas', TRUE),
('input', 'ventas_e_ingresos', 'notas de debito emitidas', TRUE),
('input', 'ventas_e_ingresos', 'notas de credito emitidas', TRUE),
('input', 'ventas_e_ingresos', 'comprobantes de caja', TRUE),
('input', 'ventas_e_ingresos', 'depositos bancarios', TRUE),
('input', 'ventas_e_ingresos', 'retenciones recibidas', TRUE),
('input', 'ventas_e_ingresos', 'transferencias recibidas', TRUE),
('input', 'ventas_e_ingresos', 'pagos electronicos', TRUE),

-- compras y gastos
('input', 'compras_y_gastos', 'facturas de proveedores', TRUE),
('input', 'compras_y_gastos', 'notas de debito recibidas', TRUE),
('input', 'compras_y_gastos', 'notas de credito recibidas', TRUE),
('input', 'compras_y_gastos', 'recibos de servicios publicos', TRUE),
('input', 'compras_y_gastos', 'comprobantes de combustible', TRUE),
('input', 'compras_y_gastos', 'facturas de mantenimiento', TRUE),
('input', 'compras_y_gastos', 'comprobantes de alquiler', TRUE),
('input', 'compras_y_gastos', 'facturas de seguros', TRUE),
('input', 'compras_y_gastos', 'comprobantes de publicidad', TRUE),
('input', 'compras_y_gastos', 'facturas de papeleria', TRUE),
('input', 'compras_y_gastos', 'comprobantes de viaticos', TRUE),

-- nomina y personal
('input', 'nomina', 'recibos de pago de nomina', TRUE),
('input', 'nomina', 'aportes ivss', TRUE),
('input', 'nomina', 'aportes inces', TRUE),
('input', 'nomina', 'retenciones islr sueldos', TRUE),
('input', 'nomina', 'constancias de trabajo', TRUE),
('input', 'nomina', 'reposos medicos', TRUE),
('input', 'nomina', 'vacaciones y liquidaciones', TRUE),
('input', 'nomina', 'bonificaciones', TRUE),

-- bancarios y financieros
('input', 'bancarios_y_financieros', 'estados de cuenta', TRUE),
('input', 'bancarios_y_financieros', 'conciliaciones bancarias', TRUE),
('input', 'bancarios_y_financieros', 'intereses ganados', TRUE),
('input', 'bancarios_y_financieros', 'comisiones bancarias', TRUE),
('input', 'bancarios_y_financieros', 'prestamos', TRUE),
('input', 'bancarios_y_financieros', 'inversiones', TRUE),
('input', 'bancarios_y_financieros', 'cambio de divisas', TRUE),

-- inventarios y activos
('input', 'inventarios_y_activos', 'compra de inventario', TRUE),
('input', 'inventarios_y_activos', 'movimientos de almacen', TRUE),
('input', 'inventarios_y_activos', 'inventarios fisicos', TRUE),
('input', 'inventarios_y_activos', 'compra de activos fijos', TRUE),
('input', 'inventarios_y_activos', 'depreciacion', TRUE),
('input', 'inventarios_y_activos', 'bajas y ventas de activos', TRUE),

-- ============================================================
-- OUTPUT DOCUMENTS (DEL CONTADOR)
-- ============================================================

-- estados financieros
('output', 'estados_financieros', 'balance general', TRUE),
('output', 'estados_financieros', 'estado de resultados', TRUE),
('output', 'estados_financieros', 'estado de cambios en el patrimonio', TRUE),
('output', 'estados_financieros', 'estado de flujo de efectivo', TRUE),
('output', 'estados_financieros', 'notas a los estados financieros', TRUE),

-- libros contables
('output', 'libros_contables', 'libro diario', TRUE),
('output', 'libros_contables', 'libro mayor', TRUE),
('output', 'libros_contables', 'libro de inventarios', TRUE),
('output', 'libros_contables', 'libro de actas', TRUE),
('output', 'libros_contables', 'libro de accionistas', TRUE),

-- declaraciones tributarias
('output', 'declaraciones_tributarias', 'declaracion islr', TRUE),
('output', 'declaraciones_tributarias', 'retenciones islr', TRUE),
('output', 'declaraciones_tributarias', 'declaracion iva', TRUE),
('output', 'declaraciones_tributarias', 'retenciones iva', TRUE),
('output', 'declaraciones_tributarias', 'declaracion dpp', TRUE),
('output', 'declaraciones_tributarias', 'declaracion igft', TRUE),
('output', 'declaraciones_tributarias', 'declaracion igtp', TRUE),
('output', 'declaraciones_tributarias', 'declaracion actividades economicas', TRUE),
('output', 'declaraciones_tributarias', 'servicios municipales', TRUE),
('output', 'declaraciones_tributarias', 'retenciones municipales', TRUE),
('output', 'declaraciones_tributarias', 'libros de compras y ventas', TRUE),

-- declaraciones de personal
('output', 'declaraciones_personal', 'retenciones islr sueldos', TRUE),
('output', 'declaraciones_personal', 'aportes ivss', TRUE),
('output', 'declaraciones_personal', 'aportes inces', TRUE),
('output', 'declaraciones_personal', 'aportes faov', TRUE),
('output', 'declaraciones_personal', 'constancias de trabajo', TRUE),
('output', 'declaraciones_personal', 'certificaciones laborales', TRUE),

-- reportes y analisis
('output', 'reportes', 'conciliaciones bancarias', TRUE),
('output', 'reportes', 'cuentas por cobrar', TRUE),
('output', 'reportes', 'cuentas por pagar', TRUE),
('output', 'reportes', 'control de inventarios', TRUE),
('output', 'reportes', 'analisis de rentabilidad', TRUE),
('output', 'reportes', 'reportes de gestion financiera', TRUE),
('output', 'reportes', 'presupuestos y proyecciones', TRUE),

-- documentos regulatorios
('output', 'regulatorios', 'cierres contables', TRUE),
('output', 'regulatorios', 'informes de auditoria', TRUE),
('output', 'regulatorios', 'certificaciones contables', TRUE),
('output', 'regulatorios', 'constancias fiscales', TRUE),
('output', 'regulatorios', 'solvencias tributarias', TRUE);
