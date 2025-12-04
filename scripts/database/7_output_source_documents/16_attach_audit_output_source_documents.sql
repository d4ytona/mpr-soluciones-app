-- 16_attach_audit_output_source_documents.sql
-- ============================================================
-- Description: Attaches audit trigger to output_source_documents table.
-- ============================================================

DROP TRIGGER IF EXISTS trg_audit_output_source_documents ON public.output_source_documents;

CREATE TRIGGER trg_audit_output_source_documents
AFTER INSERT OR UPDATE OR DELETE ON public.output_source_documents
FOR EACH ROW EXECUTE FUNCTION public.fn_write_audit();
