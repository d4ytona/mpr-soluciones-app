import {
  View,
  Text,
  ScrollView,
  ActivityIndicator,
  RefreshControl,
  TouchableOpacity,
} from 'react-native';
import { useState, useCallback } from 'react';
import { useFocusEffect, router } from 'expo-router';
import { useObligations } from '../../hooks/useObligations';
import { UrgencyLevel } from '../../types/database';

export default function Obligations() {
  const [selectedFilter, setSelectedFilter] = useState<UrgencyLevel | 'all'>('all');
  const { obligations, loading, error, refetch } = useObligations();
  const [refreshing, setRefreshing] = useState(false);

  // Refetch obligations when screen comes into focus
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

  // Calculate statistics
  const stats = {
    overdue: obligations.filter((o) => o.urgency_level === 'overdue').length,
    urgent: obligations.filter((o) => o.urgency_level === 'urgent').length,
    soon: obligations.filter((o) => o.urgency_level === 'soon').length,
    completed: obligations.filter((o) => o.urgency_level === 'completed').length,
    total: obligations.length,
  };

  // Filter obligations based on selected filter
  const filteredObligations =
    selectedFilter === 'all'
      ? obligations
      : obligations.filter((o) => o.urgency_level === selectedFilter);

  // Get color classes based on urgency
  const getUrgencyColor = (urgency: UrgencyLevel) => {
    switch (urgency) {
      case 'overdue':
        return { bg: 'bg-red-100', text: 'text-red-800', border: 'border-red-200' };
      case 'urgent':
        return { bg: 'bg-orange-100', text: 'text-orange-800', border: 'border-orange-200' };
      case 'soon':
        return { bg: 'bg-yellow-100', text: 'text-yellow-800', border: 'border-yellow-200' };
      case 'completed':
        return { bg: 'bg-green-100', text: 'text-green-800', border: 'border-green-200' };
      default:
        return { bg: 'bg-blue-100', text: 'text-blue-800', border: 'border-blue-200' };
    }
  };

  const getUrgencyLabel = (urgency: UrgencyLevel) => {
    switch (urgency) {
      case 'overdue':
        return 'Vencida';
      case 'urgent':
        return 'Urgente';
      case 'soon':
        return 'Próxima';
      case 'completed':
        return 'Completada';
      default:
        return 'Normal';
    }
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('es-VE', {
      day: 'numeric',
      month: 'short',
      year: 'numeric',
    });
  };

  if (loading && !refreshing) {
    return (
      <View className="flex-1 bg-white items-center justify-center">
        <ActivityIndicator size="large" color="#3b82f6" />
        <Text className="text-gray-600 mt-4">Cargando obligaciones...</Text>
      </View>
    );
  }

  if (error) {
    return (
      <View className="flex-1 bg-white items-center justify-center px-6">
        <Text className="text-red-600 text-center mb-4">Error al cargar obligaciones</Text>
        <Text className="text-gray-600 text-center">{error}</Text>
        <TouchableOpacity
          className="bg-blue-600 rounded-lg px-6 py-3 mt-4"
          onPress={refetch}
        >
          <Text className="text-white font-semibold">Reintentar</Text>
        </TouchableOpacity>
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
          {/* Header */}
          <View className="mb-6">
            <Text className="text-2xl font-bold text-gray-900 mb-2">Obligaciones</Text>
            <Text className="text-gray-600">{stats.total} obligaciones en total</Text>
          </View>

          {/* Statistics Cards */}
          <View className="flex-row flex-wrap gap-3 mb-6">
            <View className="flex-1 min-w-[45%] bg-red-50 border border-red-200 rounded-lg p-4">
              <Text className="text-2xl font-bold text-red-800">{stats.overdue}</Text>
              <Text className="text-sm text-red-600 mt-1">Vencidas</Text>
            </View>
            <View className="flex-1 min-w-[45%] bg-orange-50 border border-orange-200 rounded-lg p-4">
              <Text className="text-2xl font-bold text-orange-800">{stats.urgent}</Text>
              <Text className="text-sm text-orange-600 mt-1">Urgentes</Text>
            </View>
            <View className="flex-1 min-w-[45%] bg-yellow-50 border border-yellow-200 rounded-lg p-4">
              <Text className="text-2xl font-bold text-yellow-800">{stats.soon}</Text>
              <Text className="text-sm text-yellow-600 mt-1">Próximas</Text>
            </View>
            <View className="flex-1 min-w-[45%] bg-green-50 border border-green-200 rounded-lg p-4">
              <Text className="text-2xl font-bold text-green-800">{stats.completed}</Text>
              <Text className="text-sm text-green-600 mt-1">Completadas</Text>
            </View>
          </View>

          {/* Filter Buttons */}
          <ScrollView horizontal showsHorizontalScrollIndicator={false} className="mb-6">
            <View className="flex-row gap-2">
              <TouchableOpacity
                className={`px-4 py-2 rounded-full border ${
                  selectedFilter === 'all'
                    ? 'bg-blue-600 border-blue-600'
                    : 'bg-white border-gray-300'
                }`}
                onPress={() => setSelectedFilter('all')}
              >
                <Text
                  className={`font-semibold ${
                    selectedFilter === 'all' ? 'text-white' : 'text-gray-700'
                  }`}
                >
                  Todas ({stats.total})
                </Text>
              </TouchableOpacity>
              <TouchableOpacity
                className={`px-4 py-2 rounded-full border ${
                  selectedFilter === 'overdue'
                    ? 'bg-red-600 border-red-600'
                    : 'bg-white border-gray-300'
                }`}
                onPress={() => setSelectedFilter('overdue')}
              >
                <Text
                  className={`font-semibold ${
                    selectedFilter === 'overdue' ? 'text-white' : 'text-gray-700'
                  }`}
                >
                  Vencidas ({stats.overdue})
                </Text>
              </TouchableOpacity>
              <TouchableOpacity
                className={`px-4 py-2 rounded-full border ${
                  selectedFilter === 'urgent'
                    ? 'bg-orange-600 border-orange-600'
                    : 'bg-white border-gray-300'
                }`}
                onPress={() => setSelectedFilter('urgent')}
              >
                <Text
                  className={`font-semibold ${
                    selectedFilter === 'urgent' ? 'text-white' : 'text-gray-700'
                  }`}
                >
                  Urgentes ({stats.urgent})
                </Text>
              </TouchableOpacity>
              <TouchableOpacity
                className={`px-4 py-2 rounded-full border ${
                  selectedFilter === 'completed'
                    ? 'bg-green-600 border-green-600'
                    : 'bg-white border-gray-300'
                }`}
                onPress={() => setSelectedFilter('completed')}
              >
                <Text
                  className={`font-semibold ${
                    selectedFilter === 'completed' ? 'text-white' : 'text-gray-700'
                  }`}
                >
                  Completadas ({stats.completed})
                </Text>
              </TouchableOpacity>
            </View>
          </ScrollView>

          {/* Obligations List */}
          {filteredObligations.length === 0 ? (
            <View className="bg-gray-50 rounded-lg p-8 items-center">
              <Text className="text-gray-500 text-center">
                {selectedFilter === 'all'
                  ? 'No hay obligaciones registradas'
                  : `No hay obligaciones ${getUrgencyLabel(selectedFilter as UrgencyLevel).toLowerCase()}`}
              </Text>
            </View>
          ) : (
            <View className="gap-4">
              {filteredObligations.map((obligation) => {
                const colors = getUrgencyColor(obligation.urgency_level);
                return (
                  <TouchableOpacity
                    key={obligation.obligation_id}
                    className={`bg-white border ${colors.border} rounded-lg p-5 shadow-sm`}
                    onPress={() =>
                      router.push(`/obligation-detail?id=${obligation.obligation_id}`)
                    }
                  >
                    {/* Header */}
                    <View className="flex-row justify-between items-start mb-3">
                      <View className="flex-1 mr-3">
                        <Text className="text-lg font-bold text-gray-900 mb-1 capitalize">
                          {obligation.obligation_name}
                        </Text>
                        <Text className="text-sm text-gray-600 capitalize">
                          {obligation.company_name}
                        </Text>
                      </View>
                      <View className={`${colors.bg} px-3 py-1 rounded-full`}>
                        <Text className={`text-xs font-semibold ${colors.text}`}>
                          {getUrgencyLabel(obligation.urgency_level)}
                        </Text>
                      </View>
                    </View>

                    {/* Details */}
                    <View className="gap-2">
                      <View className="flex-row items-center">
                        <Text className="text-sm text-gray-500 w-24">Período:</Text>
                        <Text className="text-sm font-medium text-gray-900 flex-1">
                          {obligation.period_formatted}
                        </Text>
                      </View>

                      <View className="flex-row items-center">
                        <Text className="text-sm text-gray-500 w-24">Vencimiento:</Text>
                        <Text className="text-sm font-medium text-gray-900 flex-1">
                          {formatDate(obligation.due_date)}
                          {obligation.days_until_due !== null && (
                            <Text
                              className={`text-xs ml-2 ${
                                obligation.days_until_due < 0
                                  ? 'text-red-600'
                                  : obligation.days_until_due <= 7
                                  ? 'text-orange-600'
                                  : 'text-gray-600'
                              }`}
                            >
                              {obligation.days_until_due < 0
                                ? `(${Math.abs(obligation.days_until_due)} días vencida)`
                                : obligation.days_until_due === 0
                                ? '(Vence hoy)'
                                : `(${obligation.days_until_due} días)`}
                            </Text>
                          )}
                        </Text>
                      </View>

                      <View className="flex-row items-center">
                        <Text className="text-sm text-gray-500 w-24">Estado:</Text>
                        <Text className="text-sm font-medium text-gray-900 flex-1 capitalize">
                          {obligation.obligation_status === 'pending'
                            ? 'Pendiente'
                            : obligation.obligation_status === 'in_progress'
                            ? 'En proceso'
                            : obligation.obligation_status === 'completed'
                            ? 'Completada'
                            : 'Cancelada'}
                        </Text>
                      </View>

                      {obligation.uploaded_by_name && (
                        <View className="flex-row items-center">
                          <Text className="text-sm text-gray-500 w-24">Subido por:</Text>
                          <Text className="text-sm font-medium text-gray-900 flex-1 capitalize">
                            {obligation.uploaded_by_name}
                          </Text>
                        </View>
                      )}

                      {obligation.notes && (
                        <View className="mt-2 pt-2 border-t border-gray-100">
                          <Text className="text-xs text-gray-500">Notas:</Text>
                          <Text className="text-sm text-gray-700 mt-1">{obligation.notes}</Text>
                        </View>
                      )}
                    </View>

                    {/* View details indicator */}
                    <View className="mt-3 pt-3 border-t border-gray-100">
                      <Text className="text-sm text-blue-600 font-semibold">
                        Ver detalles →
                      </Text>
                    </View>
                  </TouchableOpacity>
                );
              })}
            </View>
          )}
        </View>
      </ScrollView>
    </View>
  );
}
