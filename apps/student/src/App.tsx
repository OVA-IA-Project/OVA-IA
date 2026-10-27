import { useEffect, useState } from 'react';
import { isSupabaseConfigured } from '@/lib/supabase';
import { AccessScreen } from '@/screens/AccessScreen';

/**
 * Shell de la aplicación.
 *
 * Fase 0: arranque + pantalla de acceso. Las rutas por pestaña se agregan en
 * la fase 1, una vez existan participantes reales en la base.
 */
type BootState = 'checking' | 'ready';

export default function App() {
  const [boot, setBoot] = useState<BootState>('checking');

  useEffect(() => {
    // Placeholder: aquí irá la restauración de sesión de Supabase.
    const id = window.setTimeout(() => setBoot('ready'), 250);
    return () => window.clearTimeout(id);
  }, []);

  if (boot === 'checking') {
    return (
      <div className="flex min-h-screen items-center justify-center bg-surface">
        <div className="flex flex-col items-center gap-3">
          <div
            className="h-10 w-10 animate-spin rounded-full border-2 border-primary-fixed border-t-primary"
            role="status"
            aria-label="Cargando"
          />
          <p className="text-body-sm text-on-surface-variant">Preparando tu espacio de aprendizaje…</p>
        </div>
      </div>
    );
  }

  return <AccessScreen supabaseReady={isSupabaseConfigured} />;
}
