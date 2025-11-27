import { useState, useCallback } from 'react';
import { supabase } from '../lib/supabase';
import { CompanyWithAccountant } from '../types/database';

export function useCompanies() {
  const [companies, setCompanies] = useState<CompanyWithAccountant[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchCompanies = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      const { data, error: fetchError } = await supabase
        .from('companies')
        .select(`
          *,
          accountant:assigned_to (
            id,
            first_name,
            last_name,
            email
          )
        `)
        .eq('active', true)
        .order('name', { ascending: true });

      if (fetchError) {
        throw fetchError;
      }

      setCompanies(data as CompanyWithAccountant[]);
    } catch (err) {
      console.error('Error fetching companies:', err);
      setError(err instanceof Error ? err.message : 'Error desconocido');
    } finally {
      setLoading(false);
    }
  }, []);

  return { companies, loading, error, refetch: fetchCompanies };
}
