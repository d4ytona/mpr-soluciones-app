// app/api/cron/check-notifications+api.ts
// ============================================================
// Vercel Cron Job: Checks pending obligations and creates deadline notifications
// Runs 3 times daily: 9am, 3pm, 9pm UTC
// ============================================================

import { createClient } from '@supabase/supabase-js';

// Response type from the Supabase function
interface NotificationCheckResult {
  notifications_created: number;
  obligations_checked: number;
  details: Array<{
    obligation_id: number;
    company_name: string;
    document_name: string;
    days_until_due: number;
    due_date: string;
    notification_type: string;
  }>;
}

export async function GET(request: Request) {
  const startTime = Date.now();
  let supabase: any = null;

  try {
    // ============================================
    // 1. SECURITY: Verify request is authorized
    // ============================================
    const authHeader = request.headers.get('authorization');
    const cronSecret = process.env.CRON_SECRET;

    if (!cronSecret) {
      console.error('CRON_SECRET is not configured');
      return new Response(
        JSON.stringify({ error: 'Server configuration error' }),
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      );
    }

    if (authHeader !== `Bearer ${cronSecret}`) {
      console.error('Unauthorized notification check attempt');
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // ============================================
    // 2. Initialize Supabase Client
    // ============================================
    const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL;
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

    if (!supabaseUrl || !supabaseServiceKey) {
      console.error('Supabase credentials are not configured');
      return new Response(
        JSON.stringify({ error: 'Server configuration error' }),
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      );
    }

    supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });

    // ============================================
    // 3. Get current timestamp for logging
    // ============================================
    const now = new Date();
    const timestamp = now.toISOString();
    const currentHour = now.getUTCHours();

    console.log(`[${timestamp}] Checking notifications (hour: ${currentHour})`);

    // ============================================
    // 4. Call Supabase function to check obligations
    // ============================================
    const { data, error } = await supabase.rpc('fn_check_and_notify_pending_obligations');

    if (error) {
      console.error('Error calling Supabase notification function:', error);

      // Guardar error en log
      await supabase.from('cron_execution_log').insert({
        cron_name: 'check-notifications',
        execution_time: now.toISOString(),
        status: 'error',
        error_message: error.message,
        details: error,
        execution_duration_ms: Date.now() - startTime,
      });

      return new Response(
        JSON.stringify({
          success: false,
          error: error.message,
          details: error,
        }),
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // ============================================
    // 5. Process and return results
    // ============================================
    const result = data[0] as NotificationCheckResult;

    const response = {
      success: true,
      timestamp,
      execution_hour: currentHour,
      summary: {
        notifications_created: result.notifications_created,
        obligations_checked: result.obligations_checked,
        notifications_sent: result.details.length,
      },
      details: result.details,
    };

    console.log('[Notification Check] Summary:', response.summary);

    // Guardar success en log
    await supabase.from('cron_execution_log').insert({
      cron_name: 'check-notifications',
      execution_time: now.toISOString(),
      status: 'success',
      notifications_created: result.notifications_created,
      obligations_checked: result.obligations_checked,
      details: response,
      execution_duration_ms: Date.now() - startTime,
    });

    return new Response(JSON.stringify(response), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (error) {
    console.error('Unexpected error in notification cron job:', error);

    // Guardar exception en log
    if (supabase) {
      try {
        await supabase.from('cron_execution_log').insert({
          cron_name: 'check-notifications',
          execution_time: new Date().toISOString(),
          status: 'error',
          error_message: error instanceof Error ? error.message : 'Unknown error',
          details: error instanceof Error ? { stack: error.stack } : { error },
          execution_duration_ms: Date.now() - startTime,
        });
      } catch (logError) {
        console.error('Failed to log error to database:', logError);
      }
    }

    return new Response(
      JSON.stringify({
        success: false,
        error: 'Internal server error',
        message: error instanceof Error ? error.message : 'Unknown error',
      }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }
}
