# MPR Soluciones — Integrated Accounting Platform

Comprehensive platform for **accountants and clients in Venezuela**, consisting of a mobile app and web interface with shared business logic.

## Goals

- Secure document management and storage
- Streamlined client-accountant communication
- Automated monthly obligation tracking
- Quick access to fiscal obligations and deadlines

---

## Tech Stack

### **Frontend**
- Expo (React Native + Web)
- Expo Router (file-based routing)
- NativeWind (TailwindCSS for React Native)
- TypeScript

### **Backend**
- Vercel (API hosting)
- Node.js

### **Database**
- Supabase (PostgreSQL 17.6)
- Automatic audit logging (all CRUD operations)
- 8 tables, 6 views, 3 utility functions
- Automated monthly obligation generation

### **Storage**
- Cloudflare R2 (document storage)

---

## Database Structure

**Core Tables (8):**
- `users` - User accounts with roles
- `companies` - Client companies
- `document_types` - 202 cataloged document types
- `input_documents` - Client-uploaded documents
- `output_documents` - Accountant deliverables + auto-generated obligations
- `legal_documents` - Legal documentation with expiration tracking
- `monthly_obligations_config` - Automatic obligation configuration
- `audit_log` - Complete audit trail

**Views (6):**
- `v_user_profiles` - Formatted user data
- `v_company_documents_summary` - Document counts and statistics
- `v_obligations_dashboard` - Obligation tracking with urgency levels
- `v_documents_pending_review` - Expiring docs and due obligations
- `v_document_relationships` - Input→Output document relationships

**Functions (3):**
- `fn_write_audit()` - Automatic audit logging
- `fn_generate_monthly_obligations()` - Auto-generate obligations
- `fn_regenerate_obligations()` - Manual obligation regeneration

---

## Quick Start

### Database Setup

```bash
# Copy and paste in Supabase SQL Editor
scripts/database/COMPLETE_SETUP.sql

# Generate 2025 obligations
scripts/database/GENERATE_2025_OBLIGATIONS.sql
```

See `scripts/database/README.md` for detailed instructions.

---

## Project Status

✅ **Database:** Fully implemented (8 tables, 6 views, 3 functions)
⏳ **Auth:** In progress (login interface)
⏳ **Mobile App:** Pending
⏳ **Web App:** Pending

---

## Documentation

- `HISTORY.md` - Complete changelog
- `DATABASE_ROADMAP.md` - Future enhancements (RLS, indexes)
- `scripts/database/README.md` - Database setup guide

---

**Last Updated:** 2025-01-16
**Version:** 0.1.0-alpha
