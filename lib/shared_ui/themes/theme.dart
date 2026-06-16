import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'theme_data.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  primaryColorLight: AppColors.primaryLight,
  colorScheme: colorScheme,
  fontFamily: 'Poppins',
  scaffoldBackgroundColor: AppColors.surface,
  appBarTheme: appBarTheme,
  iconTheme: iconThemeData,
  inputDecorationTheme: inputDecorationTheme,
  elevatedButtonTheme: getElevatedButtonTheme(colorScheme),
  outlinedButtonTheme: outlinedButtonTheme,
  chipTheme: getChipTheme(colorScheme),
  checkboxTheme: getCheckBoxTheme(colorScheme),
  listTileTheme: listTileThemeData,
  bottomNavigationBarTheme: bottomNavigationBarTheme,
  expansionTileTheme: expansionTileThemeData,
  // platform: TargetPlatform.iOS,
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  primaryColorLight: AppColors.primaryLight,
  colorScheme: darkColorScheme,
  fontFamily: 'Poppins',
  scaffoldBackgroundColor: const Color(0xFF121214),
  appBarTheme: darkAppBarTheme,
  iconTheme: darkIconThemeData,
  inputDecorationTheme: darkInputDecorationTheme,
  elevatedButtonTheme: getElevatedButtonTheme(darkColorScheme),
  outlinedButtonTheme: outlinedButtonTheme,
  chipTheme: getChipTheme(darkColorScheme),
  checkboxTheme: getCheckBoxTheme(darkColorScheme),
  listTileTheme: listTileThemeData,
  bottomNavigationBarTheme: darkBottomNavigationBarTheme,
  expansionTileTheme: darkExpansionTileThemeData,
);
