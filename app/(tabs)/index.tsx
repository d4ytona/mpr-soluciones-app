import { View, Text, ActivityIndicator, TouchableOpacity } from 'react-native';
import { router, useFocusEffect } from 'expo-router';
import { useCallback } from 'react';
import { useAuth } from '../../contexts/AuthContext';
import { useNotifications } from '../../hooks/useNotifications';

// Role labels in Spanish
const roleLabels: Record<string, string> = {
  client: 'Cliente',
  accountant: 'Contador',
  boss: 'Jefe',
  admin: 'Administrador',
};

export default function Home() {
  const { user, profile, profileLoading } = useAuth();
  const { unreadCount, refetch } = useNotifications({ limit: 50 });

  // Refetch notifications when screen comes into focus
  useFocusEffect(
    useCallback(() => {
      refetch();
    }, [refetch])
  );

  if (profileLoading) {
    return (
      <View className="flex-1 bg-white items-center justify-center">
        <ActivityIndicator size="large" color="#3b82f6" />
        <Text className="text-gray-600 mt-4">Cargando...</Text>
      </View>
    );
  }

  return (
    <View className="flex-1 bg-white">
      {/* Header with notification bell */}
      <View className="px-6 pt-8 pb-4 flex-row items-start justify-between">
        <View className="flex-1">
          <Text className="text-2xl font-bold text-gray-900 mb-2 capitalize">
            Hola, {profile?.first_name || 'Usuario'}
          </Text>
          <Text className="text-gray-600">
            {user?.email}
          </Text>
          {profile?.role && (
            <View className="mt-2">
              <View className="bg-blue-100 self-start px-3 py-1.5 rounded-full">
                <Text className="text-blue-800 font-semibold text-xs">
                  {roleLabels[profile.role] || profile.role}
                </Text>
              </View>
            </View>
          )}
        </View>

        {/* Notification Bell */}
        <TouchableOpacity
          className="relative ml-4"
          onPress={() => router.push('/notifications')}
        >
          <Text className="text-3xl">🔔</Text>
          {unreadCount > 0 && (
            <View className="absolute -top-1 -right-1 bg-red-600 rounded-full min-w-[20px] h-5 items-center justify-center px-1">
              <Text className="text-white text-xs font-bold">
                {unreadCount > 9 ? '9+' : unreadCount}
              </Text>
            </View>
          )}
        </TouchableOpacity>
      </View>

      <View className="px-6 pb-8">
        <View className="bg-blue-50 rounded-lg p-6 border border-blue-200">
          <Text className="text-lg font-semibold text-blue-900 mb-2">
            Dashboard
          </Text>
          <Text className="text-blue-700">
            Aquí verás tus documentos, obligaciones y más.
          </Text>
        </View>

        {!profile && (
          <View className="mt-6 bg-yellow-50 border border-yellow-200 rounded-lg p-4">
            <Text className="text-yellow-800 font-semibold mb-1">
              ⚠️ Perfil incompleto
            </Text>
            <Text className="text-yellow-700 text-sm">
              No se encontró tu perfil en la base de datos. Por favor contacta al administrador.
            </Text>
          </View>
        )}
      </View>
    </View>
  );
}
