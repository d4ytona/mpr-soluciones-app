# Database Overview and Population Guide

This document explains the structure of the MPR Soluciones database, how each table works, and the correct order in which the database must be populated to function properly.

---

## 1. Overview of the Database Structure

The system is organized into several core tables that represent different functional areas:

### **1. Users (`users`)**

Stores all platform users (clients, accountants, bosses, admins).  
Includes personal information, role, audit fields, and soft delete fields.

### **2. Companies (`companies`)**

Represents the legal entities (clients).  
Users such as accountants and bosses may be associated with them.

### **3. Document Types (`document_types`)**

A master catalog used by all document tables.  
It classifies documents in 3 layers:

- **category_type** (input, legal, output)
- **sub_type**
- **name**

### **4. Input Documents (`input_documents`)**

Documents provided by clients (e.g. facturas de compras, estados de cuenta).

### **5. Output Documents (`output_documents`)**

Documents prepared by the accountant for delivery to the client (e.g. declaraciones ISLR, IVA).

### **6. Legal Documents (`legal_documents`)**

Long-term documents that may have expiration dates (e.g. RIF, acta constitutiva).

### **7. Document Relations (`document_relations`)**

Bridges required input documents with the output documents that depend on them.
Example: “Declaración de IVA” requires “Facturas de venta”.

---

## 2. General Behavior of the Database

### **Audit System**

All tables have:

- `created_at`
- `updated_at`
- `deleted_at`
- `active`

Additionally, each table is connected to the generic audit trigger `fn_write_audit()`, meaning:

- Every INSERT, UPDATE, DELETE is recorded in `audit_log`.

### **Soft Delete**

Records are _not_ removed from the system.  
Instead:

- `active = FALSE`, and
- `deleted_at = now()`

This preserves historical consistency.

### **RLS (Row-Level Security)**

Each table implements RLS so users can only see:

- Their own data (clients)
- Data for companies they manage (accountants)
- Everything (admins)

---

## 3. Order of Population

To ensure the system works correctly, you must follow this sequence:

---

### **Step 1 — Populate `users`**

Insert the platform's initial users (test users included):

| Email                                 | Auth ID                              | Name                | Role       |
| ------------------------------------- | ------------------------------------ | ------------------- | ---------- |
| rachelgraphicss@gmail.com             | 949d2686-1940-4e48-b27b-a8f90abf11d8 | Rachel Solano       | client     |
| mayerling.rodriguez@mprsoluciones.com | ab81d562-066a-4c73-96cd-79d8b9215e7b | Mayerling Rodriguez | boss       |
| joselayett@gmail.com                  | d9003b2b-571b-4bbf-b75d-2557b3e8d08c | Jose Layett         | accountant |

These users are required before inserting any companies or documents.

---

### **Step 2 — Populate `companies`**

Insert the companies (clients).  
Each company may optionally reference a `created_by` user.

---

### **Step 3 — Populate `document_types`**

Load the entire document type catalog (input, legal, output).  
This must be done before any documents can be created.

---

### **Step 4 — Insert Input Documents**

Each input document requires:

- A `company_id`
- A `document_type_id`
- Optionally: uploaded file references

---

### **Step 5 — Insert Output Documents**

Each output document requires:

- A `company_id`
- A `document_type_id`
- A `due_date`

---

### **Step 6 — Insert Legal Documents**

These require:

- A `company_id`
- A `document_type_id`
- An `expiration_date`

---

### **Step 7 — Insert Document Relations**

Only after both input and output documents exist.

Example:

```
input_document_id = factura_de_ventas_uuid
output_document_id = declaracion_iva_uuid
```

This establishes dependency rules for the accountant workflow.

---

## 4. Summary

| Step | Table              | Purpose                              |
| ---- | ------------------ | ------------------------------------ |
| 1    | users              | Users of the system                  |
| 2    | companies          | Client companies                     |
| 3    | document_types     | Catalog for all document tables      |
| 4    | input_documents    | Documents uploaded by clients        |
| 5    | output_documents   | Documents produced by accountants    |
| 6    | legal_documents    | Legal long-term documents            |
| 7    | document_relations | Links required input for each output |

Following this order ensures:

- Referential integrity,
- RLS consistency,
- Audit logging correctness.

---
