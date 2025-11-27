-- 36_attach_audit_required_inputs.sql
-- ============================================================
-- Description: Attaches audit trigger to output_required_inputs table.
-- ============================================================

DROP TRIGGER IF EXISTS trg_audit_output_required_inputs ON public.output_required_inputs;

CREATE TRIGGER trg_audit_output_required_inputs
AFTER INSERT OR UPDATE OR DELETE ON public.output_required_inputs
FOR EACH ROW EXECUTE FUNCTION public.fn_write_audit();
