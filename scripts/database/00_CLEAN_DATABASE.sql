-- ============================================================
-- 00_CLEAN_DATABASE.sql
-- ============================================================
-- MPR Soluciones - Complete Database Cleanup
-- Elimina TODAS las tablas, vistas, funciones y triggers del schema public
--
-- ⚠️ PRECAUCIÓN: Este script borrará TODA la base de datos
--
-- Instrucciones:
-- 1. Open Supabase Dashboard → SQL Editor
-- 2. Copy this ENTIRE file
-- 3. Paste and click "Run"
-- 4. Luego ejecutar COMPLETE_SETUP.sql
-- ============================================================

-- ============================================================
-- PASO 1: ELIMINAR TODAS LAS VISTAS
-- ============================================================

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT table_name FROM information_schema.views WHERE table_schema = 'public')
    LOOP
        EXECUTE 'DROP VIEW IF EXISTS public.' || quote_ident(r.table_name) || ' CASCADE';
    END LOOP;
END $$;

-- ============================================================
-- PASO 2: ELIMINAR TODAS LAS TABLAS
-- ============================================================

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public')
    LOOP
        EXECUTE 'DROP TABLE IF EXISTS public.' || quote_ident(r.tablename) || ' CASCADE';
    END LOOP;
END $$;

-- ============================================================
-- PASO 3: ELIMINAR TODAS LAS FUNCIONES
-- ============================================================

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT
            n.nspname as schema_name,
            p.proname as function_name,
            pg_get_function_identity_arguments(p.oid) as function_args
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
    )
    LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS public.' || quote_ident(r.function_name) || '(' || r.function_args || ') CASCADE';
    END LOOP;
END $$;

-- ============================================================
-- PASO 4: ELIMINAR TODOS LOS TIPOS CUSTOM (si existen)
-- ============================================================

DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT typname
        FROM pg_type t
        JOIN pg_namespace n ON t.typnamespace = n.oid
        WHERE n.nspname = 'public'
          AND t.typtype = 'e'  -- Solo ENUM types
    )
    LOOP
        EXECUTE 'DROP TYPE IF EXISTS public.' || quote_ident(r.typname) || ' CASCADE';
    END LOOP;
END $$;

-- ============================================================
-- VERIFICACIÓN: Contar objetos restantes
-- ============================================================

-- Debería retornar 0 en todos
SELECT
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE') as tables_remaining,
    (SELECT COUNT(*) FROM information_schema.views WHERE table_schema = 'public') as views_remaining,
    (SELECT COUNT(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid WHERE n.nspname = 'public') as functions_remaining,
    (SELECT COUNT(*) FROM pg_type t JOIN pg_namespace n ON t.typnamespace = n.oid WHERE n.nspname = 'public' AND t.typtype = 'e') as types_remaining;

-- ============================================================
-- Si todo está en 0, la base de datos está limpia
-- Ahora puedes ejecutar COMPLETE_SETUP.sql
-- ============================================================
