-- 03_create_generic_audit_trigger_template.sql
-- ============================================================
-- Description: Template for manually attaching audit triggers
--              to any table in the public schema.
-- ============================================================

-- Instructions:
-- 1) Make sure 01_create_audit_table.sql and 02_create_audit_function.sql
--    have already been executed.
-- 2) Use the example below to attach triggers manually for each table.
-- 3) Copy and replace <table_name> with your table name.

-- ===================================================================
-- Example manual trigger for a table <table_name>:
-- ===================================================================

-- DROP TRIGGER IF EXISTS trg_audit_<table_name> ON <table_name>;
-- CREATE TRIGGER trg_audit_<table_name>
-- AFTER INSERT OR UPDATE OR DELETE ON <table_name>
-- FOR EACH ROW
-- EXECUTE FUNCTION fn_write_audit();

-- Notes:
-- - Repeat for each table you want to audit.
-- - Triggers are row-level and capture INSERT, UPDATE, DELETE operations.
-- - Each trigger references the generic fn_write_audit() function.
