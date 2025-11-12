-- 12_attach_audit_input_documents.sql
-- ============================================================
-- Description: Attaches the generic audit trigger to input_documents.
-- ============================================================

DROP TRIGGER IF EXISTS trg_audit_input_documents ON public.input_documents;

CREATE TRIGGER trg_audit_input_documents
AFTER INSERT OR UPDATE OR DELETE ON public.input_documents
FOR EACH ROW
EXECUTE FUNCTION fn_write_audit();
