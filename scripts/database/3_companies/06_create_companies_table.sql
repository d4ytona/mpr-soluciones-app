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
    created_by BIGINT REFERENCES public.users(id),              -- FK to users table (accountant or boss who created record)
    assigned_to BIGINT REFERENCES public.users(id) ON DELETE SET NULL,            -- Legacy: Single accountant assignment
    assigned_accountant BIGINT REFERENCES public.users(id) ON DELETE SET NULL,    -- Primary accountant assigned to company
    assigned_client BIGINT REFERENCES public.users(id) ON DELETE SET NULL,        -- Primary client/owner assigned to company
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),              -- Record creation timestamp
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),              -- Last update timestamp
    active BOOLEAN NOT NULL DEFAULT TRUE,                       -- Soft delete flag: TRUE = active, FALSE = deleted
    deleted_at TIMESTAMPTZ                                      -- Timestamp when the record was soft deleted
);

-- Create indexes for performance on assignment fields
CREATE INDEX idx_companies_created_by ON public.companies(created_by);
CREATE INDEX idx_companies_assigned_to ON public.companies(assigned_to);
CREATE INDEX idx_companies_assigned_accountant ON public.companies(assigned_accountant);
CREATE INDEX idx_companies_assigned_client ON public.companies(assigned_client);
CREATE INDEX idx_companies_active ON public.companies(active) WHERE active = TRUE;
