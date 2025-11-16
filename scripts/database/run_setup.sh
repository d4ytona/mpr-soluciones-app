#!/bin/bash
# run_setup.sh
# ============================================================
# Description: Automated database setup script for MPR Soluciones
# Usage: ./run_setup.sh
# ============================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "MPR Soluciones - Database Setup"
echo "========================================="
echo ""

# Check if .env file exists
if [ ! -f "../../.env" ]; then
    echo -e "${RED}Error: .env file not found${NC}"
    echo "Please create a .env file in the project root with:"
    echo "  SUPABASE_DB_URL=postgresql://postgres:password@host:5432/postgres"
    exit 1
fi

# Load environment variables
source ../../.env

# Check if SUPABASE_DB_URL is set
if [ -z "$SUPABASE_DB_URL" ]; then
    echo -e "${RED}Error: SUPABASE_DB_URL not set in .env${NC}"
    echo "Please add: SUPABASE_DB_URL=postgresql://postgres:password@host:5432/postgres"
    exit 1
fi

echo -e "${YELLOW}Database URL loaded from .env${NC}"
echo ""

# Confirm before proceeding
echo -e "${RED}WARNING: This will DROP and RECREATE all tables!${NC}"
echo -e "${RED}All existing data will be LOST!${NC}"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Setup cancelled."
    exit 0
fi

echo ""
echo "========================================="
echo "Starting database setup..."
echo "========================================="
echo ""

# Execute setup scripts in order
echo -e "${GREEN}[1/10] Creating audit system...${NC}"
psql "$SUPABASE_DB_URL" -f 1_audit/01_create_audit_table.sql
psql "$SUPABASE_DB_URL" -f 1_audit/02_create_audit_function.sql

echo -e "${GREEN}[2/10] Creating users table...${NC}"
psql "$SUPABASE_DB_URL" -f 2_users/04_create_users_table.sql
psql "$SUPABASE_DB_URL" -f 2_users/05_attach_audit_users.sql
psql "$SUPABASE_DB_URL" -f 2_users/06_populate_users.sql

echo -e "${GREEN}[3/10] Creating companies table...${NC}"
psql "$SUPABASE_DB_URL" -f 3_companies/06_create_companies_table.sql
psql "$SUPABASE_DB_URL" -f 3_companies/07_attach_audit_companies.sql
psql "$SUPABASE_DB_URL" -f 3_companies/08_populate_companies.sql

echo -e "${GREEN}[4/10] Creating document types...${NC}"
psql "$SUPABASE_DB_URL" -f 4_document_types/08_create_document_types_table.sql
psql "$SUPABASE_DB_URL" -f 4_document_types/09_attach_audit_document_types.sql
psql "$SUPABASE_DB_URL" -f 4_document_types/10_populate_document_types.sql

echo -e "${GREEN}[5/10] Creating input documents...${NC}"
psql "$SUPABASE_DB_URL" -f 5_input_documents/11_create_input_documents.sql
psql "$SUPABASE_DB_URL" -f 5_input_documents/12_attach_audit_input_documents.sql
psql "$SUPABASE_DB_URL" -f 5_input_documents/13_populate_input_documents.sql

echo -e "${GREEN}[6/10] Creating output documents (enhanced)...${NC}"
psql "$SUPABASE_DB_URL" -f 6_output_documents/14_create_output_documents.sql
psql "$SUPABASE_DB_URL" -f 6_output_documents/15_attach_audit_output_documents.sql
psql "$SUPABASE_DB_URL" -f 6_output_documents/16_populate_output_documents.sql

echo -e "${GREEN}[7/10] Creating legal documents...${NC}"
psql "$SUPABASE_DB_URL" -f 7_legal_documents/17_create_legal_documents.sql
psql "$SUPABASE_DB_URL" -f 7_legal_documents/18_attach_audit_legal_documents.sql
psql "$SUPABASE_DB_URL" -f 7_legal_documents/19_populate_legal_documents.sql

echo -e "${GREEN}[8/10] Creating monthly obligations config...${NC}"
psql "$SUPABASE_DB_URL" -f 8_monthly_obligations/20_create_monthly_obligations_config.sql
psql "$SUPABASE_DB_URL" -f 8_monthly_obligations/21_attach_audit_monthly_obligations_config.sql
psql "$SUPABASE_DB_URL" -f 8_monthly_obligations/22_populate_monthly_obligations_config.sql

echo -e "${GREEN}[9/10] Creating utility functions...${NC}"
psql "$SUPABASE_DB_URL" -f 9_functions/22_fn_generate_monthly_obligations.sql
psql "$SUPABASE_DB_URL" -f 9_functions/23_fn_regenerate_obligations.sql

echo -e "${GREEN}[10/10] Creating database views...${NC}"
psql "$SUPABASE_DB_URL" -f 10_views/24_v_user_profiles.sql
psql "$SUPABASE_DB_URL" -f 10_views/25_v_company_documents_summary.sql
psql "$SUPABASE_DB_URL" -f 10_views/26_v_obligations_dashboard.sql
psql "$SUPABASE_DB_URL" -f 10_views/27_v_documents_pending_review.sql
psql "$SUPABASE_DB_URL" -f 10_views/28_v_document_relationships.sql

echo ""
echo "========================================="
echo -e "${GREEN}Database setup complete!${NC}"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Generate 2025 obligations:"
echo "     ./generate_obligations.sh"
echo ""
echo "  2. Verify setup:"
echo "     ./verify_setup.sh"
echo ""
echo "========================================="
