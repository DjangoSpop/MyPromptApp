import 'package:flutter/material.dart';

/// Discord Design System
/// Implements Discord's color palette, typography, and component styles
/// for a consistent, professional UI/UX
class DiscordDesignSystem {
  // ==================== COLOR PALETTE ====================

  /// Primary brand colors
  static const Color blurple = Color(0xFF5865F2);
  static const Color greyple = Color(0xFF99AAB5);
  static const Color darkNotBlack = Color(0xFF2C2F33);
  static const Color notQuiteBlack = Color(0xFF23272A);
  static const Color white = Color(0xFFFFFFFF);

  /// Semantic colors
  static const Color green = Color(0xFF57F287);
  static const Color yellow = Color(0xFFFEE75C);
  static const Color fuchsia = Color(0xFFEB459E);
  static const Color red = Color(0xFFED4245);
  static const Color orange = Color(0xFFF26522);

  /// Background colors
  static const Color backgroundPrimary = Color(0xFF36393F);
  static const Color backgroundSecondary = Color(0xFF2F3136);
  static const Color backgroundTertiary = Color(0xFF202225);
  static const Color backgroundAccent = Color(0xFF4F545C);
  static const Color backgroundFloating = Color(0xFF18191C);
  static const Color backgroundMobilePrimary = Color(0xFFF2F3F5);
  static const Color backgroundMobileSecondary = Color(0xFFFFFFFF);

  /// Text colors
  static const Color textNormal = Color(0xFFDCDDDE);
  static const Color textMuted = Color(0xFF72767D);
  static const Color textLink = Color(0xFF00AFF4);
  static const Color textPositive = Color(0xFF3BA55D);
  static const Color textWarning = Color(0xFFFAA81A);
  static const Color textDanger = Color(0xFFED4245);

  /// Interactive colors
  static const Color interactiveActive = Color(0xFFDCDDDE);
  static const Color interactiveHover = Color(0xFFB9BBBE);
  static const Color interactiveMuted = Color(0xFF4F545C);
  static const Color interactiveNormal = Color(0xFFB9BBBE);

  // ==================== SPACING ====================

  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // ==================== BORDER RADIUS ====================

  static const double radiusXS = 2.0;
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusRound = 9999.0;

  // ==================== ELEVATION ====================

  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationVeryHigh = 16.0;

  // ==================== TYPOGRAPHY ====================

  static TextTheme get textTheme => const TextTheme(
        // Display styles (32-24px)
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textNormal,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textNormal,
          letterSpacing: -0.25,
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textNormal,
          height: 1.3,
        ),

        // Headline styles (20-18px)
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textNormal,
          height: 1.4,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textNormal,
          height: 1.4,
        ),

        // Title styles (18-14px)
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textNormal,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textNormal,
          height: 1.5,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textNormal,
          height: 1.5,
        ),

        // Body styles (16-14px)
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textNormal,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textNormal,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textMuted,
          height: 1.5,
        ),

        // Label styles (14-10px)
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textNormal,
          letterSpacing: 0.5,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textMuted,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textMuted,
          letterSpacing: 0.5,
          height: 1.3,
        ),
      );

  // ==================== THEME DATA ====================

  static ThemeData get darkTheme => ThemeData(
        // Base settings
        brightness: Brightness.dark,
        primaryColor: blurple,
        scaffoldBackgroundColor: backgroundPrimary,
        useMaterial3: true,

        // Color Scheme
        colorScheme: const ColorScheme.dark(
          primary: blurple,
          secondary: green,
          tertiary: fuchsia,
          surface: backgroundSecondary,
          error: red,
          onPrimary: white,
          onSecondary: notQuiteBlack,
          onSurface: textNormal,
          onError: white,
          outline: backgroundAccent,
        ),

        // Typography
        textTheme: textTheme,
        fontFamily: 'Inter', // Use Inter or Whitney (Discord's font)

        // App Bar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundSecondary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textNormal,
          ),
          iconTheme: IconThemeData(color: textNormal),
        ),

        // Card Theme
        cardTheme: CardTheme(
          color: backgroundSecondary,
          elevation: elevationLow,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          clipBehavior: Clip.antiAlias,
        ),

        // Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: blurple,
            foregroundColor: white,
            elevation: 0,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(
              horizontal: spacingL,
              vertical: spacingM,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusS),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Outlined Button Theme
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: blurple,
            side: const BorderSide(color: blurple, width: 2),
            padding: const EdgeInsets.symmetric(
              horizontal: spacingL,
              vertical: spacingM,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusS),
            ),
          ),
        ),

        // Text Button Theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: blurple,
            padding: const EdgeInsets.symmetric(
              horizontal: spacingM,
              vertical: spacingS,
            ),
          ),
        ),

        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: backgroundTertiary,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: spacingM,
            vertical: spacingM,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusS),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusS),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusS),
            borderSide: const BorderSide(color: blurple, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusS),
            borderSide: const BorderSide(color: red, width: 2),
          ),
          hintStyle: const TextStyle(color: textMuted),
          labelStyle: const TextStyle(color: textNormal),
        ),

        // Chip Theme
        chipTheme: ChipThemeData(
          backgroundColor: backgroundTertiary,
          labelStyle: const TextStyle(color: textNormal, fontSize: 12),
          padding: const EdgeInsets.symmetric(
            horizontal: spacingS,
            vertical: spacingXS,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusS),
          ),
        ),

        // Floating Action Button Theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: blurple,
          foregroundColor: white,
          elevation: elevationMedium,
        ),

        // Bottom Navigation Bar Theme
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: backgroundSecondary,
          selectedItemColor: blurple,
          unselectedItemColor: textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: elevationLow,
        ),

        // Dialog Theme
        dialogTheme: DialogTheme(
          backgroundColor: backgroundSecondary,
          elevation: elevationHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
        ),

        // Divider Theme
        dividerTheme: const DividerThemeData(
          color: backgroundAccent,
          thickness: 1,
          space: spacingM,
        ),

        // Icon Theme
        iconTheme: const IconThemeData(
          color: textNormal,
          size: 24,
        ),

        // Progress Indicator Theme
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: blurple,
          linearTrackColor: backgroundAccent,
        ),
      );

  // ==================== LIGHT THEME (Optional) ====================

  static ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        primaryColor: blurple,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        useMaterial3: true,

        colorScheme: const ColorScheme.light(
          primary: blurple,
          secondary: green,
          surface: Color(0xFFF2F3F5),
          error: red,
          onPrimary: white,
          onSecondary: white,
          onSurface: notQuiteBlack,
          onError: white,
        ),

        textTheme: textTheme.apply(
          bodyColor: notQuiteBlack,
          displayColor: notQuiteBlack,
        ),

        // Similar component themes adapted for light mode
        // ... (abbreviated for brevity)
      );

  // ==================== HELPER METHODS ====================

  /// Get gradient for premium features
  static LinearGradient get premiumGradient => const LinearGradient(
        colors: [blurple, fuchsia],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Get success color gradient
  static LinearGradient get successGradient => const LinearGradient(
        colors: [green, Color(0xFF2ECC71)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Get warning color gradient
  static LinearGradient get warningGradient => const LinearGradient(
        colors: [orange, yellow],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Get danger color gradient
  static LinearGradient get dangerGradient => const LinearGradient(
        colors: [red, Color(0xFFC0392B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Get box shadow for elevated components
  static List<BoxShadow> getElevation(double elevation) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.15),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation),
      ),
    ];
  }

  /// Get shimmer gradient for loading states
  static LinearGradient get shimmerGradient => LinearGradient(
        colors: [
          backgroundTertiary,
          backgroundAccent,
          backgroundTertiary,
        ],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
