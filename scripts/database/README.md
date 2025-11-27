# MPR Soluciones - Database Setup Scripts

## 📋 Resumen

Esta carpeta contiene todos los scripts SQL necesarios para crear y configurar la base de datos PostgreSQL de MPR Soluciones en Supabase.

## 🚀 Setup Rápido (Recomendado)

### Opción 1: Setup Completo de Una Sola Vez

Para crear la base de datos completa desde cero:

1. Abre **Supabase Dashboard** → **SQL Editor**
2. Copia y pega el contenido completo de `COMPLETE_SETUP.sql`
3. Haz clic en **Run**
4. Espera a que termine (puede tomar 10-15 segundos)

**Esto creará:**
- 10 tablas
- 10 triggers de auditoría
- 5 funciones utilitarias
- 7 vistas
- Datos de prueba (3 usuarios, 3 empresas, 101 tipos de documentos, 11 configuraciones de obligaciones)

---

## 📁 Estructura de Carpetas

```
scripts/database/
├── 1_audit/                 → Sistema de auditoría
├── 2_users/                 → Tabla de usuarios
├── 3_companies/             → Empresas (con campos de asignación)
├── 4_document_types/        → 101 tipos de documentos
├── 5_input_documents/       → Documentos de entrada (del cliente)
├── 6_output_documents/      → Documentos de salida (del contador)
├── 7_legal_documents/       → Documentos legales
├── 8_monthly_obligations/   → Configuración de obligaciones
├── 9_functions/             → Funciones de generación de obligaciones
├── 10_views/                → 7 vistas del sistema
├── 11_notifications/        → Sistema de notificaciones
├── 12_required_inputs/      → Mapeo de inputs requeridos
├── COMPLETE_SETUP.sql       → ⭐ Setup completo todo-en-uno
├── VERIFICATION.sql         → Script de verificación
└── GENERATE_OBLIGATIONS.sql → Generador de obligaciones
```

---

## 🔧 Setup Modular (Paso a Paso)

Si prefieres ejecutar los scripts modulares en orden:

### Orden de Ejecución

```bash
# 1. Sistema de Auditoría
1_audit/01_create_audit_table.sql
1_audit/02_create_audit_function.sql

# 2. Usuarios
2_users/04_create_users_table.sql
2_users/05_attach_audit_users.sql
2_users/06_populate_users.sql

# 3. Empresas
3_companies/06_create_companies_table.sql
3_companies/07_attach_audit_companies.sql
3_companies/08_populate_companies.sql

# 4. Tipos de Documentos
4_document_types/08_create_document_types_table.sql
4_document_types/09_attach_audit_document_types.sql
4_document_types/10_populate_document_types.sql

# 5-7. Documentos (Input, Output, Legal)
5_input_documents/11_create_input_documents.sql
5_input_documents/12_attach_audit_input_documents.sql
5_input_documents/13_populate_input_documents.sql

6_output_documents/14_create_output_documents.sql
6_output_documents/15_attach_audit_output_documents.sql
6_output_documents/16_populate_output_documents.sql

7_legal_documents/17_create_legal_documents.sql
7_legal_documents/18_attach_audit_legal_documents.sql
7_legal_documents/19_populate_legal_documents.sql

# 8. Configuración de Obligaciones
8_monthly_obligations/20_create_monthly_obligations_config.sql
8_monthly_obligations/21_attach_audit_monthly_obligations_config.sql
8_monthly_obligations/22_populate_monthly_obligations_config.sql

# 9. Funciones de Obligaciones
9_functions/22_fn_generate_monthly_obligations.sql
9_functions/23_fn_regenerate_obligations.sql

# 10. Vistas
10_views/24_v_user_profiles.sql
10_views/25_v_company_documents_summary.sql
10_views/26_v_obligations_dashboard.sql
10_views/27_v_documents_pending_review.sql
10_views/28_v_document_relationships.sql
10_views/29_v_user_notifications.sql

# 11. Sistema de Notificaciones
11_notifications/31_create_notifications_table.sql
11_notifications/32_attach_audit_notifications.sql
11_notifications/33_create_notification_functions.sql
11_notifications/34_create_notification_triggers.sql

# 12. Mapeo de Inputs Requeridos
12_required_inputs/35_create_required_inputs_table.sql
12_required_inputs/36_attach_audit_required_inputs.sql
12_required_inputs/37_populate_required_inputs.sql
```

---

## ✅ Verificación del Setup

Después de ejecutar `COMPLETE_SETUP.sql`, verifica que todo esté correcto:

```bash
# En Supabase SQL Editor, ejecuta:
\i VERIFICATION.sql
```

O manualmente:

```sql
-- Verificar tablas
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE';

-- Verificar funciones
SELECT routine_name FROM information_schema.routines
WHERE routine_schema = 'public';

-- Verificar vistas
SELECT table_name FROM information_schema.views
WHERE table_schema = 'public';

-- Verificar datos
SELECT COUNT(*) FROM document_types;  -- Debe ser 101
SELECT COUNT(*) FROM users;            -- Debe ser 3
SELECT COUNT(*) FROM companies;        -- Debe ser 3
```

---

## 📊 Generar Obligaciones

Una vez la base de datos esté lista, genera las obligaciones mensuales:

```sql
-- Generar obligaciones para el mes actual (todas las empresas)
SELECT * FROM fn_generate_monthly_obligations();

-- Generar obligaciones para una empresa específica
SELECT * FROM fn_generate_monthly_obligations(1);  -- company_id = 1

-- Generar para un mes/año específico
SELECT * FROM fn_generate_monthly_obligations(NULL, 2025, 12);

-- Generar para todo el año 2025
SELECT *
FROM fn_generate_monthly_obligations(NULL, 2025, month)
CROSS JOIN generate_series(1, 12) as month;
```

Para más opciones, revisa `GENERATE_OBLIGATIONS.sql`.

---

## 🗄️ Estructura de la Base de Datos

### Tablas Principales (10)

1. **users** - Usuarios del sistema (cliente, contador, jefe, admin)
2. **companies** - Empresas/clientes
3. **document_types** - 101 tipos de documentos catalogados
4. **input_documents** - Documentos subidos por el cliente
5. **output_documents** - Documentos generados/entregados por el contador
6. **legal_documents** - Documentos legales con fechas de expiración
7. **monthly_obligations_config** - Configuración de obligaciones recurrentes
8. **notifications** - Notificaciones para usuarios
9. **output_required_inputs** - Mapeo de inputs requeridos para cada output
10. **audit_log** - Log de auditoría de todas las operaciones

### Vistas (7)

1. **v_user_profiles** - Perfiles de usuario con nombres completos
2. **v_company_documents_summary** - Resumen de documentos por empresa
3. **v_obligations_dashboard** - Dashboard de obligaciones con niveles de urgencia
4. **v_documents_pending_review** - Documentos y obligaciones próximos a vencer
5. **v_document_relationships** - Relaciones entre input y output documents
6. **v_document_relationships_detailed** - Relaciones detalladas con metadata
7. **v_user_notifications** - Notificaciones de usuario con contexto completo

### Funciones (5)

1. **fn_write_audit()** - Trigger function para auditoría automática
2. **fn_generate_monthly_obligations()** - Genera obligaciones mensuales/trimestrales/anuales
3. **fn_regenerate_obligations()** - Regenera obligaciones para un período específico
4. **fn_notify_obligation_status_change()** - Notifica cambios de estado en obligaciones
5. **fn_notify_new_obligation()** - Notifica cuando se crean nuevas obligaciones

---

## 🔐 Características de Seguridad

### Soft Delete
Todas las tablas principales tienen:
- `active BOOLEAN` - Flag para borrado lógico
- `deleted_at TIMESTAMPTZ` - Timestamp de borrado

### Auditoría Completa
Cada INSERT, UPDATE y DELETE en las tablas principales se registra en `audit_log` con:
- Datos antiguos (old_data)
- Datos nuevos (new_data)
- Usuario que ejecutó la acción
- Timestamp de la operación

### Notificaciones Automáticas
- Se crean notificaciones automáticas cuando:
  - Se crea una nueva obligación
  - Cambia el estado de una obligación
- Las notificaciones se envían a usuarios asignados (contador y cliente)

---

## 📝 Datos de Prueba

El setup incluye datos de prueba para desarrollo:

**Usuarios:**
- rachel@gmail.com (cliente)
- jose@gmail.com (jefe)
- mayerling@gmail.com (contador)

**Empresas:**
- Empresa Demo 1 C.A. (J-12345678-9)
- Soluciones Integrales S.R.L. (J-98765432-1)
- Rachel Graphics Studio (J-11223344-5)

**Obligaciones Configuradas:**
- Declaración IVA (mensual, día 15)
- Libro de Compras y Ventas (mensual, día 10)
- Retenciones IVA (mensual, día 15)
- Declaración ISLR (anual, día 31)
- Balance General (trimestral, día 30)

---

## 🛠️ Comandos Útiles

### Limpiar y Recrear la BD

```sql
-- ⚠️ PELIGRO: Esto BORRA TODO
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

-- Luego ejecuta COMPLETE_SETUP.sql de nuevo
```

### Ver Obligaciones Generadas

```sql
SELECT * FROM v_obligations_dashboard
ORDER BY urgency_level DESC, due_date ASC;
```

### Ver Notificaciones de un Usuario

```sql
SELECT * FROM v_user_notifications
WHERE user_id = 1
AND is_read = FALSE
ORDER BY created_at DESC;
```

### Regenerar Obligaciones (con borrado)

```sql
-- Regenera obligaciones de diciembre 2025 para empresa 1
SELECT * FROM fn_regenerate_obligations(1, 2025, 12, TRUE);
```

---

## 📚 Documentación Adicional

- **DATABASE_ROADMAP.md** - Plan de implementación y roadmap
- **HISTORY.md** - Historial de cambios
- **AI_GUIDELINES.md** - Guías para asistentes IA

---

## ❓ Preguntas Frecuentes

**Q: ¿Puedo ejecutar COMPLETE_SETUP.sql múltiples veces?**
A: Sí, usa `DROP TABLE IF EXISTS CASCADE` entonces es seguro re-ejecutarlo.

**Q: ¿Cómo agrego un nuevo tipo de documento?**
A: Inserta en la tabla `document_types`:
```sql
INSERT INTO document_types (category_type, sub_type, name, active)
VALUES ('output', 'reportes', 'nuevo reporte', TRUE);
```

**Q: ¿Cómo configuro una nueva obligación recurrente?**
A: Inserta en `monthly_obligations_config`:
```sql
INSERT INTO monthly_obligations_config
(company_id, document_type_id, frequency, due_day, enabled, notes)
VALUES (1, 50, 'monthly', 20, TRUE, 'Nueva obligación mensual');
```

**Q: ¿Los scripts están actualizados con las migraciones?**
A: Sí, todas las migraciones anteriores ya están integradas en los scripts base. No necesitas ejecutar migraciones por separado.

---

## 🆘 Soporte

Si encuentras problemas:
1. Ejecuta `VERIFICATION.sql` para diagnosticar
2. Revisa los logs de Supabase
3. Verifica que estés usando PostgreSQL 17.6+
4. Contacta al equipo de desarrollo

---

**Última actualización:** 2025-11-26
**Versión de la BD:** 1.0.0
