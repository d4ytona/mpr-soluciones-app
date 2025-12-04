-- 20_create_obligations_config.sql
-- ============================================================
-- Description: Configuration table for automatic obligation generation.
--              Defines which obligations each company must fulfill and their frequency.
-- ============================================================

DROP TABLE IF EXISTS public.obligations_config CASCADE;

CREATE TABLE public.obligations_config (
    id BIGSERIAL PRIMARY KEY,                                               -- Unique identifier
    company_id BIGINT NOT NULL REFERENCES public.companies(id),             -- FK to company
    document_type_id BIGINT NOT NULL REFERENCES public.document_types(id),  -- FK to document type (obligation)

    -- Frequency configuration
    frequency VARCHAR(20) NOT NULL DEFAULT 'monthly'                        -- How often: 'monthly', 'quarterly', 'annual'
        CHECK (frequency IN ('monthly', 'quarterly', 'annual')),
    due_day INTEGER NOT NULL CHECK (due_day BETWEEN 1 AND 31),             -- Day of month when obligation is due

    -- Additional configuration
    enabled BOOLEAN NOT NULL DEFAULT TRUE,                                  -- Whether to auto-generate this obligation
    notes TEXT,                                                             -- Optional configuration notes

    -- Audit fields
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),                          -- Record creation timestamp
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),                          -- Last update timestamp
    active BOOLEAN NOT NULL DEFAULT TRUE,                                   -- Soft delete flag
    deleted_at TIMESTAMPTZ,                                                 -- Soft delete timestamp

    -- Prevent duplicate configurations
    UNIQUE(company_id, document_type_id)
);

-- Index for fast lookups by company
CREATE INDEX idx_obligations_config_company_id
ON public.obligations_config(company_id)
WHERE active = TRUE AND enabled = TRUE;

-- Index for fast lookups by frequency
CREATE INDEX idx_obligations_config_frequency
ON public.obligations_config(frequency)
WHERE active = TRUE AND enabled = TRUE;
