# Plan: Company Default Currency Configuration

## Objective
Introduce a central `currency VARCHAR(3) NOT NULL DEFAULT 'BRL'` in `company_parameters` (Postgres, Drift, Models, and UI) so work orders, maintenance plans, and financial reports inherit the company's default currency automatically.

## Requirements & Scope
1. **Database Migration (Supabase)**:
   - Add column `currency VARCHAR(3) NOT NULL DEFAULT 'BRL'` to `public.company_parameters`.
   - Update seed triggers and existing records.
2. **Local Drift Database**:
   - Add `currency` column to `CompanyParameters` table with default `'BRL'`.
   - Bump `schemaVersion` and add Drift migration.
3. **Domain & Data Models**:
   - Update `CompanyParametersEntity` and `CompanyParametersModel`.
4. **UI & Defaults**:
   - When creating work orders or maintenance plans, auto-populate `currency` from `CompanyParameters`.
   - Add a currency selector in the company settings/parameters screen.

## Steps
- [ ] Create & apply Supabase migration for `company_parameters.currency`.
- [ ] Update Drift `CompanyParameters` table and migration.
- [ ] Update `CompanyParametersEntity`, `CompanyParametersModel`, and factories.
- [ ] Update unit tests.
- [ ] Update documentation in `docs/schema/company_parameters.md`.
