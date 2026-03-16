import 'package:flutter/material.dart';

/// Application theme definitions.
class AppTheme {
  AppTheme._();

  static const _primaryColor = Color(0xFF6C5CE7);
  static const _secondaryColor = Color(0xFF00B894);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: _primaryColor,
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF2D3436),
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE9ECEF)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1F3F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: 0,
    ),
    extensions: const [
      BrowserThemeExtension(
        toolbarColor: Colors.white,
        addressBarColor: Color(0xFFF1F3F5),
        tabBarColor: Color(0xFFF8F9FA),
        activeTabColor: Colors.white,
        inactiveTabColor: Color(0xFFE9ECEF),
        shieldsActiveColor: _secondaryColor,
        shieldsInactiveColor: Color(0xFFADB5BD),
        incognitoColor: Color(0xFF2D3436),
      ),
    ],
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: _primaryColor,
    scaffoldBackgroundColor: const Color(0xFF1A1A2E),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Color(0xFF16213E),
      foregroundColor: Color(0xFFE9ECEF),
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF2D3436)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0F3460),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    extensions: const [
      BrowserThemeExtension(
        toolbarColor: Color(0xFF16213E),
        addressBarColor: Color(0xFF0F3460),
        tabBarColor: Color(0xFF1A1A2E),
        activeTabColor: Color(0xFF16213E),
        inactiveTabColor: Color(0xFF0F3460),
        shieldsActiveColor: _secondaryColor,
        shieldsInactiveColor: Color(0xFF6C757D),
        incognitoColor: Color(0xFF0F3460),
      ),
    ],
  );
}

/// Custom theme extension for browser-specific colors.
class BrowserThemeExtension extends ThemeExtension<BrowserThemeExtension> {
  final Color toolbarColor;
  final Color addressBarColor;
  final Color tabBarColor;
  final Color activeTabColor;
  final Color inactiveTabColor;
  final Color shieldsActiveColor;
  final Color shieldsInactiveColor;
  final Color incognitoColor;

  const BrowserThemeExtension({
    required this.toolbarColor,
    required this.addressBarColor,
    required this.tabBarColor,
    required this.activeTabColor,
    required this.inactiveTabColor,
    required this.shieldsActiveColor,
    required this.shieldsInactiveColor,
    required this.incognitoColor,
  });

  @override
  BrowserThemeExtension copyWith({
    Color? toolbarColor,
    Color? addressBarColor,
    Color? tabBarColor,
    Color? activeTabColor,
    Color? inactiveTabColor,
    Color? shieldsActiveColor,
    Color? shieldsInactiveColor,
    Color? incognitoColor,
  }) {
    return BrowserThemeExtension(
      toolbarColor: toolbarColor ?? this.toolbarColor,
      addressBarColor: addressBarColor ?? this.addressBarColor,
      tabBarColor: tabBarColor ?? this.tabBarColor,
      activeTabColor: activeTabColor ?? this.activeTabColor,
      inactiveTabColor: inactiveTabColor ?? this.inactiveTabColor,
      shieldsActiveColor: shieldsActiveColor ?? this.shieldsActiveColor,
      shieldsInactiveColor: shieldsInactiveColor ?? this.shieldsInactiveColor,
      incognitoColor: incognitoColor ?? this.incognitoColor,
    );
  }

  @override
  BrowserThemeExtension lerp(BrowserThemeExtension? other, double t) {
    if (other is! BrowserThemeExtension) return this;
    return BrowserThemeExtension(
      toolbarColor: Color.lerp(toolbarColor, other.toolbarColor, t)!,
      addressBarColor: Color.lerp(addressBarColor, other.addressBarColor, t)!,
      tabBarColor: Color.lerp(tabBarColor, other.tabBarColor, t)!,
      activeTabColor: Color.lerp(activeTabColor, other.activeTabColor, t)!,
      inactiveTabColor: Color.lerp(inactiveTabColor, other.inactiveTabColor, t)!,
      shieldsActiveColor: Color.lerp(shieldsActiveColor, other.shieldsActiveColor, t)!,
      shieldsInactiveColor: Color.lerp(shieldsInactiveColor, other.shieldsInactiveColor, t)!,
      incognitoColor: Color.lerp(incognitoColor, other.incognitoColor, t)!,
    );
  }
}
