# Plan: Rename Company Document Column (CNPJ to Registration Number / CPF or CNPJ)

## Objective
Migrate `companies.cnpj` to a more inclusive name such as `registration_number` or `document_number` across all layers (Supabase database, Drift local cache, data/domain models, and UI formatters), ensuring full semantic clarity that the field holds either a CPF (individual) or CNPJ (legal entity).

## Scope & Impact
1. **Database Migration (Supabase)**:
   - Rename column `cnpj` to `registration_number` in `public.companies` (or create a backward-compatible view / generated column during transition).
   - Update unique index `uq_companies_cnpj_active` to `uq_companies_registration_number_active`.
   - Update RLS policies and trigger functions referencing `companies.cnpj`.
   - Update `docs/schema/companies.md`.

2. **Local Drift Database**:
   - Update Drift table `Companies` column from `cnpj` to `registrationNumber`.
   - Bump Drift `schemaVersion` and add migration strategy for existing client databases.

3. **Data & Domain Layer**:
   - Update `CompanyEntity`: rename `cnpj` to `registrationNumber` (or `documentNumber`).
   - Update `CompanyModel`, `CompanyRequestModel`, and JSON serialization.
   - Update `CompanyLocalDataSource`, `CompanyRemoteDataSource`, and repositories.
   - Update test factories (`UserFactory.makeCompanyEntity`, etc.).

4. **Presentation & Formatting**:
   - Update `CompanyInfoStep`, `ConfirmationStep`, `CreateCompanyPage`, `CompanyDetailCard`, and `CompanySwitcherSection`.
   - Implement dynamic document formatting (auto-detect length $\le 11$ for CPF vs $> 11$ for CNPJ) instead of static `CNPJValidator.format()`.

## Steps
- [ ] Phase 1: Database migration & schema documentation update.
- [ ] Phase 2: Drift local database column update and schema version bump.
- [ ] Phase 3: Domain entity, data models, and repository mappings refactor.
- [ ] Phase 4: UI components, form validators, and dynamic CPF/CNPJ formatting update.
- [ ] Phase 5: Update all unit and widget tests.
