-- 14_create_output_documents.sql
-- ============================================================
-- Description: Stores accountant-delivered documents (output).
--              Enhanced with obligation management, document
--              relationship tracking, and automatic generation support.
-- ============================================================

DROP TABLE IF EXISTS public.output_documents CASCADE;

CREATE TABLE public.output_documents (
    id BIGSERIAL PRIMARY KEY,                                               -- Unique identifier
    company_id BIGINT NOT NULL REFERENCES public.companies(id),             -- FK to company receiving the document
    document_type_id BIGINT NOT NULL REFERENCES public.document_types(id),  -- FK to document type catalog
    uploaded_by BIGINT REFERENCES public.users(id),                         -- FK to user (accountant) who uploaded (NULL if auto-generated)
    file_url TEXT,                                                          -- Supabase Storage URL (NULL until document is uploaded)
    notes TEXT,                                                             -- Optional accountant notes
    due_date DATE,                                                          -- Due date for deliverable (required for obligations)

    -- Document relationship tracking (Enfoque A: Array de IDs)
    source_input_document_ids BIGINT[],                                     -- Array of input_document IDs used to create this output

    -- Monthly obligation management
    period_year INTEGER,                                                    -- Year of the obligation (e.g., 2025)
    period_month INTEGER CHECK (period_month BETWEEN 1 AND 12),            -- Month of the obligation (1-12)
    obligation_status VARCHAR(50) DEFAULT 'pending'                         -- Status: 'pending', 'in_progress', 'completed', 'overdue'
        CHECK (obligation_status IN ('pending', 'in_progress', 'completed', 'overdue')),
    auto_generated BOOLEAN NOT NULL DEFAULT FALSE,                          -- TRUE if generated automatically, FALSE if created manually

    -- Audit fields
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),                          -- Record creation timestamp
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),                          -- Last update timestamp
    active BOOLEAN NOT NULL DEFAULT TRUE,                                   -- Soft delete flag: TRUE = active, FALSE = deleted
    deleted_at TIMESTAMPTZ                                                   -- Timestamp when the record was soft deleted
);

