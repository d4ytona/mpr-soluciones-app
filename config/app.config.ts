// app.config.ts
import 'dotenv/config'; // Carga automáticamente variables desde .env
import { ExpoConfig, ConfigContext } from '@expo/config';

export default ({ config }: ConfigContext): ExpoConfig => ({
  ...config, // Mantiene cualquier configuración base que Expo genere
  name: 'mpr-soluciones-app', // Nombre de la app
  slug: 'mpr-soluciones-app', // Identificador del proyecto
  version: '1.0.0', // Versión inicial
  orientation: 'portrait', // Solo modo vertical
  userInterfaceStyle: 'light', // Tema claro por defecto
  newArchEnabled: true, // Activar nueva arquitectura de React Native

  splash: {
    resizeMode: 'contain',
    backgroundColor: '#ffffff', // Color de fondo para pantalla de inicio
  },

  ios: {
    supportsTablet: true, // Habilitar soporte tablet
  },

  android: {
    adaptiveIcon: {
      backgroundColor: '#ffffff', // Fondo de icono adaptativo
    },
    edgeToEdgeEnabled: true, // Permitir navegación edge-to-edge
    predictiveBackGestureEnabled: false, // Desactivar gestos predictivos de volver
  },

  web: {}, // Configuración web por defecto

  extra: {
    // Pasamos las variables sensibles de entorno a la app
    SUPABASE_PROJECT_URL: process.env.SUPABASE_PROJECT_URL,
    SUPABASE_ANON_API_KEY: process.env.SUPABASE_ANON_API_KEY,
    SUPABASE_SERVICE_ROLE: process.env.SUPABASE_SERVICE_ROLE,
    R2_ACCOUNT_ID: process.env.R2_ACCOUNT_ID,
    R2_TOKEN_VALUE: process.env.R2_TOKEN_VALUE,
    R2_ACCESS_KEY_ID: process.env.R2_ACCESS_KEY_ID,
    R2_SECRET_ACCES_KEY: process.env.R2_SECRET_ACCES_KEY,
  },
});
