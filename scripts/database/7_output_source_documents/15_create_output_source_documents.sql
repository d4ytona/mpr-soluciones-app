-- 15_create_output_source_documents.sql
-- ============================================================
-- Description: Junction table that maps which specific documents
--              (legal or input) were used to create an output document.
-- ============================================================

DROP TABLE IF EXISTS public.output_source_documents CASCADE;

CREATE TABLE public.output_source_documents (
    id BIGSERIAL PRIMARY KEY,
    output_document_id BIGINT NOT NULL REFERENCES public.output_documents(id) ON DELETE CASCADE,
    source_document_id BIGINT NOT NULL,  -- ID of the source document
    source_document_type VARCHAR(20) NOT NULL CHECK (source_document_type IN ('legal', 'input')),  -- Type: 'legal' or 'input'
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by BIGINT REFERENCES public.users(id),

    -- Prevent duplicate entries
    UNIQUE(output_document_id, source_document_id, source_document_type)
);

-- Create indexes for performance
CREATE INDEX idx_output_source_docs_output_id
ON public.output_source_documents(output_document_id);

CREATE INDEX idx_output_source_docs_source
ON public.output_source_documents(source_document_id, source_document_type);

COMMENT ON TABLE public.output_source_documents IS
'Maps which specific legal or input documents were used to create each output document';

COMMENT ON COLUMN public.output_source_documents.source_document_type IS
'Indicates whether source_document_id refers to legal_documents or input_documents table';
