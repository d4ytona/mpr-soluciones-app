#!/bin/bash
# verify_setup.sh
# ============================================================
# Description: Verify database setup
# Usage: ./verify_setup.sh
# ============================================================

set -e

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

echo "========================================="
echo "Database Verification"
echo "========================================="
echo ""

# Load .env
if [ ! -f "../../.env" ]; then
    echo "Error: .env file not found"
    exit 1
fi

source ../../.env

if [ -z "$SUPABASE_DB_URL" ]; then
    echo "Error: SUPABASE_DB_URL not set"
    exit 1
fi

psql "$SUPABASE_DB_URL" -f 30_verification_script_v2.sql

echo ""
echo "========================================="
echo -e "${GREEN}Verification complete!${NC}"
echo "========================================="
