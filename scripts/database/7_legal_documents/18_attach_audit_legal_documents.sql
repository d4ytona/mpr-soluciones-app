-- 14_attach_audit_legal_documents.sql
-- ============================================================
-- Description: Attaches the generic audit trigger to legal_documents.
-- ============================================================
DROP TRIGGER IF EXISTS trg_audit_legal_documents ON public.legal_documents;

CREATE TRIGGER trg_audit_legal_documents
AFTER INSERT OR UPDATE OR DELETE ON public.legal_documents
FOR EACH ROW
EXECUTE FUNCTION fn_write_audit();