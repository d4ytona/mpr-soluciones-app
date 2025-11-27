import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  ActivityIndicator,
  RefreshControl,
} from 'react-native';
import { router } from 'expo-router';
import { useNotifications } from '../hooks/useNotifications';
import Toast from 'react-native-toast-message';

export default function Notifications() {
  const { notifications, unreadCount, loading, refetch, markAsRead, markAllAsRead, deleteNotification } =
    useNotifications();

  const handleNotificationPress = async (notification: typeof notifications[0]) => {
    try {
      // Mark as read
      if (!notification.is_read) {
        await markAsRead(notification.id);
      }

      // Navigate to obligation if it exists
      if (notification.obligation_id) {
        router.push(`/obligation-detail?id=${notification.obligation_id}`);
      }
    } catch (error) {
      Toast.show({
        type: 'error',
        text1: 'Error',
        text2: 'No se pudo marcar la notificación como leída',
        position: 'top',
      });
    }
  };

  const handleMarkAllAsRead = async () => {
    try {
      await markAllAsRead();
      Toast.show({
        type: 'success',
        text1: 'Notificaciones marcadas',
        text2: 'Todas las notificaciones se marcaron como leídas',
        position: 'top',
      });
    } catch (error) {
      Toast.show({
        type: 'error',
        text1: 'Error',
        text2: 'No se pudieron marcar las notificaciones',
        position: 'top',
      });
    }
  };

  const handleDeleteNotification = async (notificationId: number, event: any) => {
    event.stopPropagation();
    try {
      await deleteNotification(notificationId);
      Toast.show({
        type: 'success',
        text1: 'Notificación eliminada',
        position: 'top',
      });
    } catch (error) {
      Toast.show({
        type: 'error',
        text1: 'Error',
        text2: 'No se pudo eliminar la notificación',
        position: 'top',
      });
    }
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffInMs = now.getTime() - date.getTime();
    const diffInMinutes = Math.floor(diffInMs / 1000 / 60);
    const diffInHours = Math.floor(diffInMinutes / 60);
    const diffInDays = Math.floor(diffInHours / 24);

    if (diffInMinutes < 1) {
      return 'Ahora';
    } else if (diffInMinutes < 60) {
      return `Hace ${diffInMinutes} min`;
    } else if (diffInHours < 24) {
      return `Hace ${diffInHours} h`;
    } else if (diffInDays < 7) {
      return `Hace ${diffInDays} d`;
    } else {
      return date.toLocaleDateString('es-VE', {
        day: 'numeric',
        month: 'short',
      });
    }
  };

  if (loading) {
    return (
      <View className="flex-1 bg-white items-center justify-center">
        <ActivityIndicator size="large" color="#3b82f6" />
        <Text className="text-gray-600 mt-4">Cargando notificaciones...</Text>
      </View>
    );
  }

  return (
    <View className="flex-1 bg-white">
      {/* Header */}
      <View className="px-6 py-8 border-b border-gray-200">
        <View className="flex-row items-center justify-between mb-4">
          <TouchableOpacity onPress={() => router.back()}>
            <Text className="text-blue-600 font-semibold">← Volver</Text>
          </TouchableOpacity>
          {unreadCount > 0 && (
            <TouchableOpacity onPress={handleMarkAllAsRead}>
              <Text className="text-blue-600 font-semibold">Marcar todas como leídas</Text>
            </TouchableOpacity>
          )}
        </View>
        <Text className="text-2xl font-bold text-gray-900">Notificaciones</Text>
        {unreadCount > 0 && (
          <Text className="text-gray-600 mt-1">{unreadCount} sin leer</Text>
        )}
      </View>

      {/* Notifications List */}
      <ScrollView
        className="flex-1"
        refreshControl={<RefreshControl refreshing={loading} onRefresh={refetch} />}
      >
        {notifications.length === 0 ? (
          <View className="flex-1 items-center justify-center py-16">
            <Text className="text-gray-400 text-lg mb-2">📭</Text>
            <Text className="text-gray-600 text-center">No tienes notificaciones</Text>
          </View>
        ) : (
          <View className="px-6 py-4">
            {notifications.map((notification) => (
              <TouchableOpacity
                key={notification.id}
                className={`border rounded-lg p-4 mb-3 ${
                  notification.is_read
                    ? 'bg-white border-gray-200'
                    : 'bg-blue-50 border-blue-200'
                }`}
                onPress={() => handleNotificationPress(notification)}
              >
                <View className="flex-row items-start justify-between mb-2">
                  <View className="flex-1">
                    <View className="flex-row items-center">
                      {!notification.is_read && (
                        <View className="w-2 h-2 rounded-full bg-blue-600 mr-2" />
                      )}
                      <Text
                        className={`text-base font-semibold ${
                          notification.is_read ? 'text-gray-900' : 'text-blue-900'
                        }`}
                      >
                        {notification.title}
                      </Text>
                    </View>
                  </View>
                  <TouchableOpacity
                    onPress={(e) => handleDeleteNotification(notification.id, e)}
                    className="ml-2 p-1"
                  >
                    <Text className="text-gray-400 text-lg">×</Text>
                  </TouchableOpacity>
                </View>

                <Text className="text-gray-700 text-sm mb-2">{notification.message}</Text>

                {notification.company_name && (
                  <Text className="text-gray-500 text-xs mb-1 capitalize">
                    {notification.company_name}
                  </Text>
                )}

                <View className="flex-row items-center justify-between mt-1">
                  <Text className="text-gray-400 text-xs">
                    {formatDate(notification.created_at)}
                  </Text>
                  {notification.obligation_id && (
                    <Text className="text-blue-600 text-xs font-medium">Ver detalles →</Text>
                  )}
                </View>
              </TouchableOpacity>
            ))}
          </View>
        )}
      </ScrollView>
    </View>
  );
}
