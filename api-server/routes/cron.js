const express = require('express');
const { createClient } = require('@supabase/supabase-js');

const router = express.Router();

// ============================================================
// POST /api/cron/generate-obligations
// Genera obligaciones mensuales automáticamente
// ============================================================
router.get('/generate-obligations', async (req, res) => {
  const startTime = Date.now();
  let supabase = null;

  try {
    // 1. SEGURIDAD: Verificar Authorization header
    const authHeader = req.headers.authorization;
    const cronSecret = process.env.CRON_SECRET;

    if (!cronSecret) {
      console.error('CRON_SECRET no está configurado');
      return res.status(500).json({ error: 'Server configuration error' });
    }

    if (authHeader !== `Bearer ${cronSecret}`) {
      console.error('Unauthorized cron attempt');
      return res.status(401).json({ error: 'Unauthorized' });
    }

    // 2. Inicializar Supabase Client
    const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL;
    const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

    if (!supabaseUrl || !supabaseServiceKey) {
      console.error('Supabase credentials no están configuradas');
      return res.status(500).json({ error: 'Server configuration error' });
    }

    supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });

    // 3. Calcular año y mes actual
    const now = new Date();
    const currentYear = now.getFullYear();
    const currentMonth = now.getMonth() + 1;

    console.log(`Generating obligations for ${currentYear}-${currentMonth}`);

    // 4. Llamar función de Supabase
    const { data, error } = await supabase.rpc('fn_generate_monthly_obligations', {
      p_company_id: null,
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

      return res.status(500).json({
        success: false,
        error: error.message,
        details: error,
      });
    }

    // 5. Procesar resultados
    const results = data || [];
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

    return res.status(200).json(response);
  } catch (error) {
    console.error('Unexpected error in cron job:', error);

    // Guardar exception en log
    if (supabase) {
      try {
        await supabase.from('cron_execution_log').insert({
          cron_name: 'generate-obligations',
          execution_time: new Date().toISOString(),
          status: 'error',
          error_message: error.message || 'Unknown error',
          details: { stack: error.stack },
          execution_duration_ms: Date.now() - startTime,
        });
      } catch (logError) {
        console.error('Failed to log error to database:', logError);
      }
    }

    return res.status(500).json({
      success: false,
      error: 'Internal server error',
      message: error.message || 'Unknown error',
    });
  }
});

module.exports = router;
