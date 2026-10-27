/**
 * Persistencia local del dispositivo.
 *
 * La sesión de Supabase ya se guarda sola; aquí solo vive lo que debe
 * sobrevivir sin conexión y no depende del servidor.
 */

const KEY = {
  lastCode: 'ova-ia:last-code',
  deviceMode: 'ova-ia:device-mode',
  pendingQueue: 'ova-ia:pending-events',
} as const;

export type DeviceMode = 'personal' | 'tablet';

export const localStore = {
  getLastCode(): string | null {
    try {
      return localStorage.getItem(KEY.lastCode);
    } catch {
      return null;
    }
  },

  setLastCode(code: string): void {
    try {
      localStorage.setItem(KEY.lastCode, code);
    } catch {
      /* modo privado del navegador */
    }
  },

  getDeviceMode(): DeviceMode {
    try {
      return (localStorage.getItem(KEY.deviceMode) as DeviceMode) ?? 'personal';
    } catch {
      return 'personal';
    }
  },

  setDeviceMode(mode: DeviceMode): void {
    try {
      localStorage.setItem(KEY.deviceMode, mode);
    } catch {
      /* ignore */
    }
  },

  getPendingEvents<T>(): T[] {
    try {
      const raw = localStorage.getItem(KEY.pendingQueue);
      return raw ? (JSON.parse(raw) as T[]) : [];
    } catch {
      return [];
    }
  },

  setPendingEvents<T>(items: T[]): void {
    try {
      localStorage.setItem(KEY.pendingQueue, JSON.stringify(items));
    } catch {
      /* ignore */
    }
  },
};
