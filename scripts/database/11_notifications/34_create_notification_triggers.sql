-- 34_create_notification_triggers.sql
-- ============================================================
-- Description: Triggers to automatically create notifications
--              when obligations are created or status changes.
-- ============================================================

-- Trigger for obligation status changes
DROP TRIGGER IF EXISTS trg_notify_obligation_status_change ON public.output_documents;

CREATE TRIGGER trg_notify_obligation_status_change
    AFTER UPDATE ON public.output_documents
    FOR EACH ROW
    EXECUTE FUNCTION public.fn_notify_obligation_status_change();

-- Trigger for new obligations
DROP TRIGGER IF EXISTS trg_notify_new_obligation ON public.output_documents;

CREATE TRIGGER trg_notify_new_obligation
    AFTER INSERT ON public.output_documents
    FOR EACH ROW
    EXECUTE FUNCTION public.fn_notify_new_obligation();
