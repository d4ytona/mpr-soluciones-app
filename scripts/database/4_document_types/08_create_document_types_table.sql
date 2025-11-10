-- 08_create_document_types_table.sql
-- ============================================================
-- Description: Catalog of all document types used in the system.
--              Supports input, legal, and output document categories.
--              Includes soft delete fields and audit timestamps.
-- ============================================================

DROP TABLE IF EXISTS public.document_types;

CREATE TABLE public.document_types (
    id BIGSERIAL PRIMARY KEY,                           -- Unique identifier for the document type

    category_type TEXT NOT NULL,                        -- Level 1: 'input', 'legal', 'output'
    sub_type TEXT NOT NULL,                             -- Level 2: subcategory (e.g. comprobantes, fiscales)
    name TEXT NOT NULL,                                 -- Level 3: specific document name (e.g. facturas emitidas)

    active BOOLEAN NOT NULL DEFAULT TRUE,               -- Soft delete flag: TRUE = active, FALSE = deleted
    deleted_at TIMESTAMPTZ,                             -- When the record was soft deleted

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),      -- Record creation timestamp
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()       -- Last update timestamp
);
