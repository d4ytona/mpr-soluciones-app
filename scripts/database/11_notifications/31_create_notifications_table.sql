-- 31_create_notifications_table.sql
-- ============================================================
-- Description: Stores user notifications for obligation changes,
--              new obligations, and other system events.
-- ============================================================

DROP TABLE IF EXISTS public.notifications CASCADE;

CREATE TABLE public.notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    obligation_id BIGINT REFERENCES public.output_documents(id) ON DELETE CASCADE,
    company_id BIGINT REFERENCES public.companies(id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL DEFAULT 'status_change',
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    deleted_at TIMESTAMPTZ
);

-- Create indexes for performance
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_obligation_id ON public.notifications(obligation_id);
CREATE INDEX idx_notifications_company_id ON public.notifications(company_id);
CREATE INDEX idx_notifications_is_read ON public.notifications(is_read);
CREATE INDEX idx_notifications_created_at ON public.notifications(created_at DESC);
CREATE INDEX idx_notifications_active ON public.notifications(active) WHERE active = TRUE;

COMMENT ON TABLE public.notifications IS 'Stores user notifications for obligations and company events';
COMMENT ON COLUMN public.notifications.notification_type IS 'Types: status_change, new_obligation, deadline_reminder, document_expiring';
