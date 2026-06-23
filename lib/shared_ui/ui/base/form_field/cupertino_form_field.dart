part of 'base_text_form_field.dart';

class CupertinoFormField extends StatefulWidget {
  const CupertinoFormField({super.key, required this.baseTextFormField});
  final BaseTextFormField baseTextFormField;

  @override
  State<CupertinoFormField> createState() => _CupertinoFormFieldState();
}

class _CupertinoFormFieldState extends State<CupertinoFormField> {
  FormFieldState<String>? _formFieldState;
  final overlayManager = OverlayManager();

  @override
  void initState() {
    super.initState();

    widget.baseTextFormField.focusNode?.addListener(_updateOverlayState);
    widget.baseTextFormField.controller?.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.baseTextFormField.focusNode?.removeListener(_updateOverlayState);
    widget.baseTextFormField.controller?.removeListener(_onControllerChanged);
    overlayManager.hide();
    super.dispose();
  }

  void _onControllerChanged() {
    if (_formFieldState?.value != widget.baseTextFormField.controller?.text) {
      _formFieldState?.didChange(widget.baseTextFormField.controller?.text);
    }
  }

  void _updateOverlayState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 100), () {});
      if (!mounted) {
        return;
      }
      final btf = widget.baseTextFormField;
      final hasFocus = btf.focusNode?.hasFocus ?? false;
      final isKeyboardOpen = context.read<KeyboardVisibilityCubit>().state;

      if (hasFocus && isKeyboardOpen && isNumeric) {
        //TODO test this on an iOS device
        debugPrint('show');
        _showOverlay();
      } else if (!hasFocus) {
        debugPrint('Hide');
        overlayManager.hide();
      }
    });
  }

  void _showOverlay() {
    final dtf = widget.baseTextFormField;
    overlayManager.showDoneBar(
      context: context,
      focusNode: dtf.focusNode,
      onDone: () {
        if (dtf.onFieldSubmitted != null) {
          dtf.onFieldSubmitted?.call(dtf.controller?.text ?? '');
        } else if (dtf.onEditingComplete != null) {
          dtf.onEditingComplete?.call();
        } else {
          dtf.focusNode?.unfocus();
        }
      },
    );
  }

  bool get isNumeric =>
      widget.baseTextFormField.keyboardType == TextInputType.number ||
      widget.baseTextFormField.keyboardType ==
          const TextInputType.numberWithOptions(decimal: true) ||
      widget.baseTextFormField.keyboardType == TextInputType.number;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dtf = widget.baseTextFormField;
    final isEnabled = dtf.enabled ?? true;

    if (dtf.focusNode == null &&
        (dtf.keyboardType == TextInputType.number ||
            dtf.keyboardType ==
                const TextInputType.numberWithOptions(decimal: true))) {
      debugPrint('iOS numeric keyboard without focus node');
    }

    return FormField<String>(
      key: dtf.key,
      validator: dtf.validator,
      enabled: isEnabled,
      initialValue: dtf.controller?.text,
      autovalidateMode: dtf.autovalidateMode,
      builder: (state) {
        _formFieldState = state;

        final fillColor = isEnabled
            ? CupertinoColors.tertiarySystemFill.resolveFrom(context)
            : colorScheme.onSurface.withAlpha(25);

        final Border? border = state.hasError
            ? Border.all(color: CupertinoColors.destructiveRed)
            : !isEnabled
            ? Border.all(color: colorScheme.onSurface.withAlpha(20))
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dtf.labelText != null) ...[
              gapH8,
              Text(
                dtf.labelText!,
                style: TextStyle(
                  color: isEnabled
                      ? colorScheme.onSurface.withAlpha(200)
                      : colorScheme.onSurface.withAlpha(100),
                  fontSize: 12,
                ),
              ),
              gapH4,
            ],
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: Sizes.p48),
              child: CupertinoTextField(
                scrollPadding: const EdgeInsets.only(bottom: Sizes.p80),
                onTap: dtf.onTap,
                onEditingComplete: dtf.onEditingComplete,
                inputFormatters: dtf.inputFormatters,
                controller: dtf.controller,
                textInputAction: dtf.textInputAction,
                minLines: 1,
                maxLines: dtf.maxLines ?? 1,
                placeholder: dtf.hintText,
                autofocus: dtf.autofocus ?? false,
                autofillHints: dtf.autofillHints,
                style: TextStyle(
                  color: isEnabled
                      ? null
                      : colorScheme.onSurface.withAlpha(100),
                ),
                placeholderStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: isEnabled
                      ? colorScheme.onSurface.withAlpha(125)
                      : colorScheme.onSurface.withAlpha(100),
                  fontSize: 12,
                ),
                textAlignVertical: TextAlignVertical.center,
                obscureText: dtf.obscureText,
                onSubmitted: dtf.onFieldSubmitted,
                enabled: isEnabled,
                focusNode: dtf.focusNode,
                maxLength: dtf.maxLength,
                onChanged: (value) {
                  dtf.onChanged?.call(value);
                  state.didChange(value);
                },
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(Sizes.p8),
                  border: border,
                ),
                keyboardType: dtf.keyboardType,
                prefix: dtf.prefixIcon == null
                    ? null
                    : _BuildIcon(widget: dtf.prefixIcon!),
                suffix: dtf.suffixIcon == null
                    ? null
                    : _BuildIcon(widget: dtf.suffixIcon!),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: Sizes.p8, top: Sizes.p4),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(
                    color: CupertinoColors.destructiveRed,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _BuildIcon extends StatelessWidget {
  const _BuildIcon({required this.widget});
  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: Sizes.p48,
        minHeight: Sizes.p48,
      ),
      child: Center(child: widget),
    );
  }
}
