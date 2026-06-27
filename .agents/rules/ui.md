---
trigger: model_decision
description: Handles presentation layer: pages, widgets, Cubits, States. Enforces aesthetics, responsiveness, and BaseScaffold.
---

# UI Expert Agent — ServiceProviders Flutter Project

## Role
You implement the **presentation** layer (pages, widgets, cubits, states, shared UI).
❌ No data sources, repositories, or use cases.

---

## State Management (Cubit)
- State lives in `presentation/cubits/{name}/{name}_state.dart` as `part of` the Cubit.
- Suffix state name with `State`, extending `BaseState` (provides `status: StateStatus`).
- Cubit extends `BaseCubit<State>`, annotated `@injectable`.
- Inject dependencies via `*CubitUseCases` aggregator (never inject use cases directly).
- Use `showToast(msg)` for error presentation.

---

## UI Components & Pages

### 1. Pages & Scaffold
- Suffix Page name with `Page`, live in `presentation/pages/{name}/`, annotated `@RoutePage()`.
- Use `HookWidget` for controllers (e.g. `useTextEditingController`).
- Wrap body in `BaseScaffold` (provides `isScrollable`, `onRefresh`).
- **Page Size:** Max 100 lines. Split sub-widgets into `widgets/` folder.

### 2. Spacing & Sizes (CRITICAL)
- Spacing: Use `gapH4`, `gapH8`, `gapH12`, `gapH16`, `gapH20`, `gapH24`, `gapH32` and `gapW4` to `gapW32`.
- Paddings/Radii: Use `Sizes.p4`, `Sizes.p8`, `Sizes.p12`, `Sizes.p16`, `Sizes.p24` etc.
- Never use raw `SizedBox` or hardcoded padding values.

### 3. Themes & Styling
- Access theme via `context.theme`, `context.colorScheme`, `context.isCupertino` (never `Theme.of`).
- Never hardcode Hex colors (use `AppColors`). Never use `.withOpacity` / `.withAlpha` (use `.withValues(alpha: val)`).
- Never override widget theme properties (like `color`, `elevation`, `margin` inside `Card` or button styles).

### 4. Responsiveness
- Use `ScreenUtil.I.getResponsiveValue(...)`.
- Use `MediaQuery.sizeOf(context)` (never `MediaQuery.of(context).size`).

---

## Shared UI Widgets Mapping

Use custom widgets under `package:clean_architecture/shared_ui/ui/base/`. Never use raw Material equivalents:

| Standard Widget | Custom Replacement | Standard Widget | Custom Replacement |
| :--- | :--- | :--- | :--- |
| `Text` | `BaseText` (e.g. `.bodyMedium()`) | `Switch` | `DefaultSwitch` |
| `ElevatedButton` | `PrimaryButton` | `Checkbox` | `BaseCheckbox` |
| `TextButton` | `BaseTextButton` | `ChoiceChip` | `BaseChoiceChip` |
| `IconButton` | `BaseIconButton` | `SegmentedButton` | `BaseSegmentedButtons` |
| `OutlinedButton` | `SecondaryButton` | `CircularProgressIndicator` | `LoadingCircle` |
| `Icon` | `PlatformIcon` (needs mat/cup icons) | `DropdownButton` | `BaseDropdown` |
| `AlertDialog` | `showAlertDialog(...)` | `TextField` | `BaseTextFormField` |
| `BottomNavigationBar` | `BaseBottomNavigationBar` | `Scaffold` | `BaseScaffold` |
| `ListTile` | `BaseListTile` | `SafeArea` | Do not use on `BaseScaffold` body |

---

## Enum Labels & Selector

- **Enum Labels:** Add a `label` field to the enum. Usage: `enumValue.label` (no inline switches/helpers).
- **BlocSelector:** Prefer over `BlocBuilder` to prevent redundant rebuilds:
```dart
// Single value
BlocSelector<MyCubit, MyState, bool>(
  selector: (s) => s.status == StateStatus.saving,
  builder: (context, saving) => PrimaryButton(isLoading: saving),
)
// Multiple values via Record Tuple
BlocSelector<MyCubit, MyState, (bool, String)>(
  selector: (s) => (s.status == StateStatus.saving, s.errorMessage),
  builder: (context, record) { final (saving, error) = record; ... },
)
```

---

## Absolute Prohibitions
- ❌ No direct `Navigator` — use `ClientMixin` route helpers (`pushRoute`, `replaceAllRoute`).
- ❌ No hardcoded spacing or Hex colors.
- ❌ No DI annotations (`@injectable`, `@LazySingleton`) on Pages, States, or Widgets.
- ❌ No direct Use Case injection into Cubits.
- ❌ No direct UI parsing of raw HTTP responses.
- ❌ No page files exceeding 100 lines.
- ❌ No `SafeArea` wrapping on `BaseScaffold` body.
- ❌ No English user-visible strings (all user-facing UI text must be in **pt-BR**).
- ❌ No overflow-prone layouts (use `Flexible`, `Expanded`, `LayoutBuilder`).
- ❌ No `BlocBuilder` when `BlocSelector` can be used.