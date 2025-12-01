# Configuración de Vercel Cron Jobs para MPR Soluciones

## 🎯 Objetivo

Automatizar la generación mensual de obligaciones (IVA, ISLR, etc.) usando Vercel Cron Jobs.

---

## 📋 Qué Hace el Cron Job

**Ejecuta:** Todos los días a las 00:00 UTC
**Acción:** Llama a `fn_generate_monthly_obligations()` en Supabase
**Resultado:** Crea automáticamente obligaciones pendientes para todas las empresas activas

**Ventajas de Ejecución Diaria:**
- ✅ Auto-detecta nuevas empresas y crea sus obligaciones al día siguiente
- ✅ Sistema auto-resiliente: si falla un día, se recupera el siguiente
- ✅ Evita duplicados: solo crea obligaciones que no existan

**Ejemplo Ejecución en Enero 2026:**
- **1 de Enero 2026 00:00** → Genera:
  - IVA de Enero 2026 (vence 15 Febrero 2026) - para todas las empresas
  - ISLR 2025 (vence 31 Marzo 2026) - para todas las empresas
- **2-14 de Enero** → Verifica y skippea (ya existen)
- **15 de Enero** (si creaste una nueva empresa el día 14) → Genera:
  - IVA de Enero 2026 para la nueva empresa
  - ISLR 2025 para la nueva empresa

---

## 🚀 Pasos para Configurar en Vercel

### 1. Desplegar a Vercel

```bash
# Desde la raíz del proyecto
vercel

# Seguir las instrucciones para crear el proyecto
```

### 2. Configurar Variables de Entorno en Vercel

Ve a: **Vercel Dashboard → Tu Proyecto → Settings → Environment Variables**

Agrega las siguientes variables:

| Variable | Valor | Descripción |
|----------|-------|-------------|
| `EXPO_PUBLIC_SUPABASE_URL` | `https://ybcroxxtnaqzbfepnchp.supabase.co` | URL de Supabase |
| `SUPABASE_SERVICE_ROLE_KEY` | `eyJhbGci...` | Service Role Key (ver Supabase Dashboard) |
| `CRON_SECRET` | `[generar-nuevo-secreto]` | Token secreto para proteger el endpoint |

**⚠️ IMPORTANTE: Para generar un CRON_SECRET seguro:**

```bash
# En tu terminal
openssl rand -base64 32

# Ejemplo de output:
# 8yG3KmN9pQw2Xz7Vb4Hj6Lf1Rt5Yn8Uc3Df0Sa9Wx==
```

Usa ese valor generado en Vercel.

### 3. Verificar que vercel.json está Configurado

El archivo `vercel.json` debe contener:

```json
{
  "crons": [
    {
      "path": "/api/cron/generate-obligations",
      "schedule": "0 0 * * *"
    }
  ]
}
```

**Formato del Schedule (Cron Expression):**
```
┌───────────── minuto (0 - 59)
│ ┌───────────── hora (0 - 23)
│ │ ┌───────────── día del mes (1 - 31)
│ │ │ ┌───────────── mes (1 - 12)
│ │ │ │ ┌───────────── día de la semana (0 - 6) (0 = Domingo)
│ │ │ │ │
* * * * *
```

**Ejemplos:**
- `0 0 * * *` → **Todos los días a las 00:00** (nuestra configuración)
- `0 0 1 * *` → Día 1 de cada mes a las 00:00
- `0 9 1 * *` → Día 1 de cada mes a las 09:00
- `0 0 15 * *` → Día 15 de cada mes a las 00:00
- `0 0 * * 1` → Cada Lunes a las 00:00

### 4. Hacer Deploy

```bash
# Deploy a producción
vercel --prod

# Vercel detectará automáticamente el cron job configurado
```

---

## ✅ Verificar que Funciona

### Opción 1: Esperar a las 00:00 UTC

El cron se ejecuta automáticamente **todos los días** a las 00:00 UTC.

**Primera ejecución del mes:**
- Creará obligaciones del mes actual para todas las empresas

**Días subsiguientes:**
- Verificará y skippeará obligaciones existentes
- Solo creará obligaciones para nuevas empresas

### Opción 2: Probar Manualmente (Recomendado)

**Usando cURL:**

```bash
curl -X GET https://tu-dominio.vercel.app/api/cron/generate-obligations \
  -H "Authorization: Bearer TU_CRON_SECRET_AQUI"
```

**Usando Postman:**
1. Crear request GET
2. URL: `https://tu-dominio.vercel.app/api/cron/generate-obligations`
3. Headers:
   - Key: `Authorization`
   - Value: `Bearer TU_CRON_SECRET_AQUI`
4. Send

**Respuesta esperada:**

```json
{
  "success": true,
  "timestamp": "2025-11-27T00:00:00.000Z",
  "year": 2025,
  "month": 11,
  "summary": {
    "total_created": 15,
    "total_skipped": 3,
    "companies_processed": 3
  },
  "details": [
    {
      "obligations_created": 5,
      "obligations_skipped": 1,
      "company_name": "Empresa Demo 1 C.A.",
      "details": {
        "year": 2025,
        "month": 11,
        "period": "November 2025"
      }
    },
    // ... más empresas
  ]
}
```

### Opción 3: Ver Logs en Vercel

1. Ve a **Vercel Dashboard → Tu Proyecto → Logs**
2. Filtra por: `/api/cron/generate-obligations`
3. Verás los logs de ejecución

---

## 🔐 Seguridad

### El endpoint está protegido por:

1. **Authorization Header:** Solo requests con el header correcto pueden ejecutar el cron
2. **CRON_SECRET:** Token secreto que solo tú conoces
3. **Service Role Key:** Usado internamente para comunicarse con Supabase

### ⚠️ NUNCA expongas:
- `CRON_SECRET`
- `SUPABASE_SERVICE_ROLE_KEY`

Estas claves deben estar SOLO en las variables de entorno de Vercel.

---

## 🐛 Troubleshooting

### Error: "Unauthorized"

**Causa:** El `CRON_SECRET` no coincide

**Solución:**
1. Verifica que `CRON_SECRET` en Vercel sea el mismo que usas en el request
2. Asegúrate de usar `Bearer ` antes del token

### Error: "Server configuration error"

**Causa:** Faltan variables de entorno

**Solución:**
1. Verifica que todas las variables estén configuradas en Vercel
2. Redeploy después de agregar variables

### Error: "Error calling Supabase function"

**Causa:** La función `fn_generate_monthly_obligations` no existe o tiene error

**Solución:**
1. Verifica que ejecutaste `COMPLETE_SETUP.sql` en Supabase
2. Prueba la función manualmente en Supabase SQL Editor:
   ```sql
   SELECT * FROM fn_generate_monthly_obligations();
   ```

### El cron no se ejecuta automáticamente

**Causa:** Vercel no detectó el `vercel.json`

**Solución:**
1. Asegúrate de que `vercel.json` está en la raíz del proyecto
2. Redeploy: `vercel --prod`
3. Ve a Vercel Dashboard → Settings → Cron Jobs para verificar

---

## 📊 Monitoreo

### Ver Ejecuciones del Cron

**Vercel Dashboard → Tu Proyecto → Cron Jobs**

Aquí verás:
- Última ejecución
- Próxima ejecución programada
- Historial de ejecuciones
- Logs de cada ejecución

### Notificaciones (Opcional)

Puedes agregar notificaciones por email modificando el endpoint:

```typescript
// Agregar al final de la función GET
if (totalCreated > 0) {
  // Enviar email de notificación
  await sendEmail({
    to: 'admin@mprsoluciones.com',
    subject: `Obligaciones generadas: ${totalCreated}`,
    body: JSON.stringify(response.summary, null, 2)
  });
}
```

---

## 🔄 Modificar el Schedule

Si quieres cambiar cuándo se ejecuta el cron:

1. Edita `vercel.json`:
   ```json
   {
     "crons": [
       {
         "path": "/api/cron/generate-obligations",
         "schedule": "0 9 1 * *"  // Ahora a las 9 AM
       }
     ]
   }
   ```

2. Redeploy:
   ```bash
   vercel --prod
   ```

---

## 📝 Testing Local

Para probar localmente (sin esperar al cron):

```bash
# 1. Instalar Vercel CLI
npm i -g vercel

# 2. Ejecutar en modo dev
vercel dev

# 3. En otra terminal, hacer request
curl -X GET http://localhost:3000/api/cron/generate-obligations \
  -H "Authorization: Bearer mpr-soluciones-cron-secret-2025-change-this-in-production"
```

---

## 🎯 Checklist de Implementación

```
[ ] 1. Archivo creado: app/api/cron/generate-obligations+api.ts
[ ] 2. Archivo creado: vercel.json
[ ] 3. Variables agregadas al .env local
[ ] 4. Deploy a Vercel: vercel --prod
[ ] 5. Variables configuradas en Vercel Dashboard
[ ] 6. CRON_SECRET generado con openssl rand -base64 32
[ ] 7. Cron Job visible en Vercel Dashboard → Cron Jobs
[ ] 8. Test manual exitoso (cURL o Postman)
[ ] 9. Verificar que las obligaciones se crean en Supabase
[ ] 10. Esperar al día 1 del próximo mes para verificar ejecución automática
```

---

## ✅ Beneficios de Esta Implementación

1. **Automático:** No requiere intervención manual
2. **Confiable:** Vercel garantiza la ejecución del cron
3. **Escalable:** Funciona sin importar cuántas empresas tengas
4. **Monitoreado:** Logs completos en Vercel Dashboard
5. **Seguro:** Endpoint protegido con token secreto
6. **Gratis:** Incluido en el plan gratuito de Vercel

---

## 📚 Recursos

- [Vercel Cron Jobs Documentation](https://vercel.com/docs/cron-jobs)
- [Cron Expression Generator](https://crontab.guru/)
- [Supabase RPC Documentation](https://supabase.com/docs/reference/javascript/rpc)

---

**Última actualización:** 2025-11-26
