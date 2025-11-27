import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  ActivityIndicator,
} from 'react-native';
import { useState, useEffect } from 'react';
import { router, useLocalSearchParams } from 'expo-router';
import { supabase } from '../lib/supabase';
import { useAuth } from '../contexts/AuthContext';
import { ObligationDashboard } from '../types/database';
import Toast from 'react-native-toast-message';

interface RequiredDocument {
  id: number;
  name: string;
  category_type: string;
  is_mandatory: boolean;
  notes: string | null;
}

export default function ObligationDetail() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const { profile } = useAuth();
  const [obligation, setObligation] = useState<ObligationDashboard | null>(null);
  const [requiredInputDocs, setRequiredInputDocs] = useState<RequiredDocument[]>([]);
  const [requiredLegalDocs, setRequiredLegalDocs] = useState<RequiredDocument[]>([]);
  const [checkedDocs, setCheckedDocs] = useState<Record<number, boolean>>({});
  const [loading, setLoading] = useState(true);
  const [uploading, setUploading] = useState(false);

  useEffect(() => {
    if (id) {
      fetchObligationDetails();
    }
  }, [id]);

  const fetchObligationDetails = async () => {
    try {
      setLoading(true);

      // Fetch obligation details
      const { data: obligationData, error: obligationError } = await supabase
        .from('v_obligations_dashboard')
        .select('*')
        .eq('obligation_id', id)
        .single();

      if (obligationError) throw obligationError;

      setObligation(obligationData as ObligationDashboard);

      // Fetch required documents for this obligation type
      const { data: requiredDocs, error: requiredError } = await supabase
        .from('output_required_inputs')
        .select(`
          id,
          is_mandatory,
          notes,
          required_input_document_type:document_types!required_input_document_type_id (
            id,
            name,
            category_type
          )
        `)
        .eq('output_document_type_id', obligationData.document_type_id)
        .eq('active', true);

      if (!requiredError && requiredDocs) {
        // Separate input and legal documents
        const inputDocs: RequiredDocument[] = [];
        const legalDocs: RequiredDocument[] = [];

        requiredDocs.forEach((doc: any) => {
          const docType = doc.required_input_document_type;
          const requiredDoc: RequiredDocument = {
            id: docType.id,
            name: docType.name,
            category_type: docType.category_type,
            is_mandatory: doc.is_mandatory,
            notes: doc.notes,
          };

          if (docType.category_type === 'input') {
            inputDocs.push(requiredDoc);
          } else if (docType.category_type === 'legal') {
            legalDocs.push(requiredDoc);
          }
        });

        setRequiredInputDocs(inputDocs);
        setRequiredLegalDocs(legalDocs);

        // Initialize all mandatory docs as unchecked
        const initialChecked: Record<number, boolean> = {};
        [...inputDocs, ...legalDocs].forEach((doc) => {
          initialChecked[doc.id] = false;
        });
        setCheckedDocs(initialChecked);
      }

    } catch (error) {
      console.error('Error fetching obligation details:', error);
      Toast.show({
        type: 'error',
        text1: 'Error',
        text2: 'No se pudo cargar la información de la obligación',
        position: 'top',
      });
    } finally {
      setLoading(false);
    }
  };

  const getUrgencyColor = (urgency: string) => {
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

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('es-VE', {
      day: 'numeric',
      month: 'long',
      year: 'numeric',
    });
  };

  const toggleDocumentCheck = (docId: number) => {
    setCheckedDocs((prev) => ({
      ...prev,
      [docId]: !prev[docId],
    }));
  };

  const handleUploadInputDocument = () => {
    Toast.show({
      type: 'info',
      text1: 'Próximamente',
      text2: 'La función de subir documentos estará disponible pronto',
      position: 'top',
    });
  };

  const handleUploadOutputDocument = async () => {
    try {
      setUploading(true);

      // TODO: Implement actual file upload
      // For now, we'll simulate the upload with a mock URL
      const mockFileUrl = `https://example.com/output-${obligation?.obligation_id}-${Date.now()}.pdf`;

      // Update the obligation status to completed and add file_url
      const { error } = await supabase
        .from('output_documents')
        .update({
          obligation_status: 'completed',
          file_url: mockFileUrl,
          uploaded_by: profile?.id,
          updated_at: new Date().toISOString(),
        })
        .eq('id', obligation?.obligation_id);

      if (error) throw error;

      Toast.show({
        type: 'success',
        text1: 'Documento subido',
        text2: 'La obligación ha sido marcada como completada',
        position: 'top',
      });

      // Refresh the obligation details
      await fetchObligationDetails();
    } catch (error) {
      console.error('Error uploading document:', error);
      Toast.show({
        type: 'error',
        text1: 'Error',
        text2: 'No se pudo subir el documento',
        position: 'top',
      });
    } finally {
      setUploading(false);
    }
  };

  if (loading) {
    return (
      <View className="flex-1 bg-white items-center justify-center">
        <ActivityIndicator size="large" color="#3b82f6" />
        <Text className="text-gray-600 mt-4">Cargando detalles...</Text>
      </View>
    );
  }

  if (!obligation) {
    return (
      <View className="flex-1 bg-white items-center justify-center px-6">
        <Text className="text-red-600 text-center mb-4">Obligación no encontrada</Text>
        <TouchableOpacity
          className="bg-blue-600 rounded-lg px-6 py-3"
          onPress={() => router.back()}
        >
          <Text className="text-white font-semibold">Volver</Text>
        </TouchableOpacity>
      </View>
    );
  }

  const colors = getUrgencyColor(obligation.urgency_level);
  const canUploadOutput =
    profile?.role === 'accountant' || profile?.role === 'boss' || profile?.role === 'admin';
  const canUploadInput = true; // Both client and accountant can upload

  // Check if all mandatory documents are checked
  const allMandatoryDocs = [...requiredInputDocs, ...requiredLegalDocs].filter(
    (doc) => doc.is_mandatory
  );
  const allMandatoryChecked = allMandatoryDocs.every((doc) => checkedDocs[doc.id] === true);
  const hasAllRequiredInputs = allMandatoryChecked;

  return (
    <ScrollView className="flex-1 bg-white">
      <View className="px-6 py-8">
        {/* Back button */}
        <TouchableOpacity onPress={() => router.back()} className="mb-6">
          <Text className="text-blue-600 font-semibold">← Volver a obligaciones</Text>
        </TouchableOpacity>

        {/* Header */}
        <View className="mb-6">
          <View className="flex-row justify-between items-start mb-3">
            <View className="flex-1 mr-3">
              <Text className="text-2xl font-bold text-gray-900 mb-2 capitalize">
                {obligation.obligation_name}
              </Text>
              <Text className="text-lg text-gray-600 capitalize">{obligation.company_name}</Text>
            </View>
            <View className={`${colors.bg} px-3 py-2 rounded-full`}>
              <Text className={`text-sm font-semibold ${colors.text}`}>
                {obligation.urgency_level === 'overdue'
                  ? 'Vencida'
                  : obligation.urgency_level === 'urgent'
                  ? 'Urgente'
                  : obligation.urgency_level === 'soon'
                  ? 'Próxima'
                  : obligation.urgency_level === 'completed'
                  ? 'Completada'
                  : 'Normal'}
              </Text>
            </View>
          </View>
        </View>

        {/* Obligation Details */}
        <View className="bg-gray-50 rounded-lg p-5 mb-6">
          <Text className="text-lg font-bold text-gray-900 mb-4">Detalles de la Obligación</Text>

          <View className="gap-3">
            <View>
              <Text className="text-sm text-gray-500 mb-1">Período</Text>
              <Text className="text-base font-medium text-gray-900">
                {obligation.period_formatted}
              </Text>
            </View>

            <View>
              <Text className="text-sm text-gray-500 mb-1">Fecha de Vencimiento</Text>
              <Text className="text-base font-medium text-gray-900">
                {formatDate(obligation.due_date)}
                {obligation.days_until_due !== null && (
                  <Text
                    className={`text-sm ml-2 ${
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

            <View>
              <Text className="text-sm text-gray-500 mb-1">Estado</Text>
              <Text className="text-base font-medium text-gray-900 capitalize">
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
              <View>
                <Text className="text-sm text-gray-500 mb-1">Subido por</Text>
                <Text className="text-base font-medium text-gray-900 capitalize">
                  {obligation.uploaded_by_name}
                </Text>
              </View>
            )}

            {obligation.notes && (
              <View>
                <Text className="text-sm text-gray-500 mb-1">Notas</Text>
                <Text className="text-base text-gray-700">{obligation.notes}</Text>
              </View>
            )}
          </View>
        </View>

        {/* Input Documents Section */}
        <View className="mb-6">
          <Text className="text-lg font-bold text-gray-900 mb-4">Documentos de Entrada Requeridos</Text>

          {requiredInputDocs.length === 0 ? (
            <View className="bg-gray-50 border border-gray-200 rounded-lg p-4">
              <Text className="text-gray-600 text-center">
                No hay documentos de entrada configurados para esta obligación
              </Text>
            </View>
          ) : (
            <View className="gap-3">
              {requiredInputDocs.map((doc) => (
                <View
                  key={doc.id}
                  className="bg-white border border-gray-300 rounded-lg p-4 flex-row items-center"
                >
                  {/* Checkbox */}
                  <TouchableOpacity
                    className={`w-6 h-6 rounded border-2 mr-3 items-center justify-center ${
                      checkedDocs[doc.id]
                        ? 'bg-green-500 border-green-500'
                        : 'bg-white border-gray-400'
                    }`}
                    onPress={() => toggleDocumentCheck(doc.id)}
                  >
                    {checkedDocs[doc.id] && (
                      <Text className="text-white font-bold text-sm">✓</Text>
                    )}
                  </TouchableOpacity>

                  {/* Document info */}
                  <View className="flex-1">
                    <Text className="text-base font-medium text-gray-900 capitalize">
                      {doc.name}
                      {doc.is_mandatory && <Text className="text-red-600"> *</Text>}
                    </Text>
                    {doc.notes && (
                      <Text className="text-xs text-gray-500 mt-1">{doc.notes}</Text>
                    )}
                  </View>

                  {/* Upload button */}
                  {canUploadInput && (
                    <TouchableOpacity
                      className="bg-blue-600 rounded-lg px-3 py-2 ml-2"
                      onPress={handleUploadInputDocument}
                    >
                      <Text className="text-white font-semibold text-xs">Subir</Text>
                    </TouchableOpacity>
                  )}
                </View>
              ))}
            </View>
          )}
        </View>

        {/* Legal Documents Section */}
        {requiredLegalDocs.length > 0 && (
          <View className="mb-6">
            <Text className="text-lg font-bold text-gray-900 mb-4">
              Documentos Legales Requeridos
            </Text>

            <View className="gap-3">
              {requiredLegalDocs.map((doc) => (
                <View
                  key={doc.id}
                  className="bg-white border border-gray-300 rounded-lg p-4 flex-row items-center"
                >
                  {/* Checkbox */}
                  <TouchableOpacity
                    className={`w-6 h-6 rounded border-2 mr-3 items-center justify-center ${
                      checkedDocs[doc.id]
                        ? 'bg-green-500 border-green-500'
                        : 'bg-white border-gray-400'
                    }`}
                    onPress={() => toggleDocumentCheck(doc.id)}
                  >
                    {checkedDocs[doc.id] && (
                      <Text className="text-white font-bold text-sm">✓</Text>
                    )}
                  </TouchableOpacity>

                  {/* Document info */}
                  <View className="flex-1">
                    <Text className="text-base font-medium text-gray-900 capitalize">
                      {doc.name}
                      {doc.is_mandatory && <Text className="text-red-600"> *</Text>}
                    </Text>
                    {doc.notes && (
                      <Text className="text-xs text-gray-500 mt-1">{doc.notes}</Text>
                    )}
                  </View>

                  {/* Upload button */}
                  {canUploadInput && (
                    <TouchableOpacity
                      className="bg-blue-600 rounded-lg px-3 py-2 ml-2"
                      onPress={handleUploadInputDocument}
                    >
                      <Text className="text-white font-semibold text-xs">Subir</Text>
                    </TouchableOpacity>
                  )}
                </View>
              ))}
            </View>
          </View>
        )}

        {/* Output Document Section */}
        <View className="mb-6">
          <Text className="text-lg font-bold text-gray-900 mb-4">Documento de Salida</Text>

          {obligation.file_url ? (
            <View className="bg-green-50 border border-green-200 rounded-lg p-4">
              <Text className="text-green-800 font-semibold mb-2">
                ✓ Documento generado y subido
              </Text>
              <Text className="text-green-700 text-sm mb-3">
                El documento de esta obligación ya ha sido generado y está disponible.
              </Text>
              <TouchableOpacity className="bg-green-600 rounded-lg py-2 px-4 self-start">
                <Text className="text-white font-semibold">Ver documento</Text>
              </TouchableOpacity>
            </View>
          ) : (
            <View>
              {!hasAllRequiredInputs && (
                <View className="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-4">
                  <Text className="text-yellow-800 font-semibold mb-2">
                    ⚠️ Documentos de entrada pendientes
                  </Text>
                  <Text className="text-yellow-700 text-sm">
                    Faltan documentos de entrada requeridos. El contador no puede generar el
                    documento de salida hasta que el cliente suba todos los documentos necesarios.
                  </Text>
                </View>
              )}

              {canUploadOutput && (
                <TouchableOpacity
                  className={`rounded-lg py-3 px-6 ${
                    hasAllRequiredInputs && !uploading
                      ? 'bg-blue-600'
                      : 'bg-gray-300'
                  }`}
                  onPress={handleUploadOutputDocument}
                  disabled={!hasAllRequiredInputs || uploading}
                >
                  {uploading ? (
                    <View className="flex-row items-center justify-center">
                      <ActivityIndicator size="small" color="#6b7280" />
                      <Text className="text-gray-500 font-semibold ml-2">Subiendo...</Text>
                    </View>
                  ) : (
                    <Text
                      className={`text-center font-semibold ${
                        hasAllRequiredInputs ? 'text-white' : 'text-gray-500'
                      }`}
                    >
                      {hasAllRequiredInputs
                        ? 'Subir Documento de Salida'
                        : 'Esperando Documentos de Entrada'}
                    </Text>
                  )}
                </TouchableOpacity>
              )}

              {!canUploadOutput && (
                <View className="bg-gray-50 border border-gray-200 rounded-lg p-4">
                  <Text className="text-gray-600 text-center">
                    Solo el contador puede subir el documento de salida
                  </Text>
                </View>
              )}
            </View>
          )}
        </View>
      </View>
    </ScrollView>
  );
}
