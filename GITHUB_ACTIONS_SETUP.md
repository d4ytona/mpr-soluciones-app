# GitHub Actions - Setup de Cron Jobs

## 🎯 Objetivo

Ejecutar cron jobs automáticos mediante GitHub Actions para generar obligaciones mensuales sin depender de límites de Vercel.

---

## ✅ Ventajas vs Vercel Cron

| Feature | Vercel Cron | GitHub Actions |
|---------|-------------|----------------|
| **Costo** | 2 jobs gratis | Ilimitado (público) |
| **Logs** | 24-48h | 90 días |
| **Ejecución manual** | ❌ No | ✅ Sí |
| **Límites** | Por cuenta | Por repo |

---

## 📋 Setup Paso a Paso

### 1. El workflow ya está creado

El archivo `.github/workflows/generate-obligations.yml` ya está en el repositorio.

**Schedule actual:**
- `0 4 * * *` → Diario a las 00:00 Venezuela (04:00 UTC)

---

### 2. Configurar CRON_SECRET en GitHub

**Paso 2.1:** Genera un secreto seguro (en tu terminal local):

```bash
openssl rand -base64 32
```

Copia el resultado (ejemplo: `xK9mP2vN8qR5tL7wY3aZ1bC4dF6gH8jM0nS2uV4xE6A=`)

**Paso 2.2:** Agrégalo a GitHub Secrets:

1. Ve a tu repositorio en GitHub
2. **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"**
4. **Name:** `CRON_SECRET`
5. **Value:** El valor que generaste
6. Click **"Add secret"**

---

### 3. Actualizar URL de Vercel en el workflow

Una vez que despliegues tu app a Vercel:

1. Anota tu URL de producción (ejemplo: `https://mpr-soluciones.vercel.app`)
2. Edita `.github/workflows/generate-obligations.yml`
3. Reemplaza `https://YOUR_VERCEL_URL.vercel.app` con tu URL real
4. Commit y push:

```bash
git add .github/workflows/generate-obligations.yml
git commit -m "chore(cron): update Vercel URL in GitHub Actions workflow"
git push
```

---

### 4. Configurar CRON_SECRET en Vercel (también)

Aunque el cron se ejecuta desde GitHub Actions, el endpoint en Vercel necesita validar el secret:

1. Ve a tu proyecto en Vercel Dashboard
2. **Settings** → **Environment Variables**
3. Agrega:
   - **Name:** `CRON_SECRET`
   - **Value:** El mismo valor que pusiste en GitHub
   - **Environment:** Production, Preview, Development
4. **Save**
5. Redeploy si es necesario

---

## ▶️ Ejecución Manual (Testing)

Puedes probar el cron manualmente sin esperar al schedule:

1. Ve a tu repo en GitHub
2. Click en **Actions** tab
3. Selecciona **"Generate Monthly Obligations"** en la lista
4. Click **"Run workflow"** → **"Run workflow"**
5. Espera 10-20 segundos
6. Verifica los logs en la ejecución

---

## 📊 Verificar Logs

### En GitHub Actions:
1. **Actions** tab → Selecciona una ejecución
2. Click en el job `generate-obligations`
3. Expande el step "Generate obligations via API"

### En Supabase:
```sql
-- Ver últimas ejecuciones
SELECT * FROM cron_execution_log
ORDER BY execution_time DESC
LIMIT 10;

-- Ver estado actual
SELECT * FROM v_cron_status;
```

---

## 🔧 Troubleshooting

### Error: "Unauthorized" (401)

**Causa:** CRON_SECRET no coincide

**Solución:**
1. Verifica que el secret en GitHub Secrets sea exactamente el mismo que en Vercel Environment Variables
2. No debe tener espacios al inicio/final
3. Redeploy en Vercel si cambiaste el valor

### Error: "Connection refused" o "404"

**Causa:** URL incorrecta en el workflow

**Solución:**
1. Verifica que la URL en `.github/workflows/generate-obligations.yml` sea correcta
2. Debe incluir `https://`
3. Debe ser la URL de producción de Vercel (no preview)

### El cron no se ejecuta en el schedule

**Causa:** GitHub Actions puede tener delays de hasta 15 minutos

**Solución:**
- Espera 15-20 minutos después del horario programado
- Verifica que el repo tenga actividad reciente (GitHub desactiva workflows en repos inactivos por 60 días)

---

## 🔗 Archivos Relacionados

- **Workflow:** `.github/workflows/generate-obligations.yml`
- **Endpoint:** `app/api/cron/generate-obligations+api.ts`
- **Tabla de logs:** `scripts/database/COMPLETE_SETUP.sql` (PART 11)
- **Queries útiles:** `scripts/database/CRON_MONITORING_QUERIES.sql`

---

## 📝 Próximos Pasos

Una vez que el cron de obligaciones funcione correctamente, se puede agregar:

1. **Notificaciones:** Agregar `check-notifications` workflow
2. **Alertas:** Enviar notificación a Discord/Slack si hay errores
3. **Reportes:** Workflow semanal con resumen de obligaciones creadas

---

**Última actualización:** 2025-12-01
