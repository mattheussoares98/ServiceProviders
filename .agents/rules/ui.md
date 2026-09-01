---
trigger: model_decision
description: Presentation layer — Flutter pages, widgets, Cubits, States. Enforces project aesthetics, responsive design, and shared-widget usage. Route here for any UI or user-interaction task
---

# UI Expert — ServicePro

Implements the **presentation** layer: pages, widgets, cubits, states, shared components.
Consumes the domain layer only through the `*CubitUseCases` aggregator. No data sources, repositories, or use cases (→ `feature.md`).

## Cubit + State
- `BaseState.status` (`DataStatus`): page data loading only (`initial`, `loading`, `loadingError`, `loaded`, `noInternet`).
- `BaseState.sections` (`Map<SectionKey, SectionStatus>`): actions/mutations (`idle`, `running`, `error`, `success`). UI binds via `observeLoading` / `observeRunning`.
- Mutation flow: `SectionStatus.running` → mutate → `SectionStatus.success` / `error` → non-loading reload (`emitLoading: false` → `DataStatus.loaded`).

```dart
enum LoginSections implements SectionKey { login }
part 'login_cubit.dart';
class LoginState extends BaseState {
  const LoginState({super.status, super.sections, super.errorMessage, required this.showPassword});
  const LoginState.initial() : showPassword = false, super(status: DataStatus.initial);
  final bool showPassword;
  LoginState copyWith({DataStatus? status, Map<SectionKey, SectionStatus>? sections, String? errorMessage, bool? annulErrorMessage, bool? showPassword}) => LoginState(
    status: status ?? this.status,
    sections: sections ?? this.sections,
    errorMessage: annulErrorMessage == true ? null : errorMessage ?? this.errorMessage,
    showPassword: showPassword ?? this.showPassword,
  );
  @override List<Object?> get props => [status, sections, errorMessage, showPassword];
}

@injectable
class LoginCubit extends BaseCubit<LoginState> {
  LoginCubit({required LoginCubitUseCases useCases}) : _useCases = useCases, super(const LoginState.initial());
  final LoginCubitUseCases _useCases;

  Future<void> login(String e, String p) async {
    emit(state.copyWith(sections: withSection(LoginSections.login, SectionStatus.running)));
    final res = await _useCases.login(AuthEntity(email: e, password: p));
    if (res is SuccessState) {
      emit(state.copyWith(sections: withSection(LoginSections.login, SectionStatus.success)));
      return replaceAllRoute(const HomeRoute());
    }
    emit(state.copyWith(sections: withSection(LoginSections.login, SectionStatus.error), errorMessage: res.message));
    showDataStateToast(res);
  }
}
```

## Pages
`presentation/pages/{name}/{name}_page.dart`, annotated `@RoutePage()`, body wrapped in `BaseScaffold`.
Any page using a controller must be a `HookWidget` using `useTextEditingController` / `useScrollController` / `useAnimationController` — never manual `initState`/`dispose`.

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

`BaseScaffold` provides safe areas, standardized padding, `isScrollable` (default true), `showAnnotatedRegion`, and `onRefresh` (pull-to-refresh).

**Max 100 lines per page file.** Beyond that, split sub-widgets into `pages/{name}/widgets/`.

## Sizing & Spacing
From `package:o_jogo_da_obra/shared_ui/utils/app_sizes.dart` — never raw numbers:
- Vertical gap → `gapH4`…`gapH32` (never `SizedBox(height: 16)`)
- Horizontal gap → `gapW4`…`gapW32`
- Sliver gap → `gapSliverH16`, `gapSliverW16` (never `SliverToBoxAdapter(child: SizedBox(...))`)
- Padding / margin / radius → `Sizes.p16`, never `16.0`

## Responsiveness
`ScreenUtil.I.getResponsiveValue(base:, screens: {...})` for breakpoint-dependent values.
`MediaQuery.sizeOf(context)` — never `MediaQuery.of(context).size` (rebuild churn).

## Theme & Color
`context.theme`, `context.colorScheme`, `context.isCupertino` — never `Theme.of(context)`.
Colors from `AppColors`; add missing ones to `app_colors.dart` rather than inlining hex.
Alpha via `.withValues(alpha: v)` — `.withOpacity()` / `.withAlpha()` are deprecated.

## Shared Widget Mapping (mandatory)
All under `package:o_jogo_da_obra/shared_ui/ui/base/`.

| Instead of | Use | Path |
|---|---|---|
| `Text` | `BaseText` (`.bodyMedium`, `.titleMedium`, `.caption`, …) | `text/base_text.dart` |
| `Scaffold` | `BaseScaffold` | `base_scaffold.dart` |
| `AppBar` | `BaseAppBar` | `app_bar/base_app_bar.dart` |
| `ElevatedButton` / `MaterialButton` | `BaseButton` | `buttons/base_button.dart` |
| `OutlinedButton` | `SecondaryButton` | `buttons/secondary_button.dart` |
| `TextButton` | `BaseTextButton` | `buttons/base_text_button.dart` |
| `IconButton` | `BaseIconButton` | `buttons/base_icon_button.dart` |
| `Icon` | `PlatformIcon(materialIcon:, cupertinoIcon:, color:)` | `platform_icon.dart` |
| `TextField` / `TextFormField` | `BaseTextFormField` | `form_field/base_text_form_field.dart` |
| `DropdownButton*` | `BaseDropDown` | `dropdown/base_dropdown.dart` |
| `ListTile` | `BaseListTile` | `base_list_tile.dart` |
| `Switch` | `BaseSwitch` | `base_switch.dart` |
| `Checkbox` | `BaseCheckbox` | `base_checkbox.dart` |
| `ChoiceChip` | `BaseChoiceChip` | `chip/base_choice_chip.dart` |
| `SegmentedButton` | `BaseSegmentedButtons` | `base_segmented_buttons.dart` |
| `BottomNavigationBar` | `BaseBottomNavigationBar` + `BaseBottomNavigationBarItem` | `base_bottom_navigation_bar.dart` |
| `CircularProgressIndicator` | `LoadingCircle` | `loading/loading_circle.dart` |
| `AlertDialog` / `showDialog` | `await showAlertDialog(...)` | `alert_dialogs.dart` |
| `ListView` / `SliverList.builder` grids | `ResponsiveListFlow` | `responsive/responsive_list_flow.dart` |

## Enum Labels
Display labels live **in the enum** as a `label` field — never a `switch`, helper, or extension in the UI.
```dart
enum PermissionAction {
  create('create', 'Criar'),
  read('read', 'Ler');
  const PermissionAction(this.code, this.label);
  final String code;
  final String label;
}
```

## Prohibitions
- ❌ `Navigator` directly — use `pushRoute` / `replaceAllRoute` from `ClientMixin` in the cubit
- ❌ DI annotations on Pages, States, or Widgets — only Cubits get `@injectable`
- ❌ Injecting a use case straight into a cubit — always the `*CubitUseCases` aggregator
- ❌ `Cubit<T>` — always `BaseCubit<T>`
- ❌ Raw data/HTTP in UI — everything comes from cubit state
- ❌ `faker` in UI code — tests only
- ❌ `SafeArea` around a `BaseScaffold` body — it handles this
- ❌ Page file > 100 lines
- ❌ Overflow-prone layouts — reach for `Flexible`, `Expanded`, `LayoutBuilder`
- ❌ A raw Material/Cupertino widget where the table above lists a replacement
