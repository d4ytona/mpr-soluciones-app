-- 36_attach_audit_document_requirements.sql
-- ============================================================
-- Description: Attaches audit trigger to document_requirements table.
-- ============================================================

DROP TRIGGER IF EXISTS trg_audit_document_requirements ON public.document_requirements;

CREATE TRIGGER trg_audit_document_requirements
AFTER INSERT OR UPDATE OR DELETE ON public.document_requirements
FOR EACH ROW EXECUTE FUNCTION public.fn_write_audit();
