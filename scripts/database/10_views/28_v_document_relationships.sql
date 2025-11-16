-- 28_v_document_relationships.sql
-- ============================================================
-- Description: Shows relationships between output documents and their source input documents.
-- ============================================================

DROP VIEW IF EXISTS public.v_document_relationships CASCADE;

CREATE VIEW public.v_document_relationships AS
SELECT
    od.id as output_document_id,
    od.company_id,
    c.name as company_name,

    -- Output document details
    dt_out.id as output_type_id,
    dt_out.name as output_type_name,
    od.file_url as output_file_url,
    od.period_year,
    od.period_month,
    od.obligation_status,
    od.due_date,

    -- Source input documents (unnested)
    UNNEST(COALESCE(od.source_input_document_ids, ARRAY[]::BIGINT[])) as input_document_id,

    od.created_at,
    od.updated_at
FROM public.output_documents od
JOIN public.companies c ON od.company_id = c.id
JOIN public.document_types dt_out ON od.document_type_id = dt_out.id
WHERE od.active = TRUE
  AND c.active = TRUE
  AND od.source_input_document_ids IS NOT NULL
  AND array_length(od.source_input_document_ids, 1) > 0;

-- Enhanced view with input document details
DROP VIEW IF EXISTS public.v_document_relationships_detailed CASCADE;

CREATE VIEW public.v_document_relationships_detailed AS
SELECT
    vdr.output_document_id,
    vdr.company_id,
    vdr.company_name,
    vdr.output_type_id,
    vdr.output_type_name,
    vdr.output_file_url,
    vdr.period_year,
    vdr.period_month,
    vdr.obligation_status,
    vdr.due_date,

    -- Input document details
    vdr.input_document_id,
    id.document_type_id as input_type_id,
    dt_in.name as input_type_name,
    id.title as input_title,
    id.file_url as input_file_url,
    id.created_at as input_created_at

FROM public.v_document_relationships vdr
LEFT JOIN public.input_documents id ON vdr.input_document_id = id.id
LEFT JOIN public.document_types dt_in ON id.document_type_id = dt_in.id;

-- Usage:
-- View all relationships:
-- SELECT * FROM v_document_relationships_detailed;

-- Get all input documents used for a specific output:
-- SELECT * FROM v_document_relationships_detailed WHERE output_document_id = 1;

-- Get all outputs that used a specific input:
-- SELECT * FROM v_document_relationships_detailed WHERE input_document_id = 5;

-- Count relationships per output document:
-- SELECT output_document_id, output_type_name, COUNT(*) as input_count
-- FROM v_document_relationships_detailed
-- GROUP BY output_document_id, output_type_name;
