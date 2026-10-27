import { createClient, type SupabaseClient } from '@supabase/supabase-js';

/**
 * Cliente de Supabase.
 *
 * La seguridad NO depende de esconder esta clave: depende de las políticas
 * RLS definidas en supabase/migrations/0002_rls.sql.
 *
 * La clave `service_role` NUNCA debe aparecer aquí.
 */

const url = import.meta.env.VITE_SUPABASE_URL;
const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

export const isSupabaseConfigured = Boolean(url && anonKey && !url.includes('TU-PROYECTO'));

function createSupabase(): SupabaseClient | null {
  if (!isSupabaseConfigured) {
    console.warn(
      '[OVA-IA] Supabase no está configurado. Copia .env.example a .env.local y completa ' +
        'VITE_SUPABASE_URL y VITE_SUPABASE_ANON_KEY.',
    );
    return null;
  }

  return createClient(url, anonKey, {
    auth: {
      persistSession: true,
      autoRefreshToken: true,
      detectSessionInUrl: false,
      storageKey: 'ova-ia-auth',
    },
    global: {
      headers: { 'x-application-name': 'ova-ia-student' },
    },
  });
}

export const supabase = createSupabase();

/** Acceso garantizado al cliente; lanza si falta configuración. */
export function requireSupabase(): SupabaseClient {
  if (!supabase) {
    throw new Error(
      'Supabase no configurado: define VITE_SUPABASE_URL y VITE_SUPABASE_ANON_KEY en .env.local',
    );
  }
  return supabase;
}
