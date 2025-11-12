-- 13_create_output_documents.sql
-- ============================================================
-- Description: Stores accountant-delivered documents (output).
--              Includes accountant assignment and due dates.
-- ============================================================

DROP TABLE IF EXISTS public.output_documents CASCADE;

CREATE TABLE public.output_documents (
    id BIGSERIAL PRIMARY KEY,                                               -- Unique identifier
    company_id BIGINT NOT NULL REFERENCES public.companies(id),             -- FK to company receiving the document
    document_type_id BIGINT NOT NULL REFERENCES public.document_types(id),  -- FK to document type catalog
    uploaded_by BIGINT NOT NULL REFERENCES public.users(id),                -- FK to user (accountant) who uploaded
    file_url TEXT NOT NULL,                                                 -- Supabase Storage URL
    notes TEXT,                                                             -- Optional accountant notes
    due_date DATE,                                                          -- Optional due date for deliverable
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),                          -- Record creation timestamp
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),                          -- Last update timestamp
    active BOOLEAN NOT NULL DEFAULT TRUE,                                   -- Soft delete flag: TRUE = active, FALSE = deleted
    deleted_at TIMESTAMPTZ                                                   -- Timestamp when the record was soft deleted
);

