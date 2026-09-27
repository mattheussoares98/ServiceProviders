# customers

Stores customers/clients for CRM purposes (applicable to service providers and hybrid companies). Customers never authenticate to the app.

| Column | Type | Null | Default | Description |
|---|---|---|---|---|
| `name` | VARCHAR(255) | NO | - | Customer name or company name |
| `document` | VARCHAR(14) | YES | - | Clean document numbers (CPF/CNPJ) |
| `document_type` | VARCHAR(4) | YES | - | 'cpf' or 'cnpj' |
| `contact_name` | VARCHAR(255) | YES | - | Primary contact person |
| `contact_email` | VARCHAR(255) | YES | - | Contact email |
| `contact_phone` | VARCHAR(30) | YES | - | Contact phone |
| `address` | VARCHAR(500) | YES | - | Street address or client site |
| `notes` | VARCHAR(2000) | YES | - | General observations or instructions |
| `is_active` | BOOLEAN | NO | true | Active status |

## Constraints & Indexes

* `chk_customers_name_not_empty`: `CHECK (length(trim(name)) > 0)` prevents empty or whitespace-only names.
* `chk_customers_document_type`: `CHECK (document_type IS NULL OR lower(document_type) IN ('cpf', 'cnpj'))`.
* `unique_customer_document_per_company_idx`: Unique document per company where active and not null.
* `unique_customer_name_per_company_idx`: Unique lower(trim(name)) per company where active.

## Deletion Rules

* **Hard Deletes**: Prohibited by the general `prevent_delete()` trigger.
* **Soft Deletes**: Blocked if any work orders associated with this customer have `status != 'completed'` and `deleted_at IS NULL` via `tr_prevent_delete_customers_with_relations` (`check_customer_before_delete()`).
