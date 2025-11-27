-- 33_create_notification_functions.sql
-- ============================================================
-- Description: Functions to handle automatic notification creation
--              on obligation status changes and new obligations.
-- ============================================================

-- ============================================================
-- Function: Notify on Obligation Status Change
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_notify_obligation_status_change()
RETURNS TRIGGER AS $$
DECLARE
    company_record RECORD;
    notification_title VARCHAR(255);
    notification_message TEXT;
BEGIN
    -- Only notify on status change
    IF OLD.obligation_status IS DISTINCT FROM NEW.obligation_status THEN
        -- Get company info and assigned users
        SELECT
            c.id,
            c.name,
            c.assigned_accountant,
            c.assigned_client
        INTO company_record
        FROM public.companies c
        WHERE c.id = NEW.company_id;

        -- Prepare notification content
        notification_title := CASE
            WHEN NEW.obligation_status = 'completed' THEN 'Obligación Completada'
            WHEN NEW.obligation_status = 'in_progress' THEN 'Obligación En Progreso'
            WHEN NEW.obligation_status = 'overdue' THEN 'Obligación Vencida'
            ELSE 'Cambio de Estado'
        END;

        notification_message := format(
            'La obligación de %s para %s ha cambiado de estado: %s → %s',
            (SELECT name FROM public.document_types WHERE id = NEW.document_type_id),
            company_record.name,
            COALESCE(OLD.obligation_status, 'nuevo'),
            NEW.obligation_status
        );

        -- Notify assigned accountant
        IF company_record.assigned_accountant IS NOT NULL THEN
            INSERT INTO public.notifications (
                user_id,
                title,
                message,
                obligation_id,
                company_id,
                notification_type
            ) VALUES (
                company_record.assigned_accountant,
                notification_title,
                notification_message,
                NEW.id,
                NEW.company_id,
                'status_change'
            );
        END IF;

        -- Notify assigned client
        IF company_record.assigned_client IS NOT NULL THEN
            INSERT INTO public.notifications (
                user_id,
                title,
                message,
                obligation_id,
                company_id,
                notification_type
            ) VALUES (
                company_record.assigned_client,
                notification_title,
                notification_message,
                NEW.id,
                NEW.company_id,
                'status_change'
            );
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- Function: Notify on New Obligation
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_notify_new_obligation()
RETURNS TRIGGER AS $$
DECLARE
    company_record RECORD;
    notification_title VARCHAR(255);
    notification_message TEXT;
    period_text TEXT;
BEGIN
    -- Only notify for auto-generated obligations
    IF NEW.auto_generated = TRUE THEN
        -- Get company info and assigned users
        SELECT
            c.id,
            c.name,
            c.assigned_accountant,
            c.assigned_client
        INTO company_record
        FROM public.companies c
        WHERE c.id = NEW.company_id;

        -- Format period text
        period_text := to_char(make_date(NEW.period_year, NEW.period_month, 1), 'Month YYYY');

        -- Prepare notification content
        notification_title := 'Nueva Obligación';

        notification_message := format(
            'Nueva obligación creada: %s - %s para %s. Vence: %s',
            (SELECT name FROM public.document_types WHERE id = NEW.document_type_id),
            period_text,
            company_record.name,
            to_char(NEW.due_date, 'DD/MM/YYYY')
        );

        -- Notify assigned accountant
        IF company_record.assigned_accountant IS NOT NULL THEN
            INSERT INTO public.notifications (
                user_id,
                title,
                message,
                obligation_id,
                company_id,
                notification_type
            ) VALUES (
                company_record.assigned_accountant,
                notification_title,
                notification_message,
                NEW.id,
                NEW.company_id,
                'new_obligation'
            );
        END IF;

        -- Notify assigned client
        IF company_record.assigned_client IS NOT NULL THEN
            INSERT INTO public.notifications (
                user_id,
                title,
                message,
                obligation_id,
                company_id,
                notification_type
            ) VALUES (
                company_record.assigned_client,
                notification_title,
                notification_message,
                NEW.id,
                NEW.company_id,
                'new_obligation'
            );
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
