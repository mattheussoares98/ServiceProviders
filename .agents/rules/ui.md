---
trigger: model_decision
description: Presentation implementation — cubits, states, pages, widgets, and responsive design
---

# Presentation

Use `architect.md` for DI/routing and the orchestrator for strings/enum labels. Access use cases through `*CubitUseCases`, not direct cubit injection; keep data access and business logic outside presentation.

## Cubits and states

The API source is `lib/shared_ui/cubits/base/base_cubit.dart`:

- Extend `BaseCubit<T>` / `BaseState`.
- `BaseState.sections` is `Map<SectionKey, SectionState>`; read with `state.section(key)` and update through `withSection(key, status, errorMessage: ...)`.
- Use `BaseSections.load` for page loading and feature enums implementing `SectionKey` for independent operations. Statuses: `idle`, `running`, `error`, `success`.
- Emit `running` before work and `success` / `error` afterward. Preserve unrelated sections; refresh data without restarting page loading when appropriate.
- Bind page loading/errors through `BaseStateView`; action indicators use `observeRunning`. Do not reintroduce the removed `BaseState.status` / `DataStatus` API.
- Include sections and feature fields in state equality/copying. For part-based states, the cubit declares `part '<name>_state.dart'`; the state declares `part of '<name>_cubit.dart'`.
- Cancel owned subscriptions/timers and close owned controllers in `close()`. Guard async callbacks that can outlive the cubit (`isClosed`); recreate tenant-scoped subscriptions when their context changes.

## Pages and layout

- Pages use `@RoutePage()` and `BaseScaffold`; it provides safe areas, padding, scrolling, annotated region, and refresh. Do not wrap its body in another `SafeArea`.
- Controller-owning pages use `HookWidget` with the appropriate controller hooks, not manual `initState`/`dispose`. `observeRunning` is hook-based and must run in a hook build context with explicit observed section keys.
- Maximum 100 lines per page file; extract page-local widgets to `pages/<name>/widgets/`.
- From `shared_ui/utils/app_sizes.dart`: `gapH*`, `gapW*`, `gapSliverH*` / `gapSliverW*`, and `Sizes.p*` for spacing/padding/radii; no raw spacing literals.
- Use `ScreenUtil.I.getResponsiveValue(base:, screens: {...})` for breakpoints and `MediaQuery.sizeOf(context)` for size. Prevent overflow with `Flexible`, `Expanded`, or `LayoutBuilder` as appropriate.
- Theme access: `context.theme`, `context.colorScheme`, `context.isCupertino`. Colors: `AppColors`; add missing colors there. Use `.withValues(alpha: ...)` for transparency.
- No raw HTTP/data access or faker in UI.

## Required shared widgets

Under `lib/shared_ui/ui/base/`; inspect the component's API before use. These replacements apply to feature UI. Shared wrappers may compose native widgets internally; do not replace them recursively. Missing capability requires an explicit design decision, not silently bypassing the shared component.

| Flutter component | Project replacement |
|---|---|
| Text | `BaseText` (named text styles) |
| Scaffold / AppBar | `BaseScaffold` / `BaseAppBar` |
| ElevatedButton / MaterialButton | `BaseButton` |
| OutlinedButton / TextButton / IconButton | `BaseButton.secondary` / `BaseButton.text` / `BaseIconButton` |
| Icon | `PlatformIcon(materialIcon:, cupertinoIcon:, color:)` |
| TextField / TextFormField | `BaseTextFormField` |
| DropdownButton* | `BaseDropDown` |
| ListTile / Switch / Checkbox | `BaseListTile` / `BaseSwitch` / `BaseCheckbox` |
| ChoiceChip / SegmentedButton | `BaseChoiceChip` / `BaseSegmentedButtons` |
| BottomNavigationBar | `BaseBottomNavigationBar` + `BaseBottomNavigationBarItem` |
| CircularProgressIndicator | `LoadingCircle` |
| AlertDialog / showDialog | `await showAlertDialog(...)` |
| Responsive lists/grids | `ResponsiveListFlow` |
