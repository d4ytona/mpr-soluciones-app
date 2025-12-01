-- 35_fn_check_and_notify_pending_obligations.sql
-- ============================================================
-- Description: Checks all pending obligations and creates
--              notifications based on days until due date.
--              Designed to be called by Vercel Cron (3x daily).
-- ============================================================

CREATE OR REPLACE FUNCTION public.fn_check_and_notify_pending_obligations()
RETURNS TABLE(
    notifications_created INTEGER,
    obligations_checked INTEGER,
    details JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_obligation RECORD;
    v_days_until_due INTEGER;
    v_notification_type VARCHAR(50);
    v_notification_exists BOOLEAN;
    v_notification_title VARCHAR(255);
    v_notification_message TEXT;
    v_notifications_created INTEGER := 0;
    v_obligations_checked INTEGER := 0;
    v_details JSONB := '[]'::JSONB;
    v_detail JSONB;
BEGIN
    -- Loop through all pending obligations
    FOR v_obligation IN
        SELECT
            od.id,
            od.due_date,
            od.document_type_id,
            od.period_year,
            od.period_month,
            c.id as company_id,
            c.name as company_name,
            c.assigned_to,
            c.assigned_accountant,
            c.assigned_client,
            dt.name as document_name
        FROM public.output_documents od
        JOIN public.companies c ON od.company_id = c.id
        JOIN public.document_types dt ON od.document_type_id = dt.id
        WHERE od.status = 'pending'
          AND od.active = TRUE
          AND c.active = TRUE
          AND od.due_date >= CURRENT_DATE  -- Only future obligations
        ORDER BY od.due_date ASC
    LOOP
        v_obligations_checked := v_obligations_checked + 1;

        -- Calculate days until due
        v_days_until_due := v_obligation.due_date - CURRENT_DATE;

        -- Determine notification type based on days remaining
        v_notification_type := NULL;

        IF v_days_until_due >= 14 AND v_days_until_due <= 16 THEN
            -- 15 days before (with 1 day tolerance)
            v_notification_type := 'reminder_15_days';
            v_notification_title := '⏰ Recordatorio: 15 días para vencimiento';
            v_notification_message := format(
                'La obligación "%s" de %s vence en %s días (%s)',
                v_obligation.document_name,
                v_obligation.company_name,
                v_days_until_due,
                to_char(v_obligation.due_date, 'DD/MM/YYYY')
            );

        ELSIF v_days_until_due >= 6 AND v_days_until_due <= 8 THEN
            -- 7 days before (with 1 day tolerance)
            v_notification_type := 'reminder_7_days';
            v_notification_title := '⚠️ Recordatorio: 1 semana para vencimiento';
            v_notification_message := format(
                'La obligación "%s" de %s vence en %s días (%s)',
                v_obligation.document_name,
                v_obligation.company_name,
                v_days_until_due,
                to_char(v_obligation.due_date, 'DD/MM/YYYY')
            );

        ELSIF v_days_until_due <= 3 AND v_days_until_due >= 0 THEN
            -- Last 3 days - create notification each time (3x daily)
            v_notification_type := 'reminder_urgent';
            v_notification_title := '🚨 URGENTE: ' || v_days_until_due || ' día(s) para vencimiento';
            v_notification_message := format(
                '¡ATENCIÓN! La obligación "%s" de %s vence en %s día(s) (%s)',
                v_obligation.document_name,
                v_obligation.company_name,
                v_days_until_due,
                to_char(v_obligation.due_date, 'DD/MM/YYYY')
            );
        END IF;

        -- If we determined a notification type, check if we should create it
        IF v_notification_type IS NOT NULL THEN

            -- For urgent notifications (last 3 days), always create (3x daily)
            -- For others, check if notification already exists for this obligation+type
            IF v_notification_type = 'reminder_urgent' THEN
                v_notification_exists := FALSE;  -- Always create for urgent
            ELSE
                -- Check if notification already exists
                SELECT EXISTS(
                    SELECT 1
                    FROM public.notifications
                    WHERE obligation_id = v_obligation.id
                      AND notification_type = v_notification_type
                      AND active = TRUE
                ) INTO v_notification_exists;
            END IF;

            -- Create notification if it doesn't exist (or is urgent)
            IF NOT v_notification_exists THEN

                -- Create notification for assigned_to (main responsible)
                IF v_obligation.assigned_to IS NOT NULL THEN
                    INSERT INTO public.notifications (
                        user_id,
                        title,
                        message,
                        obligation_id,
                        company_id,
                        notification_type,
                        is_read
                    ) VALUES (
                        v_obligation.assigned_to,
                        v_notification_title,
                        v_notification_message,
                        v_obligation.id,
                        v_obligation.company_id,
                        v_notification_type,
                        FALSE
                    );
                    v_notifications_created := v_notifications_created + 1;
                END IF;

                -- Also notify accountant if different from assigned_to
                IF v_obligation.assigned_accountant IS NOT NULL
                   AND v_obligation.assigned_accountant != v_obligation.assigned_to THEN
                    INSERT INTO public.notifications (
                        user_id,
                        title,
                        message,
                        obligation_id,
                        company_id,
                        notification_type,
                        is_read
                    ) VALUES (
                        v_obligation.assigned_accountant,
                        v_notification_title,
                        v_notification_message,
                        v_obligation.id,
                        v_obligation.company_id,
                        v_notification_type,
                        FALSE
                    );
                    v_notifications_created := v_notifications_created + 1;
                END IF;

                -- Add to details
                v_detail := jsonb_build_object(
                    'obligation_id', v_obligation.id,
                    'company_name', v_obligation.company_name,
                    'document_name', v_obligation.document_name,
                    'days_until_due', v_days_until_due,
                    'due_date', v_obligation.due_date,
                    'notification_type', v_notification_type
                );
                v_details := v_details || v_detail;
            END IF;
        END IF;

    END LOOP;

    -- Return summary
    RETURN QUERY SELECT
        v_notifications_created,
        v_obligations_checked,
        v_details;
END;
$$;

COMMENT ON FUNCTION public.fn_check_and_notify_pending_obligations()
IS 'Checks pending obligations and creates deadline reminder notifications. Called by Vercel Cron 3x daily (9am, 3pm, 9pm).';
