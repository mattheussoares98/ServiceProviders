# Step 3 — Presentation Layer

## Phase 6: Quota Guards + Upgrade Prompts

- [ ] Guard work order creation — check quota before allowing
- [ ] Guard attachment upload — check quota before allowing
- [ ] Guard observation creation — check quota before allowing
- [ ] Lock maintenance plans — show disabled state for free tier
- [ ] Lock service providers — show disabled state for free tier
- [ ] Create upgrade prompt dialog/banner
- [ ] Widget tests for quota-blocked states

### Quota Guard Pattern

Each creation flow calls the corresponding quota use case before proceeding. If the quota is exceeded, an upgrade prompt is shown instead of the creation form.

```dart
// Example: in WorkOrdersCubit
Future<void> createWorkOrder(...) async {
  final canCreate = await _useCases.checkWorkOrderQuota();
  if (!canCreate) {
    _showUpgradePrompt();
    return;
  }
  // ... existing creation logic
}
```

### Upgrade Prompt

A reusable dialog/bottom sheet:
- Title: "Limite atingido" 
- Description varies by resource: "Você atingiu o limite de X por dia no plano gratuito."
- CTA: "Falar com o suporte" → navigates to support page
- Secondary: "Entendi" → dismiss

### Feature Locks

For maintenance plans and service providers on free tier:
- The nav menu item / list page shows a "Pro" badge
- Tapping it shows the upgrade prompt instead of the list
- The `CheckFeatureEnabledUseCase` gates access

---

## Phase 7: Super-Admin Plan Management

- [ ] Create `PlanManagementPage`
- [ ] Create `PlanManagementCubit` + use cases
- [ ] Register route (super-admin guarded)
- [ ] Add menu entry in admin settings
- [ ] Tests

### PlanManagementPage

A super-admin-only screen to:
- List all companies with their current `plan_type` and `work_type`
- Toggle a company between `free` and `paid`
- When toggling to `paid`: reset quota columns to `0` (unlimited)
- When toggling to `free`: set restrictive quota values

### New Files

```
lib/features/company/presentation/
├── pages/
│   └── plan_management/
│       ├── plan_management_page.dart
│       └── widgets/
│           ├── company_plan_card.dart
│           └── plan_toggle_dialog.dart
├── cubits/
│   └── plan_management/
│       ├── plan_management_cubit.dart
│       ├── plan_management_cubit_use_cases.dart
│       └── plan_management_state.dart
```

### Use Cases

- `GetAllCompaniesUseCase` — already exists
- `UpdateCompanyPlanUseCase` — new; updates `plan_type` + resets `company_parameters` quotas accordingly

### Verification

- Toggle company to `paid` → quota fields become `0` (unlimited)
- Toggle company to `free` → quota fields set to restrictive values
- Non-super-admin cannot access the page
