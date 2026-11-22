import 'package:flutter/material.dart';

/// The only file that knows colours, text sizes, radii and spacing.
/// Screens read everything through `Theme.of(context)` (and
/// `context.tokens`, which is a [ThemeExtension] on the same theme).
///
/// Token values are taken from the Figma reference frames
/// (docs/design-1.png, docs/design-2.png); see design_credit.dart.
abstract final class AppTheme {
  // Colour tokens.
  static const _paper = Color(0xFFF6F4EF); // page background
  static const _card = Color(0xFFFFFFFF);
  static const _well = Color(0xFFEEEBE4); // image frame, bar track
  static const _hairline = Color(0xFFE2DDD3);
  static const _rule = Color(0xFFC9C2B5);
  static const _ink = Color(0xFF1A1C1E);
  static const _inkMuted = Color(0xFF5E636B);

  static const _forest = Color(0xFF17694F); // primary, camera
  static const _forestTint = Color(0xFFD3ECE2);
  static const _forestDeep = Color(0xFF0A3A2B);
  static const _indigo = Color(0xFF3E4FA8); // gallery
  static const _indigoTint = Color(0xFFE0E4FA);
  static const _indigoDeep = Color(0xFF1A2463);
  static const _amber = Color(0xFFB7791F); // download
  static const _amberTint = Color(0xFFFBEBCF);
  static const _amberDeep = Color(0xFF4F3200);
  static const _red = Color(0xFFB3261E);
  static const _redTint = Color(0xFFF9DEDC);
  static const _redDeep = Color(0xFF410E0B);

  // Shape and spacing tokens.
  static const _radiusS = 10.0;
  static const _radiusM = 16.0;
  static const _radiusL = 24.0;

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: _forest,
      onPrimary: _card,
      primaryContainer: _forestTint,
      onPrimaryContainer: _forestDeep,
      secondary: _indigo,
      onSecondary: _card,
      secondaryContainer: _indigoTint,
      onSecondaryContainer: _indigoDeep,
      tertiary: _amber,
      onTertiary: _card,
      tertiaryContainer: _amberTint,
      onTertiaryContainer: _amberDeep,
      error: _red,
      onError: _card,
      errorContainer: _redTint,
      onErrorContainer: _redDeep,
      surface: _paper,
      onSurface: _ink,
      onSurfaceVariant: _inkMuted,
      surfaceContainerLowest: _card,
      surfaceContainerLow: _card,
      surfaceContainer: _card,
      surfaceContainerHigh: _well,
      surfaceContainerHighest: _well,
      outline: _rule,
      outlineVariant: _hairline,
      inverseSurface: _ink,
      onInverseSurface: _paper,
      inversePrimary: _forestTint,
      shadow: _ink,
      scrim: _ink,
    );

    const text = TextTheme(
      displaySmall: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -1.2, height: 1.05),
      headlineSmall: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.15),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.2, height: 1.2),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.3),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.3),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.45),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.4),
      bodySmall: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w400, height: 1.35),
      labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      labelMedium: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4),
    );
    final textTheme = text.apply(bodyColor: _ink, displayColor: _ink);

    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radiusM));
    const buttonSize = Size(64, 52);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: _paper,
      splashFactory: InkSparkle.splashFactory,
      extensions: const [AppTokens.standard],
      appBarTheme: AppBarTheme(
        backgroundColor: _paper,
        foregroundColor: _ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: _card,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radiusL),
          side: const BorderSide(color: _hairline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: buttonSize, shape: buttonShape, textStyle: textTheme.labelLarge),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          foregroundColor: _ink,
          side: const BorderSide(color: _rule),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _forest, shape: buttonShape, textStyle: textTheme.labelLarge),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _card,
        side: const BorderSide(color: _hairline),
        shape: const StadiumBorder(),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _card,
        surfaceTintColor: Colors.transparent,
        indicatorColor: _forestTint,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusM),
          borderSide: const BorderSide(color: _rule),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusM),
          borderSide: const BorderSide(color: _rule),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radiusM),
          borderSide: const BorderSide(color: _forest, width: 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _ink,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: _paper),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radiusS)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _paper,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _paper,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radiusL)),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        minVerticalPadding: 12,
      ),
      dividerTheme: const DividerThemeData(color: _hairline, space: 1, thickness: 1),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _forest,
        linearTrackColor: _well,
        circularTrackColor: _well,
      ),
    );
  }
}

/// Spacing, radii and sizes that Material has no slot for.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.gutter,
    required this.gapXs,
    required this.gapS,
    required this.gapM,
    required this.gapL,
    required this.gapXl,
    required this.radiusS,
    required this.radiusM,
    required this.radiusL,
    required this.thumbnail,
    required this.barHeight,
    required this.imageMaxFraction,
  });

  static const standard = AppTokens(
    gutter: 20,
    gapXs: 4,
    gapS: 8,
    gapM: 12,
    gapL: 16,
    gapXl: 28,
    radiusS: AppTheme._radiusS,
    radiusM: AppTheme._radiusM,
    radiusL: AppTheme._radiusL,
    thumbnail: 56,
    barHeight: 8,
    imageMaxFraction: 0.45,
  );

  final double gutter; // distance from text to the screen edge
  final double gapXs, gapS, gapM, gapL, gapXl;
  final double radiusS, radiusM, radiusL;
  final double thumbnail;
  final double barHeight;
  final double imageMaxFraction; // result image: at most this much of the screen

  @override
  AppTokens copyWith({double? gutter}) => AppTokens(
    gutter: gutter ?? this.gutter,
    gapXs: gapXs,
    gapS: gapS,
    gapM: gapM,
    gapL: gapL,
    gapXl: gapXl,
    radiusS: radiusS,
    radiusM: radiusM,
    radiusL: radiusL,
    thumbnail: thumbnail,
    barHeight: barHeight,
    imageMaxFraction: imageMaxFraction,
  );

  @override
  AppTokens lerp(AppTokens? other, double t) => t < 0.5 || other == null ? this : other;
}

extension AppTokensContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}
