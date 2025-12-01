# Sistema de Notificaciones Automáticas - MPR Soluciones

## 🎯 Objetivo

Enviar notificaciones automáticas a los usuarios sobre obligaciones próximas a vencer, con diferentes niveles de urgencia según el tiempo restante.

---

## 📋 Cómo Funciona el Sistema

### Timeline de Notificaciones

Para cada obligación pendiente, se generan notificaciones en los siguientes momentos:

| Momento | Tipo de Notificación | Frecuencia | Icono |
|---------|---------------------|------------|-------|
| **Al crear obligación** | `new_obligation` | Una vez (trigger DB) | 📄 |
| **15 días antes** | `reminder_15_days` | Una vez | ⏰ |
| **7 días antes** | `reminder_7_days` | Una vez | ⚠️ |
| **Últimos 3 días** | `reminder_urgent` | 3 veces al día (9am, 3pm, 9pm) | 🚨 |
| **Al cambiar estado** | `status_change` | Cada cambio (trigger DB) | 🔄 |

---

## 🔧 Componentes del Sistema

### 1. Base de Datos

#### Tabla: `notifications`

```sql
CREATE TABLE public.notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    obligation_id BIGINT,
    company_id BIGINT,
    notification_type VARCHAR(50) NOT NULL,  -- Clave para evitar duplicados
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    deleted_at TIMESTAMPTZ
);
```

**Tipos de Notificación:**
- `new_obligation` - Nueva obligación creada
- `reminder_15_days` - Recordatorio 15 días antes
- `reminder_7_days` - Recordatorio 7 días antes
- `reminder_urgent` - Últimos 3 días (urgente)
- `status_change` - Cambio de estado

#### Función: `fn_check_and_notify_pending_obligations()`

**Ubicación:** `scripts/database/11_notifications/35_fn_check_and_notify_pending_obligations.sql`

**Qué hace:**

1. Busca todas las obligaciones con `status = 'pending'` y `due_date >= hoy`
2. Calcula días restantes hasta vencimiento para cada una
3. Determina qué tipo de notificación crear:
   - **14-16 días**: Notificación de 15 días (con tolerancia de ±1 día)
   - **6-8 días**: Notificación de 7 días (con tolerancia de ±1 día)
   - **0-3 días**: Notificación urgente (siempre se crea, 3x diarias)
4. Verifica si la notificación ya existe (excepto urgentes)
5. Crea notificaciones para:
   - `assigned_to` (responsable principal)
   - `assigned_accountant` (si es diferente del responsable)

**Retorna:**

```json
{
  "notifications_created": 5,
  "obligations_checked": 12,
  "details": [
    {
      "obligation_id": 123,
      "company_name": "Empresa Demo C.A.",
      "document_name": "IVA",
      "days_until_due": 7,
      "due_date": "2025-12-15",
      "notification_type": "reminder_7_days"
    }
  ]
}
```

---

### 2. Vercel Cron Jobs

#### Endpoint: `/api/cron/check-notifications`

**Ubicación:** `app/api/cron/check-notifications+api.ts`

**Frecuencia:** 3 veces al día

| Horario | Cron Expression | Descripción |
|---------|----------------|-------------|
| 9:00 AM UTC | `0 9 * * *` | Chequeo matutino |
| 3:00 PM UTC | `0 15 * * *` | Chequeo vespertino |
| 9:00 PM UTC | `0 21 * * *` | Chequeo nocturno |

**Proceso:**

1. Verifica autenticación con `CRON_SECRET`
2. Conecta a Supabase con Service Role Key
3. Llama a `fn_check_and_notify_pending_obligations()`
4. Registra resultados en logs
5. Retorna resumen de ejecución

**Respuesta de ejemplo:**

```json
{
  "success": true,
  "timestamp": "2025-11-30T09:00:00.000Z",
  "execution_hour": 9,
  "summary": {
    "notifications_created": 5,
    "obligations_checked": 12,
    "notifications_sent": 5
  },
  "details": [...]
}
```

---

### 3. Configuración en `vercel.json`

```json
{
  "crons": [
    {
      "path": "/api/cron/generate-obligations",
      "schedule": "0 0 1 * *"
    },
    {
      "path": "/api/cron/check-notifications",
      "schedule": "0 9 * * *"
    },
    {
      "path": "/api/cron/check-notifications",
      "schedule": "0 15 * * *"
    },
    {
      "path": "/api/cron/check-notifications",
      "schedule": "0 21 * * *"
    }
  ]
}
```

---

## ⚙️ Configuración y Deploy

### 1. Variables de Entorno

En Vercel Dashboard → Settings → Environment Variables:

| Variable | Valor | Descripción |
|----------|-------|-------------|
| `EXPO_PUBLIC_SUPABASE_URL` | `https://ybcroxxtnaqzbfepnchp.supabase.co` | URL de Supabase |
| `SUPABASE_SERVICE_ROLE_KEY` | `eyJhbGci...` | Service Role Key |
| `CRON_SECRET` | `[generado]` | Token de seguridad |

**Generar CRON_SECRET:**

```bash
openssl rand -base64 32
```

### 2. Deploy a Vercel

```bash
# Deploy a producción
vercel --prod

# Vercel detectará automáticamente los 4 cron jobs configurados
```

### 3. Verificar en Vercel Dashboard

**Vercel Dashboard → Tu Proyecto → Cron Jobs**

Deberías ver:
- ✅ `/api/cron/generate-obligations` - Día 1 de cada mes a las 00:00
- ✅ `/api/cron/check-notifications` - Diariamente a las 09:00
- ✅ `/api/cron/check-notifications` - Diariamente a las 15:00
- ✅ `/api/cron/check-notifications` - Diariamente a las 21:00

---

## 🧪 Testing

### Opción 1: Test Manual con cURL

```bash
curl -X GET https://tu-dominio.vercel.app/api/cron/check-notifications \
  -H "Authorization: Bearer TU_CRON_SECRET_AQUI"
```

### Opción 2: Test Local

```bash
# 1. Ejecutar en modo dev
vercel dev

# 2. En otra terminal
curl -X GET http://localhost:3000/api/cron/check-notifications \
  -H "Authorization: Bearer mpr-soluciones-cron-secret-2025-change-this-in-production"
```

### Opción 3: Probar la Función Directamente en Supabase

```sql
-- En Supabase SQL Editor
SELECT * FROM fn_check_and_notify_pending_obligations();
```

---

## 📊 Ejemplo de Flujo Completo

### Escenario: Obligación IVA vence el 15 de Diciembre 2025

| Fecha | Días Restantes | Acción | Tipo de Notificación |
|-------|----------------|--------|---------------------|
| **1 Dic** | 14 días | ✅ Cron ejecuta a las 9am, 3pm, 9pm → Crea notificación | `reminder_15_days` |
| **2-7 Dic** | 13-8 días | ⏸️ Cron ejecuta pero no crea notificación (fuera de rangos) | - |
| **8 Dic** | 7 días | ✅ Cron ejecuta a las 9am → Crea notificación | `reminder_7_days` |
| **9-11 Dic** | 6-4 días | ⏸️ Cron ejecuta pero no crea notificación | - |
| **12 Dic** | 3 días | ✅ Cron ejecuta 3 veces → **3 notificaciones** | `reminder_urgent` |
| **13 Dic** | 2 días | ✅ Cron ejecuta 3 veces → **3 notificaciones** | `reminder_urgent` |
| **14 Dic** | 1 día | ✅ Cron ejecuta 3 veces → **3 notificaciones** | `reminder_urgent` |
| **15 Dic** | 0 días (HOY) | ✅ Cron ejecuta 3 veces → **3 notificaciones** | `reminder_urgent` |

**Total de notificaciones:**
- 1 de 15 días
- 1 de 7 días
- 12 urgentes (4 días × 3 notificaciones/día)
- **= 14 notificaciones totales**

---

## 🔍 Lógica Anti-Duplicados

### Para Notificaciones de 15 y 7 Días

```sql
-- Verifica si ya existe una notificación del mismo tipo para la misma obligación
SELECT EXISTS(
    SELECT 1
    FROM public.notifications
    WHERE obligation_id = [obligation_id]
      AND notification_type = 'reminder_15_days'  -- o 'reminder_7_days'
      AND active = TRUE
) INTO v_notification_exists;

-- Solo crea si NO existe
IF NOT v_notification_exists THEN
    INSERT INTO notifications (...)
END IF;
```

### Para Notificaciones Urgentes (Últimos 3 Días)

```sql
-- NO verifica duplicados - siempre crea
-- Esto permite 3 notificaciones diarias en los últimos 3 días
IF v_notification_type = 'reminder_urgent' THEN
    v_notification_exists := FALSE;  -- Forzar creación
    INSERT INTO notifications (...)
END IF;
```

---

## 🚨 Troubleshooting

### Las notificaciones no se crean

**Posibles causas:**

1. **La obligación no está en estado `pending`**
   ```sql
   -- Verificar en Supabase
   SELECT id, status, due_date FROM output_documents WHERE id = [obligation_id];
   ```

2. **La empresa no está activa**
   ```sql
   SELECT id, name, active FROM companies WHERE id = [company_id];
   ```

3. **No hay usuarios asignados**
   ```sql
   SELECT assigned_to, assigned_accountant FROM companies WHERE id = [company_id];
   ```

4. **La notificación ya existe (para 15 o 7 días)**
   ```sql
   SELECT * FROM notifications
   WHERE obligation_id = [obligation_id]
     AND notification_type = 'reminder_15_days';
   ```

### El cron no se ejecuta

**Verificar:**

1. **Cron Jobs configurados en Vercel Dashboard**
   - Vercel Dashboard → Cron Jobs → Verificar que aparecen los 3 horarios

2. **Variables de entorno configuradas**
   - Vercel Dashboard → Settings → Environment Variables
   - Verificar `CRON_SECRET`, `EXPO_PUBLIC_SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`

3. **Logs de ejecución**
   - Vercel Dashboard → Logs
   - Filtrar por `/api/cron/check-notifications`

### Error: "Unauthorized"

**Causa:** El `CRON_SECRET` no coincide

**Solución:**
1. Verificar que el valor en Vercel sea el mismo que usas en el request
2. Asegurarse de usar el formato: `Bearer [tu-secret]`

---

## 📈 Monitoreo y Métricas

### En Vercel Dashboard

**Vercel Dashboard → Tu Proyecto → Cron Jobs**

Puedes ver:
- Última ejecución
- Próxima ejecución programada
- Historial de ejecuciones (últimas 24 horas)
- Logs de cada ejecución

### En Supabase

```sql
-- Ver todas las notificaciones creadas hoy
SELECT
    n.created_at,
    n.notification_type,
    n.title,
    u.email,
    c.name as company_name,
    od.due_date
FROM notifications n
JOIN users u ON n.user_id = u.id
JOIN companies c ON n.company_id = c.id
LEFT JOIN output_documents od ON n.obligation_id = od.id
WHERE n.created_at::date = CURRENT_DATE
ORDER BY n.created_at DESC;
```

```sql
-- Contar notificaciones por tipo
SELECT
    notification_type,
    COUNT(*) as total,
    COUNT(CASE WHEN is_read THEN 1 END) as read_count,
    COUNT(CASE WHEN NOT is_read THEN 1 END) as unread_count
FROM notifications
WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY notification_type
ORDER BY total DESC;
```

---

## 🎛️ Modificar el Sistema

### Cambiar Horarios de Ejecución

Editar `vercel.json`:

```json
{
  "crons": [
    {
      "path": "/api/cron/check-notifications",
      "schedule": "0 8 * * *"  // Cambiar a 8am
    }
  ]
}
```

Luego redeploy: `vercel --prod`

### Cambiar Días de Recordatorio

Editar la función en `COMPLETE_SETUP.sql`:

```sql
-- Cambiar de 15 días a 20 días
IF v_days_until_due >= 19 AND v_days_until_due <= 21 THEN
    v_notification_type := 'reminder_20_days';
    -- ...
END IF;
```

Re-ejecutar el script en Supabase.

### Agregar Nuevos Tipos de Notificación

1. Agregar lógica en la función `fn_check_and_notify_pending_obligations()`
2. Actualizar el endpoint si necesitas parámetros adicionales
3. Redeploy

---

## ✅ Checklist de Implementación

```
[✅] 1. Función creada: fn_check_and_notify_pending_obligations()
[✅] 2. Endpoint API creado: app/api/cron/check-notifications+api.ts
[✅] 3. vercel.json actualizado con 3 cron schedules
[✅] 4. COMPLETE_SETUP.sql actualizado con nueva función
[✅] 5. CRON_SECRET generado y configurado en .env
[ ] 6. Deploy a Vercel: vercel --prod
[ ] 7. Variables configuradas en Vercel Dashboard
[ ] 8. Cron Jobs visibles en Vercel Dashboard
[ ] 9. Test manual exitoso (cURL o Postman)
[ ] 10. Verificar notificaciones en Supabase después de test
[ ] 11. Esperar a las 9am/3pm/9pm UTC para verificar ejecución automática
```

---

## 🔗 Archivos Relacionados

- **Función Supabase:** `scripts/database/11_notifications/35_fn_check_and_notify_pending_obligations.sql`
- **API Route:** `app/api/cron/check-notifications+api.ts`
- **Configuración Cron:** `vercel.json`
- **Setup Completo:** `scripts/database/COMPLETE_SETUP.sql` (líneas 789-965)
- **Tabla Notifications:** `scripts/database/11_notifications/31_create_notifications_table.sql`

---

## 📚 Recursos

- [Vercel Cron Jobs Documentation](https://vercel.com/docs/cron-jobs)
- [Cron Expression Generator](https://crontab.guru/)
- [PostgreSQL Date/Time Functions](https://www.postgresql.org/docs/current/functions-datetime.html)
- [Supabase RPC Documentation](https://supabase.com/docs/reference/javascript/rpc)

---

**Última actualización:** 2025-11-30
