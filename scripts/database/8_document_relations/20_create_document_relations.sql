-- 17_create_document_relations.sql
-- ============================================================
-- Description: Links input documents with output documents that depend on them.
--              Example: "Declaración de IVA" requires "Facturas de venta".
-- ============================================================

DROP TABLE IF EXISTS public.document_relations CASCADE;

CREATE TABLE public.document_relations (
    id BIGSERIAL PRIMARY KEY,                                               -- Unique identifier
    input_document_id BIGINT NOT NULL REFERENCES public.input_documents(id) ON DELETE CASCADE,   -- FK to input document
    output_document_id BIGINT NOT NULL REFERENCES public.output_documents(id) ON DELETE CASCADE, -- FK to output document
    created_by BIGINT REFERENCES public.users(id) ON DELETE SET NULL,       -- Optional FK to user who created the relation
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),                          -- Record creation timestamp
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),                          -- Last update timestamp
    active BOOLEAN NOT NULL DEFAULT TRUE,                                   -- Soft delete flag: TRUE = active, FALSE = deleted
    deleted_at TIMESTAMPTZ                                                   -- Timestamp when the record was soft deleted
);
