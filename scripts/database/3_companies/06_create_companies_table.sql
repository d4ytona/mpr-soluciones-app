-- 06_create_companies_table.sql
-- ============================================================
-- Description: Stores company/client information.
--              Each company can have multiple users associated
--              (e.g., accountants, legal representatives).
-- ============================================================
DROP TABLE IF EXISTS public.companies;

CREATE TABLE public.companies (
    id BIGSERIAL PRIMARY KEY,                                   -- Unique identifier
    name TEXT NOT NULL,                                         -- Legal name of the company
    tax_id TEXT UNIQUE NOT NULL,                                -- Tax identification number (Venezuelan RIF)
    address TEXT,                                               -- Company physical address
    phone TEXT,                                                 -- Main contact phone number
    email TEXT,                                                 -- General contact email
    created_by BIGINT,                                          -- Optional FK to users table (accountant or boss who created record)
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),              -- Record creation timestamp
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),              -- Last update timestamp
    active BOOLEAN NOT NULL DEFAULT TRUE,                       -- Soft delete flag: TRUE = active, FALSE = deleted
    deleted_at TIMESTAMPTZ                                      -- Timestamp when the record was soft deleted
);
