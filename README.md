# MPR Soluciones — Integrated Accounting Platform

This project aims to develop a comprehensive platform for **accountants and clients in Venezuela**, consisting of a mobile app and a web interface sharing the same logic and services.

The main goal is to simplify the accounting workflow by:

- Secure management and storage of documents.
- Clear communication between clients and accountants.
- Organized upload and download of files.
- Quick access to relevant information for fiscal obligations.

The project is developed in stages, adding features and improvements as it progresses.

---

## Technologies Used

### **Frontend (App & Web)**

- **Expo** (React Native)
- **React Native Web**
- **Expo Router**
- **NativeWind / TailwindCSS**
- **TypeScript**

### **Backend**

- **Vercel**
- **Node.js**

### **Database & Auditing**

- **Supabase** (Auth, RLS)
- **PostgreSQL** with **audit_log** table for manual tracking of CRUD operations.
- Trigger functions for auditing (`fn_write_audit()`)
- SQL scripts for creating tables and attaching triggers.

### **Infrastructure / Utilities**

- **Dotenv + app.config.ts** for environment variables
- **Git + GitHub** for version control

---

## Notes

- All database audit operations are captured in JSONB format for complete tracking.
- Triggers are manually attached to each table after creation.
- Comments in SQL scripts are in English; explanations and communication with the developer are in Spanish.
- Commit history uses conventional commits for clarity and versioning.
