part of 'theme.dart';

/// Color Scheme
ColorScheme get colorScheme => ColorScheme.fromSeed(
  seedColor: AppColors.primary,
  surface: AppColors.surface,
  onSurface: AppColors.onSurface,
  error: AppColors.error,
);

IconThemeData get iconThemeData =>
    const IconThemeData(color: AppColors.primaryLight);

ColorScheme get darkColorScheme => ColorScheme.fromSeed(
  seedColor: AppColors.primary,
  brightness: Brightness.dark,
  surface: const Color(0xFF1E1E22),
  onSurface: const Color(0xFFE2E8F0),
  error: AppColors.error,
);

IconThemeData get darkIconThemeData =>
    const IconThemeData(color: AppColors.primaryLight);

/// App ar Theme
AppBarTheme get appBarTheme => const AppBarTheme(
  backgroundColor: AppColors.white,
  surfaceTintColor: Colors.transparent,
  iconTheme: IconThemeData(color: AppColors.black),
  elevation: 0,
  systemOverlayStyle: SystemUiOverlayStyle(
    statusBarColor: AppColors.white,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ),
);

AppBarTheme get darkAppBarTheme => const AppBarTheme(
  backgroundColor: Color(0xFF121214),
  surfaceTintColor: Colors.transparent,
  iconTheme: IconThemeData(color: Color(0xFFE2E8F0)),
  elevation: 0,
  systemOverlayStyle: SystemUiOverlayStyle(
    statusBarColor: Color(0xFF121214),
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ),
);

/// InputDecoration Theme
OutlineInputBorder outlinedInputBorder(Color color) => OutlineInputBorder(
  borderRadius: const BorderRadius.all(Radius.circular(Sizes.p12)),
  borderSide: BorderSide(color: color, width: 2),
);
InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
  hintStyle: const TextStyle(color: AppColors.fade, fontSize: 14),
  enabledBorder: outlinedInputBorder(AppColors.border),
  focusedBorder: outlinedInputBorder(AppColors.primary),
  errorBorder: outlinedInputBorder(AppColors.red600),
  focusedErrorBorder: outlinedInputBorder(AppColors.red600),
);

InputDecorationTheme get darkInputDecorationTheme => InputDecorationTheme(
  hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
  enabledBorder: outlinedInputBorder(const Color(0xFF334155)),
  focusedBorder: outlinedInputBorder(AppColors.primary),
  errorBorder: outlinedInputBorder(AppColors.red600),
  focusedErrorBorder: outlinedInputBorder(AppColors.red600),
);

/// Elevated Button Theme
ElevatedButtonThemeData getElevatedButtonTheme(ColorScheme colorScheme) =>
    ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: colorScheme.primary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Sizes.p8)),
        ),
      ),
    );

/// Outlined Button Theme
OutlinedButtonThemeData get outlinedButtonTheme => OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(Sizes.p8)),
    ),
    elevation: 0,
    splashFactory: InkRipple.splashFactory,
  ),
);

/// Chip Theme
ChipThemeData getChipTheme(ColorScheme colorScheme) => ChipThemeData(
  checkmarkColor: Colors.white,
  labelStyle: TextStyle(color: colorScheme.onSurface, fontSize: 12),
);

/// CheckBox Theme
CheckboxThemeData getCheckBoxTheme(ColorScheme colorScheme) =>
    CheckboxThemeData(
      visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Sizes.p4)),
      ),
      fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return Colors.transparent;
      }),
      side: BorderSide(
        color: colorScheme.onSurface.withValues(alpha: 0.5),
        width: 1.2,
      ),
    );

/// ListTile Theme
ListTileThemeData get listTileThemeData => const ListTileThemeData(
  dense: true,
  contentPadding: EdgeInsets.zero,
  // If zero is given than it will take default top padding
  minVerticalPadding: 1,
  horizontalTitleGap: 0,
  minLeadingWidth: 0,
);

ExpansionTileThemeData get expansionTileThemeData =>
    const ExpansionTileThemeData(
      childrenPadding: EdgeInsets.all(Sizes.p8),
      tilePadding: EdgeInsets.all(Sizes.p8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Sizes.p8)),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Sizes.p8)),
      ),
      iconColor: AppColors.primary,
      textColor: AppColors.primary,
      collapsedIconColor: AppColors.fade,
      collapsedTextColor: AppColors.onSurface,
    );

ExpansionTileThemeData get darkExpansionTileThemeData =>
    const ExpansionTileThemeData(
      childrenPadding: EdgeInsets.all(Sizes.p8),
      tilePadding: EdgeInsets.all(Sizes.p8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Sizes.p8)),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Sizes.p8)),
      ),
      iconColor: AppColors.primaryLight,
      textColor: AppColors.primaryLight,
      collapsedIconColor: Color(0xFF64748B),
      collapsedTextColor: Color(0xFFE2E8F0),
      backgroundColor: AppColors.fadeLight,
    );

/// Bottom Navigation Bar Themes
BottomNavigationBarThemeData get bottomNavigationBarTheme =>
    const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Color(0x995E6A75), // AppColors.fade.withAlpha(153)
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    );

BottomNavigationBarThemeData get darkBottomNavigationBarTheme =>
    const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E22),
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Color(0xFF64748B),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    );

CardThemeData get cardTheme =>
    const CardThemeData(margin: EdgeInsets.symmetric(vertical: Sizes.p4));

CardThemeData get darkCardTheme => const CardThemeData(
  margin: EdgeInsets.symmetric(vertical: Sizes.p4),
  color: AppColors.fadeLight,
  elevation: 0,
);

/// Slider Theme
SliderThemeData getSliderTheme(ColorScheme colorScheme) => SliderThemeData(
  activeTrackColor: colorScheme.primary,
  inactiveTrackColor: colorScheme.primary.withValues(alpha: 0.2),
  thumbColor: colorScheme.primary,
  overlayColor: colorScheme.primary.withValues(alpha: 0.12),
  rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 6),
  rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
  trackHeight: 3,
  showValueIndicator: ShowValueIndicator.never,
);

