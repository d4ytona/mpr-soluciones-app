import { View, Text, ScrollView, ActivityIndicator, RefreshControl, TouchableOpacity } from 'react-native';
import { useState } from 'react';
import { router, useFocusEffect } from 'expo-router';
import { useCallback } from 'react';
import { useCompanies } from '../../hooks/useCompanies';
import { useAuth } from '../../contexts/AuthContext';
import { supabase } from '../../lib/supabase';
import Toast from 'react-native-toast-message';

export default function Companies() {
  const { companies, loading, error, refetch } = useCompanies();
  const { profile } = useAuth();
  const [refreshing, setRefreshing] = useState(false);
  const [assigningTo, setAssigningTo] = useState<number | null>(null);

  // Refetch companies when screen comes into focus
  useFocusEffect(
    useCallback(() => {
      refetch();
    }, [refetch])
  );

  const onRefresh = async () => {
    setRefreshing(true);
    await refetch();
    setRefreshing(false);
  };

  const handleSelfAssign = async (companyId: number) => {
    if (!profile || profile.role !== 'accountant') {
      Toast.show({
        type: 'error',
        text1: 'No autorizado',
        text2: 'Solo los contadores pueden asignarse a empresas',
        position: 'top',
      });
      return;
    }

    try {
      setAssigningTo(companyId);

      const { error } = await supabase
        .from('companies')
        .update({
          assigned_accountant: profile.id,
          assigned_to: profile.id, // Also update the old field for backward compatibility
        })
        .eq('id', companyId);

      if (error) throw error;

      Toast.show({
        type: 'success',
        text1: 'Asignación exitosa',
        text2: 'Te has asignado a esta empresa',
        position: 'top',
      });

      // Refresh the companies list
      await refetch();
    } catch (error) {
      console.error('Error assigning company:', error);
      Toast.show({
        type: 'error',
        text1: 'Error',
        text2: 'No se pudo asignar a la empresa',
        position: 'top',
      });
    } finally {
      setAssigningTo(null);
    }
  };

  if (loading && !refreshing) {
    return (
      <View className="flex-1 bg-white items-center justify-center">
        <ActivityIndicator size="large" color="#3b82f6" />
        <Text className="text-gray-600 mt-4">Cargando empresas...</Text>
      </View>
    );
  }

  if (error) {
    return (
      <View className="flex-1 bg-white items-center justify-center px-6">
        <Text className="text-red-600 text-center mb-4">Error al cargar empresas</Text>
        <Text className="text-gray-600 text-center">{error}</Text>
      </View>
    );
  }

  return (
    <View className="flex-1 bg-white">
      <ScrollView
        className="flex-1"
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} colors={['#3b82f6']} />
        }
      >
      <View className="px-6 py-8">
        <View className="mb-6">
          <Text className="text-2xl font-bold text-gray-900 mb-2">Empresas</Text>
          <Text className="text-gray-600">
            {companies.length} {companies.length === 1 ? 'empresa registrada' : 'empresas registradas'}
          </Text>
        </View>

        {companies.length === 0 ? (
          <View className="bg-gray-50 rounded-lg p-8 items-center">
            <Text className="text-gray-500 text-center">No hay empresas registradas</Text>
          </View>
        ) : (
          <View className="gap-4">
            {companies.map((company) => (
              <View key={company.id} className="bg-white border border-gray-200 rounded-lg p-5 shadow-sm">
                <Text className="text-lg font-bold text-gray-900 mb-3 capitalize">
                  {company.name}
                </Text>

                <View className="gap-2">
                  <View className="flex-row items-center">
                    <Text className="text-sm text-gray-500 w-20">RIF:</Text>
                    <Text className="text-sm font-medium text-gray-900 uppercase flex-1">
                      {company.tax_id}
                    </Text>
                  </View>

                  {company.email && (
                    <View className="flex-row items-center">
                      <Text className="text-sm text-gray-500 w-20">Email:</Text>
                      <Text className="text-sm font-medium text-gray-900 flex-1">
                        {company.email}
                      </Text>
                    </View>
                  )}

                  {company.phone && (
                    <View className="flex-row items-center">
                      <Text className="text-sm text-gray-500 w-20">Teléfono:</Text>
                      <Text className="text-sm font-medium text-gray-900 flex-1">
                        {company.phone}
                      </Text>
                    </View>
                  )}

                  {company.address && (
                    <View className="flex-row">
                      <Text className="text-sm text-gray-500 w-20">Dirección:</Text>
                      <Text className="text-sm font-medium text-gray-900 flex-1 capitalize">
                        {company.address}
                      </Text>
                    </View>
                  )}
                </View>

                <View className="mt-3 pt-3 border-t border-gray-100">
                  {company.accountant ? (
                    <View>
                      <Text className="text-xs text-gray-500 mb-1">Contador asignado:</Text>
                      <View className="bg-green-100 self-start px-3 py-1 rounded-full">
                        <Text className="text-green-800 text-xs font-semibold capitalize">
                          {company.accountant.first_name} {company.accountant.last_name}
                        </Text>
                      </View>
                    </View>
                  ) : (
                    <View className="flex-row items-center justify-between">
                      <View className="bg-yellow-100 px-3 py-1 rounded-full">
                        <Text className="text-yellow-800 text-xs font-semibold">
                          Sin contador asignado
                        </Text>
                      </View>
                      {profile?.role === 'accountant' && (
                        <TouchableOpacity
                          className={`bg-blue-600 rounded-lg px-4 py-2 ${assigningTo === company.id ? 'opacity-50' : ''}`}
                          onPress={() => handleSelfAssign(company.id)}
                          disabled={assigningTo === company.id}
                        >
                          {assigningTo === company.id ? (
                            <ActivityIndicator size="small" color="white" />
                          ) : (
                            <Text className="text-white text-xs font-semibold">
                              Asignarme
                            </Text>
                          )}
                        </TouchableOpacity>
                      )}
                    </View>
                  )}
                </View>
              </View>
            ))}
          </View>
        )}
      </View>
    </ScrollView>

    {/* Floating Action Button */}
    <TouchableOpacity
      className="absolute bottom-6 right-6 bg-blue-600 w-14 h-14 rounded-full items-center justify-center shadow-lg"
      onPress={() => router.push('/new-company')}
    >
      <Text className="text-white text-3xl font-light">+</Text>
    </TouchableOpacity>
  </View>
  );
}
