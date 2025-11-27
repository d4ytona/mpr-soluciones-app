-- 35_create_required_inputs_table.sql
-- ============================================================
-- Description: Maps which input document types are required
--              for each output document type (obligations).
-- ============================================================

DROP TABLE IF EXISTS public.output_required_inputs CASCADE;

CREATE TABLE public.output_required_inputs (
    id BIGSERIAL PRIMARY KEY,
    output_document_type_id BIGINT NOT NULL REFERENCES public.document_types(id),
    required_input_document_type_id BIGINT NOT NULL REFERENCES public.document_types(id),
    is_mandatory BOOLEAN NOT NULL DEFAULT TRUE,  -- TRUE = required, FALSE = optional
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    deleted_at TIMESTAMPTZ,

    -- Prevent duplicates
    UNIQUE(output_document_type_id, required_input_document_type_id)
);

-- Create indexes for performance
CREATE INDEX idx_output_required_inputs_output_type
ON public.output_required_inputs(output_document_type_id)
WHERE active = TRUE;

CREATE INDEX idx_output_required_inputs_input_type
ON public.output_required_inputs(required_input_document_type_id)
WHERE active = TRUE;

COMMENT ON TABLE public.output_required_inputs IS
'Defines which input document types are required to generate each output document type';
