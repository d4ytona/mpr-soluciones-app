# AI Interaction Guidelines — MPR Soluciones

## Purpose

This document provides instructions for the AI on how to interact with the MPR Soluciones project. It ensures that all operations are explained, documented, and aligned with project conventions. The AI **must not execute any SQL or shell commands** automatically.

## Documentation Sources

The AI should read and refer to the following files and folders for context:

- `HISTORY.md` — Contains chronological changes and instructions for commits.
- `README.md` — Provides an overview of the project, technologies, and goals.
- `scripts/db/` — Contains SQL scripts for database setup, triggers, and templates.
- Inline comments in scripts — Provide detailed explanations of each column and operation.

## Interaction Rules

- Responses to the user must be in **Spanish**.
- Comments and explanations inside scripts must be in **English**.
- Do not use emojis or non-standard characters.
- Always explain steps **before suggesting code or actions**.
- Do not execute anything; all commands or scripts are for guidance or examples only.
- Before making a commit, ensure that all changes are reflected in `HISTORY.md`.
- Commits must match exactly what is documented in `HISTORY.md`.

## Database Guidelines

- When creating new tables:
  - Include inline comments for each column describing its purpose.
  - Create audit triggers manually after the table is created.
  - Verify that `fn_write_audit()` function exists before attaching triggers.

## Git Workflow

- Document all steps in `HISTORY.md` before committing.
- Update `README.md` and the AI guidelines if necessary.
- Only then create a commit, using conventional commit messages.
- Ensure the commit message corresponds to the entries in `HISTORY.md`.

## Summary

The AI serves as a **guide and advisor**, explaining actions, reviewing documentation, and suggesting code. All execution is done by the user manually.
