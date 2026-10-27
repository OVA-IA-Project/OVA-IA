import { useState } from 'react';

interface AccessScreenProps {
  supabaseReady: boolean;
}

/**
 * Pantalla de acceso.
 *
 * Fase 0: maqueta funcional de la UI (sin backend).
 * Fase 1: llamada a la RPC `verify_access_key` y creación del participante.
 *
 * Reglas de diseño (docs/design/DESIGN.md):
 *  · botones y campos >= 8px de radio, tarjetas 16px
 *  · toda acción táctil >= 44×44 px
 *  · foco visible en todos los controles
 */
export function AccessScreen({ supabaseReady }: AccessScreenProps) {
  const [code, setCode] = useState('');
  const [accessKey, setAccessKey] = useState('');
  const [error, setError] = useState<string | null>(null);

  const canSubmit = code.trim().length >= 4 && accessKey.trim().length >= 4;

  function handleSubmit(event: React.FormEvent) {
    event.preventDefault();
    setError(null);

    if (!canSubmit) {
      setError('Escribe tu código de participante y tu clave de acceso.');
      return;
    }

    // Fase 1 conectará aquí con verify_access_key().
    setError('La conexión con la base de datos se activa en la siguiente fase.');
  }

  return (
    <div className="flex min-h-screen flex-col bg-surface">
      <header className="pt-safe px-margin pb-space-md">
        <div className="flex items-center gap-3 pt-space-md">
          <div
            className="flex h-10 w-10 items-center justify-center rounded-xl bg-primary text-on-primary"
            aria-hidden="true"
          >
            <svg viewBox="0 0 24 24" className="h-6 w-6" fill="none" stroke="currentColor" strokeWidth="1.8">
              <path d="M4 15c0-3 3.5-4 8-4s8 1 8 4" strokeLinecap="round" />
              <circle cx="12" cy="7" r="3" />
            </svg>
          </div>
          <div className="flex min-w-0 flex-col">
            <span className="text-label-sm font-bold uppercase tracking-wider text-primary">
              OVA-IA 10°
            </span>
            <h1 className="truncate text-title-md font-semibold text-on-surface">Acceso</h1>
          </div>
        </div>
      </header>

      <main className="flex-1 px-margin pb-24">
        <section className="rounded-lg border border-outline-variant bg-surface-container-lowest p-space-md shadow-resting">
          <h2 className="text-title-md font-semibold text-on-surface">Entra a tus actividades</h2>
          <p className="mt-space-xs text-body-sm text-on-surface-variant">
            Tu docente te entregó un código de participante. Úsalo la primera vez; después
            bastará con tu clave.
          </p>

          <form className="mt-space-md flex flex-col gap-space-md" onSubmit={handleSubmit} noValidate>
            <div className="flex flex-col gap-1.5">
              <label htmlFor="participant-code" className="text-label-md text-on-surface-variant">
                Código de participante
              </label>
              <input
                id="participant-code"
                name="participantCode"
                type="text"
                inputMode="text"
                autoComplete="username"
                autoCapitalize="characters"
                spellCheck={false}
                placeholder="INS2-10B-0147"
                value={code}
                onChange={(event) => setCode(event.target.value.toUpperCase())}
                className="min-h-[44px] w-full rounded-lg border border-outline-variant bg-surface px-3 font-mono text-code-sm text-on-surface placeholder:text-outline focus-visible:border-primary-container"
              />
            </div>

            <div className="flex flex-col gap-1.5">
              <label htmlFor="access-key" className="text-label-md text-on-surface-variant">
                Tu clave
              </label>
              <input
                id="access-key"
                name="accessKey"
                type="password"
                autoComplete="current-password"
                placeholder="La que tú elegiste"
                value={accessKey}
                onChange={(event) => setAccessKey(event.target.value)}
                aria-describedby="access-key-help"
                className="min-h-[44px] w-full rounded-lg border border-outline-variant bg-surface px-3 text-body-md text-on-surface placeholder:text-outline focus-visible:border-primary-container"
              />
              <p id="access-key-help" className="text-label-sm text-on-surface-variant">
                Cualquier palabra que recuerdes sirve. No necesitas correo ni teléfono.
              </p>
            </div>

            {error && (
              <p role="alert" className="rounded-lg bg-error-container px-3 py-2 text-body-sm text-on-error-container">
                {error}
              </p>
            )}

            <button
              type="submit"
              disabled={!canSubmit}
              className="flex min-h-[44px] w-full items-center justify-center gap-2 rounded-lg bg-primary px-space-md text-title-md font-semibold text-on-primary transition-transform active:scale-[0.98] disabled:cursor-not-allowed disabled:opacity-40"
            >
              Entrar
              <span aria-hidden="true">→</span>
            </button>
          </form>
        </section>

        <section className="mt-space-md rounded-lg border border-outline-variant bg-surface-container-low p-space-md">
          <h2 className="text-title-md font-semibold text-on-surface">¿Primera vez aquí?</h2>
          <p className="mt-space-xs text-body-sm text-on-surface-variant">
            Si es tu primer ingreso, tu docente registrará tu curso contigo en clase.
          </p>
          <button
            type="button"
            disabled
            className="mt-space-sm flex min-h-[44px] w-full items-center justify-center rounded-lg border-[1.5px] border-outline-variant text-title-md font-semibold text-on-surface disabled:opacity-50"
          >
            Registrar mi curso
          </button>
        </section>

        {!supabaseReady && (
          <p className="mt-space-md rounded-lg bg-surface-container-high p-3 text-label-sm text-on-surface-variant">
            Modo sin conexión configurada: falta definir la URL y la clave de Supabase en
            <code className="mx-1 font-mono">.env.local</code>.
          </p>
        )}
      </main>
    </div>
  );
}
