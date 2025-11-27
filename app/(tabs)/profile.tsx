import { View, Text, TouchableOpacity, ActivityIndicator, ScrollView } from 'react-native';
import { useState, useCallback } from 'react';
import { router, useFocusEffect } from 'expo-router';
import Toast from 'react-native-toast-message';
import { useAuth } from '../../contexts/AuthContext';
import { useNotifications } from '../../hooks/useNotifications';

// Role labels in Spanish
const roleLabels: Record<string, string> = {
  client: 'Cliente',
  accountant: 'Contador',
  boss: 'Jefe',
  admin: 'Administrador',
};

export default function Profile() {
  const { profile, profileLoading, signOut } = useAuth();
  const { unreadCount, refetch } = useNotifications({ limit: 50 });
  const [showLogoutConfirm, setShowLogoutConfirm] = useState(false);
  const [isLoggingOut, setIsLoggingOut] = useState(false);

  // Refetch notifications when screen comes into focus
  useFocusEffect(
    useCallback(() => {
      refetch();
    }, [refetch])
  );

  const handleSignOut = () => {
    setShowLogoutConfirm(true);
  };

  const confirmSignOut = async () => {
    setIsLoggingOut(true);
    await signOut();
    Toast.show({
      type: 'success',
      text1: 'Sesión cerrada',
      text2: 'Has cerrado sesión exitosamente',
      position: 'top',
      visibilityTime: 2000,
    });
    setTimeout(() => {
      router.replace('/(auth)/login');
    }, 300);
  };

  const cancelSignOut = () => {
    setShowLogoutConfirm(false);
  };

  if (profileLoading) {
    return (
      <View className="flex-1 bg-white items-center justify-center">
        <ActivityIndicator size="large" color="#3b82f6" />
        <Text className="text-gray-600 mt-4">Cargando perfil...</Text>
      </View>
    );
  }

  return (
    <ScrollView className="flex-1 bg-white">
      <View className="px-6 py-8">
        <View className="mb-8">
          <View className="flex-row items-center justify-between mb-2">
            <Text className="text-2xl font-bold text-gray-900">Perfil</Text>
            <TouchableOpacity
              className="relative"
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
          <Text className="text-gray-600">Gestiona tu cuenta</Text>
        </View>

        {!profile && !profileLoading && (
          <View className="bg-yellow-50 border border-yellow-200 rounded-lg p-6 mb-4">
            <Text className="text-yellow-800 font-semibold mb-2">
              ⚠️ Perfil no encontrado
            </Text>
            <Text className="text-yellow-700 text-sm mb-3">
              No se encontró tu perfil en la base de datos. Esto puede suceder si:
            </Text>
            <Text className="text-yellow-700 text-sm ml-4 mb-1">
              • Tu cuenta fue creada recientemente
            </Text>
            <Text className="text-yellow-700 text-sm ml-4 mb-1">
              • No se completó el registro en la tabla de usuarios
            </Text>
            <Text className="text-yellow-700 text-sm ml-4 mb-3">
              • Hay un problema de sincronización
            </Text>
            <Text className="text-yellow-700 text-sm font-medium">
              Por favor contacta al administrador del sistema.
            </Text>
          </View>
        )}

        {profile && (
          <>
            <View className="bg-gray-50 rounded-lg p-6 mb-4">
              <Text className="text-sm text-gray-500 mb-1">Nombre completo</Text>
              <Text className="text-base font-medium text-gray-900 capitalize">
                {profile.first_name} {profile.last_name}
              </Text>
            </View>

            <View className="bg-gray-50 rounded-lg p-6 mb-4">
              <Text className="text-sm text-gray-500 mb-1">Email</Text>
              <Text className="text-base font-medium text-gray-900">{profile.email}</Text>
            </View>

            <View className="bg-gray-50 rounded-lg p-6 mb-4">
              <Text className="text-sm text-gray-500 mb-1">Rol</Text>
              <View className="mt-1">
                <View className="bg-blue-100 self-start px-3 py-1 rounded-full">
                  <Text className="text-blue-800 font-semibold text-sm">
                    {roleLabels[profile.role] || profile.role}
                  </Text>
                </View>
              </View>
            </View>

            <View className="bg-gray-50 rounded-lg p-6 mb-4">
              <Text className="text-sm text-gray-500 mb-1">Cédula</Text>
              <Text className="text-base font-medium text-gray-900 uppercase">
                {profile.id_type}-{profile.id_number}
              </Text>
            </View>

            {profile.phone && (
              <View className="bg-gray-50 rounded-lg p-6 mb-4">
                <Text className="text-sm text-gray-500 mb-1">Teléfono</Text>
                <Text className="text-base font-medium text-gray-900">{profile.phone}</Text>
              </View>
            )}

            {profile.birth_date && (
              <View className="bg-gray-50 rounded-lg p-6 mb-4">
                <Text className="text-sm text-gray-500 mb-1">Fecha de nacimiento</Text>
                <Text className="text-base font-medium text-gray-900">
                  {new Date(profile.birth_date).toLocaleDateString('es-VE')}
                </Text>
              </View>
            )}
          </>
        )}

        <TouchableOpacity
          className="bg-red-600 rounded-lg py-3.5 mt-4"
          onPress={handleSignOut}
          disabled={isLoggingOut}
        >
          <Text className="text-white text-center font-semibold text-base">
            Cerrar Sesión
          </Text>
        </TouchableOpacity>
      </View>

      {/* Logout Confirmation Modal */}
      {showLogoutConfirm && (
        <View className="absolute inset-0 bg-black/50 items-center justify-center px-6">
          <View className="bg-white rounded-lg p-6 w-full max-w-sm shadow-xl">
            <Text className="text-xl font-bold text-gray-900 mb-2">
              Cerrar sesión
            </Text>
            <Text className="text-gray-600 mb-6">
              ¿Estás seguro que deseas cerrar sesión?
            </Text>

            <View className="flex-row gap-3">
              <TouchableOpacity
                className="flex-1 bg-gray-200 rounded-lg py-3"
                onPress={cancelSignOut}
                disabled={isLoggingOut}
              >
                <Text className="text-gray-800 text-center font-semibold">
                  Cancelar
                </Text>
              </TouchableOpacity>

              <TouchableOpacity
                className={`flex-1 bg-red-600 rounded-lg py-3 ${isLoggingOut ? 'opacity-50' : ''}`}
                onPress={confirmSignOut}
                disabled={isLoggingOut}
              >
                {isLoggingOut ? (
                  <ActivityIndicator color="white" size="small" />
                ) : (
                  <Text className="text-white text-center font-semibold">
                    Sí, cerrar
                  </Text>
                )}
              </TouchableOpacity>
            </View>
          </View>
        </View>
      )}
    </ScrollView>
  );
}
