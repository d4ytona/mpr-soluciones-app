import { Stack } from 'expo-router';
import { AuthProvider } from '../contexts/AuthContext';
import Toast from 'react-native-toast-message';
import '../global.css';

export default function RootLayout() {
  return (
    <AuthProvider>
      <Stack>
        <Stack.Screen name="index" options={{ headerShown: false }} />
        <Stack.Screen name="(auth)" options={{ headerShown: false }} />
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
        <Stack.Screen
          name="new-company"
          options={{
            presentation: 'modal',
            title: 'Nueva Empresa',
            headerShown: true,
          }}
        />
        <Stack.Screen
          name="obligation-detail"
          options={{
            presentation: 'card',
            title: 'Detalle de Obligación',
            headerShown: true,
          }}
        />
      </Stack>
      <Toast />
    </AuthProvider>
  );
}
