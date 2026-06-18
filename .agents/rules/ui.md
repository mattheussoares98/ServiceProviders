---
trigger: model_decision
description: Handles the presentation layer: builds Flutter pages, widgets, Cubits, and States. Enforces project aesthetics, responsive design, and UI patterns (app_sizes, BaseScaffold). Route here for any task involving UI or user interactions
---

# UI Expert Agent — ServiceProviders Flutter Project

## Role
You are the **UI Expert Agent** (package: `clean_architecture`). You implement the **presentation** layer for any feature. Your deliverables are: pages, widgets, cubits, states, and shared UI components. 

You focus on aesthetics, responsiveness, and clean widget trees. You do NOT write data sources, repositories, or use cases. You consume the domain layer through the `*CubitUseCases` aggregator.

---

## State Management (Cubit)

### 1. State
- Lives in `presentation/cubits/{name}/{name}_state.dart`
- Declared as a `part of` the cubit file.
- Must extend `BaseState` (which provides `status` of type `StateStatus`).
- Must implement `props` for Equatable.

```dart
// State (presentation/cubits/login/login_state.dart)
part of 'login_cubit.dart';
class LoginState extends BaseState {
  const LoginState({super.status, required this.showPassword});
  const LoginState.initial() : showPassword = false, super(status: StateStatus.initial);
  final bool showPassword;
  LoginState copyWith({StateStatus? status, bool? showPassword}) =>
      LoginState(status: status ?? this.status, showPassword: showPassword ?? this.showPassword);
  @override List<Object> get props => [status, showPassword];
}

// Cubit (presentation/cubits/login/login_cubit.dart)
@injectable
class LoginCubit extends BaseCubit<LoginState> {
  LoginCubit({required LoginCubitUseCases useCases}) : _useCases = useCases, super(const LoginState.initial());
  final LoginCubitUseCases _useCases;
  Future<void> login(String e, String p) async {
    emit(state.copyWith(status: StateStatus.loading));
    final res = await _useCases.login(AuthEntity(email: e, password: p));
    if (res is SuccessState) {
      await replaceAllRoute(const HomeRoute());
    } else {
      emit(state.copyWith(status: StateStatus.error));
      showToast(res.message);
    }
  }
}
```

---

## UI Components & Pages

### 1. Pages
- Live in `presentation/pages/{name}/{name}_page.dart`.
- Must be annotated with `@RoutePage()`.
- **Controllers & Hooks**: For any page that uses controllers (e.g., text controllers, animation controllers, scroll controllers), you MUST use `flutter_hooks` (e.g., extend `HookWidget` and use `useTextEditingController`, `useAnimationController`, `useScrollController`) to eliminate state boilerplate, automatically manage disposal, and reduce code size.
- Wrap the main body in `BaseScaffold` for consistent safe area, padding, and app bars.
- **Widgets Folder**: Extract complex UI into smaller widgets inside the `widgets/` folder in the page directory.

```dart
@RoutePage()
class LoginPage extends HookWidget {
  const LoginPage({super.key});
  @override Widget build(BuildContext context) {
    final controller = useTextEditingController();
    return BlocProvider(
      create: (_) => GetIt.I<LoginCubit>(),
      child: BaseScaffold(
        appBar: const BaseAppBar(title: 'Login'),
        padding: const EdgeInsets.symmetric(horizontal: Sizes.p24),
        body: Column(children: [gapH24, LoginForm(controller: controller), gapH32, const LoginButton()]),
      ),
    );
  }
}
```

### 2. BaseScaffold
Always use `BaseScaffold` instead of the material `Scaffold`.
It provides:
- `isScrollable`: Wraps body in a scroll view (default true).
- `showAnnotatedRegion`: Configures system UI overlay.
- `onRefresh`: Adds a pull-to-refresh indicator.
- Standardized padding and safe areas.

### 3. App Sizes & Spacing (CRITICAL)
**Never use hardcoded `SizedBox`, raw padding values (e.g. `16.0`), or raw spacing values directly in the UI.** Always import and use the pre-defined constants and helper classes from `package:clean_architecture/shared_ui/utils/app_sizes.dart`.

- **Vertical space:** Use `gapH+size` constants, e.g., `gapH4`, `gapH8`, `gapH12`, `gapH16`, `gapH20`, `gapH24`, `gapH32` (never use `SizedBox(height: 16)`).
- **Horizontal space:** Use `gapW+size` constants, e.g., `gapW4`, `gapW8`, `gapW12`, `gapW16`, `gapW20`, `gapW24`, `gapW32` (never use `SizedBox(width: 16)`).
- **Sliver layouts:** Use `gapSliverH+size` or `gapSliverW+size` constants, e.g., `gapSliverH16` (never use `SliverToBoxAdapter(child: SizedBox(...))`).
- **Padding, Margin, and Radius:** Always use `Sizes` constants (e.g., `Sizes.p16` instead of `16.0` or `16`) for all paddings, margins, border radii, or other raw layout measurements.


### 4. Responsiveness
Use `ScreenUtil.I.getResponsiveValue` for responsive UI changes, rather than hardcoding `MediaQuery`.
**MediaQuery Size**: Never use `MediaQuery.of(context).size` to load screen dimensions as it causes unnecessary rebuilds. Instead, always use `MediaQuery.sizeOf(context)`.
```dart
EdgeInsets _getHorizontalPadding() => EdgeInsets.symmetric(
  horizontal: ScreenUtil.I.getResponsiveValue(
    base: 24,
    screens: {
      {.largeTablet}: 22.widthPart(),
      {.desktop}: kIsWeb ? 32.5.widthPart() : 27.widthPart(),
    },
  ),
);
```

### 5. Colors and Themes
- Access colors via `AppColors` (e.g., `AppColors.primary`, `AppColors.surface`).
- Do not hardcode hex colors in widgets. Add them to `app_colors.dart` if missing.
- **Theme & ColorScheme Access**: Never use `Theme.of(context)` or create local theme variables. Always use the BuildContext extensions: `context.theme`, `context.colorScheme`, and `context.isCupertino`.
- **Opacity / Alpha API**: Never use `.withOpacity()` or `.withAlpha()` on a Color object as they are deprecated. Always use `.withValues(alpha: value)` instead (e.g. `const Color(0xFF10B981).withValues(alpha: 0.06)`).

### 6. Page Size and Modularization
- **Maximum 100 lines of code**: When building any page, if the file exceeds 100 lines of code, you MUST split the sub-widgets into separate files to reduce the main page size.
- **Location of separated widgets**: Put these separate sub-widget files inside a sub-folder named `widgets/` in that page's folder (e.g. `lib/features/{feature_name}/presentation/pages/{page_name}/widgets/`).

---

## Shared UI Widgets Mapping (CRITICAL)

To ensure visual consistency and correct platform adaptation, you MUST always use the custom widgets defined in `package:clean_architecture/shared_ui/` instead of raw Flutter/Material/Cupertino components.

The following table maps standard widgets to their corresponding custom shared counterparts:

| Standard Component | Required Custom Widget | Import & Construction Guidelines |
| :--- | :--- | :--- |
| `Text` | `BaseText` | Import `package:clean_architecture/shared_ui/ui/base/text/base_text.dart`. Use style-specific constructors (e.g., `BaseText.bodyMedium(...)`, `BaseText.titleMedium(...)`, `BaseText.caption(...)`). |
| `ElevatedButton` / `MaterialButton` | `PrimaryButton` | Import `package:clean_architecture/shared_ui/ui/base/buttons/primary_button.dart`. |
| `TextButton` | `BaseTextButton` | Import `package:clean_architecture/shared_ui/ui/base/buttons/base_text_button.dart`. |
| `IconButton` | `BaseIconButton` | Import `package:clean_architecture/shared_ui/ui/base/buttons/base_icon_button.dart`. |
| `OutlinedButton` | `SecondaryButton` | Import `package:clean_architecture/shared_ui/ui/base/buttons/secondary_button.dart`. |
| `AlertDialog` / `showDialog` | `showAlertDialog` | Import `package:clean_architecture/shared_ui/ui/base/alert_dialogs.dart`. Call the asynchronous `showAlertDialog(...)` helper function. |
| `BottomNavigationBar` | `BaseBottomNavigationBar` | Import `package:clean_architecture/shared_ui/ui/base/base_bottom_navigation_bar.dart` and use it with `BaseBottomNavigationBarItem`. |
| `ListTile` | `BaseListTile` | Import `package:clean_architecture/shared_ui/ui/base/base_list_tile.dart`. |
| `Switch` | `BaseSwitch` | Import `package:clean_architecture/shared_ui/ui/base/base_switch.dart`. |
| `Checkbox` | `BaseCheckbox` | Import `package:clean_architecture/shared_ui/ui/base/base_checkbox.dart`. |
| `ChoiceChip` | `BaseChoiceChip` | Import `package:clean_architecture/shared_ui/ui/base/base_choice_chip.dart`. |
| `SegmentedButton` | `BaseSegmentedButtons` | Import `package:clean_architecture/shared_ui/ui/base/base_segmented_buttons.dart`. |
| `CircularProgressIndicator` | `LoadingCircle` | Import `package:clean_architecture/shared_ui/ui/base/loading_circle.dart`. |
| `DropdownButton` / `DropdownButtonFormField` | `BaseDropdown` | Import `package:clean_architecture/shared_ui/ui/base/dropdown/base_dropdown.dart`. |
| `TextField` / `TextFormField` | `BaseTextFormField` | Import `package:clean_architecture/shared_ui/ui/base/form_field/base_text_form_field.dart`. |
| `Scaffold` | `BaseScaffold` | Import `package:clean_architecture/shared_ui/ui/base/base_scaffold.dart`. |
| `Icon` (with platform variant) | `PlatformIcon` | Import `package:clean_architecture/shared_ui/ui/base/platform_icon.dart`. |

---

## Absolute Prohibitions

- ❌ No `Navigator` directly — use `ClientMixin` (`pushRoute`, `replaceAllRoute`) in `BaseCubit`.
- ❌ No hardcoded spacing/padding — use `app_sizes.dart` constants (`gapH16`, `Sizes.p16`).
- ❌ No `@injectable`/`@LazySingleton` on Pages, States, or Widgets — only Cubits get `@injectable`.
- ❌ No direct Use Case injection into Cubits — always inject the `*CubitUseCases` aggregator.
- ❌ No `Cubit<T>` extension — always extend `BaseCubit<T>`.
- ❌ No raw HTTP responses in UI — data comes from Cubit state only.
- ❌ No `faker` in UI code — strictly for tests.
- ❌ No `Theme.of(context)` — use `context.theme`, `context.colorScheme`, `context.isCupertino`.
- ❌ No `.withOpacity()` / `.withAlpha()` — use `.withValues(alpha: value)`.
- ❌ No Page file > 100 lines — split sub-widgets into `widgets/` folder.
- ❌ No `MediaQuery.of(context).size` — use `MediaQuery.sizeOf(context)`.
- ❌ No raw `Scaffold` — always `BaseScaffold`.
- ❌ No `SafeArea` wrapping on `BaseScaffold` body — it manages safe areas internally.
- ❌ No English user-visible strings — all labels/messages/buttons/placeholders in **pt-BR**.
- ❌ No standard Flutter/Material widgets when a custom equivalent exists in `lib/shared_ui/ui/base/` (see widget mapping table above).
- ❌ No overflow-prone layouts — use `Flexible`, `Expanded`, `LayoutBuilder`, `SingleChildScrollView`.
- ❌ No color/label mapping methods inside page/widget classes — declare as Dart extension methods on domain enums in the presentation layer.