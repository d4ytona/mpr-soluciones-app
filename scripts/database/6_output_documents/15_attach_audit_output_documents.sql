-- 16_attach_audit_output_documents.sql
-- ============================================================
-- Description: Attaches the generic audit trigger to output_documents.
-- ============================================================
DROP TRIGGER IF EXISTS trg_audit_output_documents ON public.output_documents;

CREATE TRIGGER trg_audit_output_documents
AFTER INSERT OR UPDATE OR DELETE ON public.output_documents
FOR EACH ROW
EXECUTE FUNCTION fn_write_audit();