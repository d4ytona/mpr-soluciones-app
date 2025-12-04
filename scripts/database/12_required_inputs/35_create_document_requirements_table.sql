-- 35_create_document_requirements_table.sql
-- ============================================================
-- Description: Maps which document types (input OR legal) are required
--              for each output document type (obligations).
-- ============================================================

DROP TABLE IF EXISTS public.document_requirements CASCADE;

CREATE TABLE public.document_requirements (
    id BIGSERIAL PRIMARY KEY,
    output_document_type_id BIGINT NOT NULL REFERENCES public.document_types(id),
    required_document_type_id BIGINT NOT NULL REFERENCES public.document_types(id),  -- Can be input OR legal document
    is_mandatory BOOLEAN NOT NULL DEFAULT TRUE,  -- TRUE = required, FALSE = optional
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    deleted_at TIMESTAMPTZ,

    -- Prevent duplicates
    UNIQUE(output_document_type_id, required_document_type_id)
);

-- Create indexes for performance
CREATE INDEX idx_document_requirements_output_type
ON public.document_requirements(output_document_type_id)
WHERE active = TRUE;

CREATE INDEX idx_document_requirements_required_type
ON public.document_requirements(required_document_type_id)
WHERE active = TRUE;

COMMENT ON TABLE public.document_requirements IS
'Defines which document types (input or legal) are required to generate each output document type';
