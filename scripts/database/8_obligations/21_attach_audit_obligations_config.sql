-- 21_attach_audit_obligations_config.sql
-- ============================================================
-- Description: Attaches audit trigger to obligations_config table.
-- ============================================================

DROP TRIGGER IF EXISTS trg_audit_obligations_config ON public.obligations_config;

CREATE TRIGGER trg_audit_obligations_config
AFTER INSERT OR UPDATE OR DELETE
ON public.obligations_config
FOR EACH ROW
EXECUTE FUNCTION public.fn_write_audit();
