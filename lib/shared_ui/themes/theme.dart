import 'package:clean_architecture/core/constants/app_colors.dart';
import 'package:clean_architecture/shared_ui/utils/app_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'theme_data.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  colorScheme: colorScheme,
  fontFamily: 'Poppins',
  scaffoldBackgroundColor: AppColors.surface,
  appBarTheme: appBarTheme,
  iconTheme: iconThemeData,
  inputDecorationTheme: inputDecorationTheme,
  checkboxTheme: checkBoxThemeData,
  listTileTheme: listTileThemeData,
  bottomNavigationBarTheme: bottomNavigationBarTheme,
  // platform: TargetPlatform.iOS,
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  colorScheme: darkColorScheme,
  fontFamily: 'Poppins',
  scaffoldBackgroundColor: const Color(0xFF121214),
  appBarTheme: darkAppBarTheme,
  iconTheme: darkIconThemeData,
  inputDecorationTheme: darkInputDecorationTheme,
  checkboxTheme: checkBoxThemeData,
  listTileTheme: listTileThemeData,
  bottomNavigationBarTheme: darkBottomNavigationBarTheme,
);
