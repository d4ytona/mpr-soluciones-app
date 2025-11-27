import { useState, useCallback } from 'react';
import { supabase } from '../lib/supabase';
import { ObligationDashboard, UrgencyLevel } from '../types/database';

interface UseObligationsOptions {
  companyId?: number;
  urgencyLevel?: UrgencyLevel;
  status?: string;
}

export function useObligations(options: UseObligationsOptions = {}) {
  const [obligations, setObligations] = useState<ObligationDashboard[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchObligations = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      let query = supabase
        .from('v_obligations_dashboard')
        .select('*')
        .order('due_date', { ascending: true });

      // Apply filters if provided
      if (options.companyId) {
        query = query.eq('company_id', options.companyId);
      }

      if (options.urgencyLevel) {
        query = query.eq('urgency_level', options.urgencyLevel);
      }

      if (options.status) {
        query = query.eq('obligation_status', options.status);
      }

      const { data, error: fetchError } = await query;

      if (fetchError) {
        throw fetchError;
      }

      setObligations((data as ObligationDashboard[]) || []);
    } catch (err) {
      console.error('Error fetching obligations:', err);
      setError(err instanceof Error ? err.message : 'Error desconocido');
    } finally {
      setLoading(false);
    }
  }, [options.companyId, options.urgencyLevel, options.status]);

  return { obligations, loading, error, refetch: fetchObligations };
}
