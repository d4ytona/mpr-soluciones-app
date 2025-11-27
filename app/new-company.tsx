import { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  ScrollView,
  ActivityIndicator,
} from 'react-native';
import { router } from 'expo-router';
import Toast from 'react-native-toast-message';
import { supabase } from '../lib/supabase';
import { useAuth } from '../contexts/AuthContext';

export default function NewCompany() {
  const { profile } = useAuth();
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    name: '',
    tax_id: '',
    email: '',
    phone: '',
    address: '',
  });

  const handleCreate = async () => {
    // Validation
    if (!formData.name || !formData.tax_id) {
      Toast.show({
        type: 'error',
        text1: 'Campos requeridos',
        text2: 'Nombre y RIF son obligatorios',
        position: 'top',
      });
      return;
    }

    if (!profile) {
      Toast.show({
        type: 'error',
        text1: 'Error',
        text2: 'No se encontró el perfil de usuario',
        position: 'top',
      });
      return;
    }

    setLoading(true);

    try {
      const { error } = await supabase.from('companies').insert({
        name: formData.name.toLowerCase(),
        tax_id: formData.tax_id.toLowerCase(),
        email: formData.email.toLowerCase() || null,
        phone: formData.phone || null,
        address: formData.address.toLowerCase() || null,
        created_by: profile.id,
        active: true,
      });

      if (error) {
        // Check for duplicate tax_id error (unique constraint violation)
        if (error.code === '23505' && error.message.includes('tax_id')) {
          Toast.show({
            type: 'error',
            text1: 'RIF duplicado',
            text2: 'Ya existe una empresa registrada con este RIF',
            position: 'top',
            visibilityTime: 4000,
          });
          return;
        }
        throw error;
      }

      Toast.show({
        type: 'success',
        text1: 'Empresa creada',
        text2: 'La empresa se creó correctamente',
        position: 'top',
        visibilityTime: 3000,
      });

      // Close modal and return to companies list
      // Using a small timeout to allow the user to see the success message
      setTimeout(() => {
        router.dismiss();
      }, 500);
    } catch (error) {
      console.error('Error creating company:', error);
      Toast.show({
        type: 'error',
        text1: 'Error al crear empresa',
        text2: error instanceof Error ? error.message : 'Ocurrió un error inesperado',
        position: 'top',
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <View className="flex-1 bg-white">
      <ScrollView className="flex-1">
        <View className="px-6 py-8">
          <View className="mb-8">
            <Text className="text-2xl font-bold text-gray-900 mb-2">Nueva Empresa</Text>
            <Text className="text-gray-600">Completa la información de la empresa</Text>
          </View>

          <View className="gap-4">
            <View>
              <Text className="text-sm font-medium text-gray-700 mb-2">
                Nombre <Text className="text-red-600">*</Text>
              </Text>
              <TextInput
                className="bg-gray-50 border border-gray-300 rounded-lg px-4 py-3 text-gray-900"
                placeholder="Empresa Demo C.A."
                value={formData.name}
                onChangeText={(text) => setFormData({ ...formData, name: text })}
                editable={!loading}
              />
            </View>

            <View>
              <Text className="text-sm font-medium text-gray-700 mb-2">
                RIF <Text className="text-red-600">*</Text>
              </Text>
              <TextInput
                className="bg-gray-50 border border-gray-300 rounded-lg px-4 py-3 text-gray-900"
                placeholder="J-12345678-9"
                value={formData.tax_id}
                onChangeText={(text) => setFormData({ ...formData, tax_id: text })}
                editable={!loading}
                autoCapitalize="characters"
              />
            </View>

            <View>
              <Text className="text-sm font-medium text-gray-700 mb-2">Email</Text>
              <TextInput
                className="bg-gray-50 border border-gray-300 rounded-lg px-4 py-3 text-gray-900"
                placeholder="contacto@empresa.com"
                value={formData.email}
                onChangeText={(text) => setFormData({ ...formData, email: text })}
                editable={!loading}
                keyboardType="email-address"
                autoCapitalize="none"
              />
            </View>

            <View>
              <Text className="text-sm font-medium text-gray-700 mb-2">Teléfono</Text>
              <TextInput
                className="bg-gray-50 border border-gray-300 rounded-lg px-4 py-3 text-gray-900"
                placeholder="0414-1234567"
                value={formData.phone}
                onChangeText={(text) => setFormData({ ...formData, phone: text })}
                editable={!loading}
                keyboardType="phone-pad"
              />
            </View>

            <View>
              <Text className="text-sm font-medium text-gray-700 mb-2">Dirección</Text>
              <TextInput
                className="bg-gray-50 border border-gray-300 rounded-lg px-4 py-3 text-gray-900"
                placeholder="Calle principal, Edificio X, Piso Y"
                value={formData.address}
                onChangeText={(text) => setFormData({ ...formData, address: text })}
                editable={!loading}
                multiline
                numberOfLines={3}
                textAlignVertical="top"
              />
            </View>
          </View>

          <View className="flex-row gap-3 mt-8">
            <TouchableOpacity
              className="flex-1 bg-gray-200 rounded-lg py-3.5"
              onPress={() => router.dismiss()}
              disabled={loading}
            >
              <Text className="text-gray-800 text-center font-semibold text-base">
                Cancelar
              </Text>
            </TouchableOpacity>

            <TouchableOpacity
              className={`flex-1 bg-blue-600 rounded-lg py-3.5 ${loading ? 'opacity-50' : ''}`}
              onPress={handleCreate}
              disabled={loading}
            >
              {loading ? (
                <ActivityIndicator color="white" />
              ) : (
                <Text className="text-white text-center font-semibold text-base">
                  Crear Empresa
                </Text>
              )}
            </TouchableOpacity>
          </View>
        </View>
      </ScrollView>
    </View>
  );
}
