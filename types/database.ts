// Database types based on Supabase schema

export type UserRole = 'client' | 'accountant' | 'boss' | 'admin';
export type IdType = 'v' | 'e' | 'p';

export interface User {
  id: number;
  auth_id: string;
  first_name: string;
  last_name: string;
  email: string;
  role: UserRole;
  profile_photo_url: string | null;
  phone: string | null;
  birth_date: string | null;
  id_number: string;
  id_type: IdType;
  active: boolean;
  created_at: string;
  updated_at: string;
  deleted_at: string | null;
}

export interface Company {
  id: number;
  name: string;
  tax_id: string;
  address: string | null;
  phone: string | null;
  email: string | null;
  created_by: number;
  assigned_to: number | null;
  assigned_accountant: number | null;
  assigned_client: number | null;
  active: boolean;
  created_at: string;
  updated_at: string;
  deleted_at: string | null;
}

export interface CompanyWithAccountant extends Company {
  accountant: {
    id: number;
    first_name: string;
    last_name: string;
    email: string;
  } | null;
}

export interface DocumentType {
  id: number;
  code: string;
  name: string;
  description: string | null;
  category_type: string;
  sub_type: string | null;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface InputDocument {
  id: number;
  company_id: number;
  document_type_id: number;
  title: string;
  file_url: string;
  created_at: string;
  updated_at: string;
  active: boolean;
  deleted_at: string | null;
}

export interface OutputDocument {
  id: number;
  company_id: number;
  document_type_id: number;
  uploaded_by: number | null;
  file_url: string | null;
  notes: string | null;
  due_date: string | null;
  source_input_document_ids: number[] | null;
  period_year: number | null;
  period_month: number | null;
  obligation_status: ObligationStatus;
  auto_generated: boolean;
  created_at: string;
  updated_at: string;
  active: boolean;
  deleted_at: string | null;
}

// Obligation types
export type ObligationStatus = 'pending' | 'in_progress' | 'completed' | 'cancelled';
export type ObligationFrequency = 'weekly' | 'biweekly' | 'monthly' | 'quarterly' | 'annual';
export type UrgencyLevel = 'completed' | 'overdue' | 'urgent' | 'soon' | 'normal';

export interface ObligationDashboard {
  obligation_id: number;
  company_id: number;
  company_name: string;
  tax_id: string;
  document_type_id: number;
  obligation_name: string;
  obligation_code: string;
  period_year: number;
  period_month: number;
  period_formatted: string;
  due_date: string;
  days_until_due: number;
  obligation_status: ObligationStatus;
  file_url: string | null;
  uploaded_by: number | null;
  uploaded_by_name: string | null;
  source_input_document_ids: number[] | null;
  related_inputs_count: number;
  auto_generated: boolean;
  notes: string | null;
  created_at: string;
  updated_at: string;
  urgency_level: UrgencyLevel;
}

// View types
export interface UserProfile {
  id: number;
  auth_id: string;
  full_name: string;
  email: string;
  role: UserRole;
  formatted_id: string;
  profile_photo_url: string | null;
  active: boolean;
}

// Notifications
export type NotificationType = 'status_change' | 'new_obligation' | 'reminder' | 'general';

export interface Notification {
  id: number;
  user_id: number;
  title: string;
  message: string;
  obligation_id: number | null;
  company_id: number | null;
  notification_type: NotificationType;
  is_read: boolean;
  created_at: string;
  active: boolean;
}

export interface UserNotification extends Notification {
  company_name: string | null;
  company_tax_id: string | null;
  obligation_type: string | null;
  period_year: number | null;
  period_month: number | null;
  due_date: string | null;
  obligation_status: ObligationStatus | null;
}
