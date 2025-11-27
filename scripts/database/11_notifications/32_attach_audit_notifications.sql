-- 32_attach_audit_notifications.sql
-- ============================================================
-- Description: Attaches audit trigger to notifications table.
-- ============================================================

DROP TRIGGER IF EXISTS trg_audit_notifications ON public.notifications;

CREATE TRIGGER trg_audit_notifications
AFTER INSERT OR UPDATE OR DELETE ON public.notifications
FOR EACH ROW EXECUTE FUNCTION public.fn_write_audit();
