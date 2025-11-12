-- 11_create_input_documents.sql
-- ============================================================
-- Description: Stores all incoming documents provided by clients.
--              Each document is linked to a company and classified by type.
-- ============================================================

DROP TABLE IF EXISTS public.input_documents CASCADE;

CREATE TABLE public.input_documents (
    id BIGSERIAL PRIMARY KEY,                                               -- Unique identifier
    company_id BIGINT NOT NULL REFERENCES public.companies(id),             -- FK to company that owns the document
    document_type_id BIGINT NOT NULL REFERENCES public.document_types(id),  -- FK to document type catalog
    title TEXT NOT NULL,                                                    -- Human-readable document title
    file_url TEXT NOT NULL,                                                 -- Supabase Storage URL
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),                          -- Record creation timestamp
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),                          -- Last update timestamp
    active BOOLEAN NOT NULL DEFAULT TRUE,                                   -- Soft delete flag: TRUE = active, FALSE = deleted
    deleted_at TIMESTAMPTZ                                                   -- Timestamp when the record was soft deleted
);

