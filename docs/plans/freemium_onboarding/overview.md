# Freemium Onboarding + Work Type

Self-service onboarding: users sign up freely, create a company, and start using the app with a limited free tier. Payment unlocks the full feature set.

## Confirmed Decisions

| Decision | Answer |
|---|---|
| Work type location | `companies` table (company-level) |
| Payment unlock | Super-admin panel in the app |
| Customers concept | New `customers` table (deferred to separate plan) |
| Work type changes | Upgrades only (internal → hybrid, provider → hybrid); no downgrades |
| Onboarding flow | Sign up → confirm email → login → wizard (name/CNPJ → work type → done) |

### Free-Tier Limits

| Resource | Free | Paid |
|---|---|---|
| Work orders per day | **3** | Unlimited |
| Attachments per work order | **2** | Unlimited |
| Maintenance plans | **Disabled** | Unlimited |
| Service providers | **Disabled** | Unlimited |
| Observations per work order | **2** | Unlimited |

> [!IMPORTANT]
> **Dual enforcement (non-negotiable):** Every quota limit is enforced at **both** layers:
> - **Database** (BEFORE INSERT triggers) — the security gate. Cannot be bypassed even if someone calls the API directly.
> - **Flutter UI** (use case checks) — the UX convenience. Shows an upgrade prompt before the user even tries, avoiding a failed request.
>
> The UI is a friendlier presentation of the same rule; it is NOT the enforcement boundary.

## Steps

| # | Layer | File | Phases |
|---|---|---|---|
| 1 | Database | [step_1_database.md](step_1_database.md) | 1 — companies columns, 2 — company_parameters quotas + trigger |
| 2 | Domain | [step_2_domain.md](step_2_domain.md) | 3 — entities & enums, 4 — quota enforcement use cases |
| 3 | Presentation | [step_3_presentation.md](step_3_presentation.md) | 5 — onboarding wizard, 6 — quota guards + upgrade prompts, 7 — super-admin panel |

## Execution Order

```
Step 1 (DB) → Step 2 (Domain) → Step 3 (Presentation)
```

Each step is a separate turn with its own tests. The **customers table** for service-provider/hybrid companies is deferred to a separate plan after this foundation is complete.
