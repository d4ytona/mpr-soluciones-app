// app/api/cron/generate-obligations+api.ts
// ============================================================
// Vercel Cron Job: Genera obligaciones mensuales automáticamente
// Se ejecuta DIARIAMENTE a las 00:00 UTC
// Auto-detecta nuevas empresas y evita duplicados
// ============================================================

import { createClient } from '@supabase/supabase-js';

// Tipos para la respuesta de la función
interface ObligationResult {
  obligations_created: number;
  obligations_skipped: number;
  company_name: string;
  details: {
    year: number;
    month: number;
    period: string;
  };
}

export async function GET(request: Request) {
  const startTime = Date.now();
  let supabase: any = null;

  try {
    // ============================================
    // 1. SEGURIDAD: Verificar que viene de Vercel Cron
    // ============================================
    const authHeader = request.headers.get('authorization');
    const cronSecret = process.env.CRON_SECRET;

    if (!cronSecret) {
      console.error('CRON_SECRET no está configurado');
      return new Response(
        JSON.stringify({ error: 'Server configuration error' }),
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      );
    }

    if (authHeader !== `Bearer ${cronSecret}`) {
      console.error('Unauthorized cron attempt');
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: { 'Content-Type': 'application/json' } }
      );
    }

    // ============================================
    // 2. Inicializar Supabase Client
    // ============================================
    const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL;
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

    if (!supabaseUrl || !supabaseServiceKey) {
      console.error('Supabase credentials no están configuradas');
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
    // 3. Calcular año y mes actual
    // ============================================
    const now = new Date();
    const currentYear = now.getFullYear();
    const currentMonth = now.getMonth() + 1; // JavaScript months are 0-indexed

    console.log(`Generating obligations for ${currentYear}-${currentMonth}`);

    // ============================================
    // 4. Llamar función de Supabase
    // ============================================
    const { data, error } = await supabase.rpc('fn_generate_monthly_obligations', {
      p_company_id: null, // null = todas las empresas
      p_year: currentYear,
      p_month: currentMonth,
    });

    if (error) {
      console.error('Error calling Supabase function:', error);

      // Guardar error en log
      await supabase.from('cron_execution_log').insert({
        cron_name: 'generate-obligations',
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
    // 5. Procesar resultados
    // ============================================
    const results = data as ObligationResult[];
    const totalCreated = results.reduce((sum, r) => sum + r.obligations_created, 0);
    const totalSkipped = results.reduce((sum, r) => sum + r.obligations_skipped, 0);

    const response = {
      success: true,
      timestamp: now.toISOString(),
      year: currentYear,
      month: currentMonth,
      summary: {
        total_created: totalCreated,
        total_skipped: totalSkipped,
        companies_processed: results.length,
      },
      details: results,
    };

    console.log('Obligations generated successfully:', response.summary);

    // Guardar success en log
    await supabase.from('cron_execution_log').insert({
      cron_name: 'generate-obligations',
      execution_time: now.toISOString(),
      status: 'success',
      obligations_created: totalCreated,
      obligations_skipped: totalSkipped,
      companies_processed: results.length,
      details: response,
      execution_duration_ms: Date.now() - startTime,
    });

    return new Response(JSON.stringify(response), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (error) {
    console.error('Unexpected error in cron job:', error);

    // Guardar exception en log
    if (supabase) {
      try {
        await supabase.from('cron_execution_log').insert({
          cron_name: 'generate-obligations',
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
