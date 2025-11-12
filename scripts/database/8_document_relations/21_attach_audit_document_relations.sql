-- ============================================================
-- 18_attach_audit_document_relations.sql
-- Description: Attaches the generic audit trigger to the
--              document_relations table.
-- ============================================================

DROP TRIGGER IF EXISTS trg_audit_document_relations ON public.document_relations;

CREATE TRIGGER trg_audit_document_relations
AFTER INSERT OR UPDATE OR DELETE ON public.document_relations
FOR EACH ROW
EXECUTE FUNCTION fn_write_audit();
