part of 'theme.dart';

/// Color Scheme
ColorScheme get colorScheme => ColorScheme.fromSeed(
  seedColor: AppColors.primary,
  surface: AppColors.surface,
  onSurface: AppColors.onSurface,
  error: AppColors.error,
);

IconThemeData get iconThemeData => IconThemeData(color: colorScheme.onSurface);

ColorScheme get darkColorScheme => ColorScheme.fromSeed(
  seedColor: AppColors.primary,
  brightness: Brightness.dark,
  surface: const Color(0xFF1E1E22),
  onSurface: const Color(0xFFE2E8F0),
  error: AppColors.error,
);

IconThemeData get darkIconThemeData =>
    IconThemeData(color: darkColorScheme.onSurface);

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

/// CheckBox Theme
CheckboxThemeData get checkBoxThemeData => const CheckboxThemeData(
  visualDensity: VisualDensity(horizontal: -3, vertical: -3),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(Sizes.p4)),
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
