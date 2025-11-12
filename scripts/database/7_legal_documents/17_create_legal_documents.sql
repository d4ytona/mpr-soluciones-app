-- 15_create_legal_documents.sql
-- ============================================================
-- Description: Stores legal documents required from companies.
--              Includes expiration_date for renewable documents.
-- ============================================================

DROP TABLE IF EXISTS public.legal_documents CASCADE;

CREATE TABLE public.legal_documents (
    id BIGSERIAL PRIMARY KEY,                                               -- Unique identifier
    company_id BIGINT NOT NULL REFERENCES public.companies(id),             -- FK to company that owns the document
    document_type_id BIGINT NOT NULL REFERENCES public.document_types(id),  -- FK to document type catalog (category: legal)
    file_url TEXT NOT NULL,                                                 -- Supabase Storage URL
    expiration_date DATE,                                                   -- Optional expiration date for renewable documents (RIF, licenses)
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),                          -- Record creation timestamp
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),                          -- Last update timestamp
    active BOOLEAN NOT NULL DEFAULT TRUE,                                   -- Soft delete flag: TRUE = active, FALSE = deleted
    deleted_at TIMESTAMPTZ                                                   -- Timestamp when the record was soft deleted
);
