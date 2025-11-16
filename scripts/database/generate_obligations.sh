#!/bin/bash
# generate_obligations.sh
# ============================================================
# Description: Generate monthly obligations for 2025
# Usage: ./generate_obligations.sh
# ============================================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "Generating 2025 Obligations"
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

echo -e "${YELLOW}Generating obligations from January to November 2025...${NC}"
echo ""

psql "$SUPABASE_DB_URL" -f 29_generate_2025_obligations.sql

echo ""
echo "========================================="
echo -e "${GREEN}Obligations generated successfully!${NC}"
echo "========================================="
echo ""
echo "View obligations with:"
echo "  SELECT * FROM v_obligations_dashboard;"
echo ""
