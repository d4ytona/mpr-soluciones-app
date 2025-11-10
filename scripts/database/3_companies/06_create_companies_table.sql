-- 04_create_companies_table.sql
-- ============================================================
-- Description: Stores company/client information.
--              Each company can have multiple users associated
--              (e.g., accountants, legal representatives).
-- ============================================================
DROP TABLE IF EXISTS public.companies

CREATE TABLE public.companies (
    id BIGSERIAL PRIMARY KEY,                          -- Unique identifier for the company
    name TEXT NOT NULL,                                -- Legal name of the company
    tax_id TEXT UNIQUE NOT NULL,                       -- Tax identification number (Venezuelan RIF)
    address TEXT,                                      -- Company address (optional)
    phone TEXT,                                        -- Main contact phone
    email TEXT,                                        -- General contact email
    created_by BIGINT,                                 -- User ID of the creator (optional, can be accountant or boss)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(), -- Record creation timestamp
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()  -- Last update timestamp
    active BOOLEAN DEFAULT TRUE,                       -- Soft delete flag: TRUE = active, FALSE = deleted
    deleted_at TIMESTAMPTZ DEFAULT NULL                -- Timestamp when the record was soft deleted

);
