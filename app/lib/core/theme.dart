import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Fixed semantic colours (same in both themes) + surfaces.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.callGreen,
    required this.endRed,
    required this.holdAmber,
    required this.regOk,
    required this.regWarn,
    required this.regFail,
    required this.disabled,
    required this.raised,
    required this.card,
  });

  final Color callGreen;
  final Color endRed;
  final Color holdAmber;
  final Color regOk;
  final Color regWarn;
  final Color regFail;
  final Color disabled;
  final Color raised;
  final Color card;

  static const _base = AppColors(
    callGreen: Color(0xFF16A34A),
    endRed: Color(0xFFDC2626),
    holdAmber: Color(0xFFD97706),
    regOk: Color(0xFF22C55E),
    regWarn: Color(0xFFF59E0B),
    regFail: Color(0xFFEF4444),
    disabled: Color(0xFF9CA3AF),
    raised: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
  );

  static const light = _base;
  static final dark = AppColors(
    callGreen: _base.callGreen,
    endRed: _base.endRed,
    holdAmber: _base.holdAmber,
    regOk: _base.regOk,
    regWarn: _base.regWarn,
    regFail: _base.regFail,
    disabled: _base.disabled,
    raised: const Color(0xFF232733),
    card: const Color(0xFF171A21),
  );

  @override
  AppColors copyWith({Color? raised, Color? card}) => AppColors(
    callGreen: callGreen,
    endRed: endRed,
    holdAmber: holdAmber,
    regOk: regOk,
    regWarn: regWarn,
    regFail: regFail,
    disabled: disabled,
    raised: raised ?? this.raised,
    card: card ?? this.card,
  );

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) => this;
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

const double kRadius = 12;
const double kSheetRadius = 24;

/// Tabular figures style for dialler field and timers.
TextStyle tabular(TextStyle? base) => (base ?? const TextStyle()).copyWith(
  fontFeatures: const [FontFeature.tabularFigures()],
);

/// Families tried, in order, for glyphs Inter lacks (Arabic, Devanagari, CJK).
///
/// Flutter on Linux does not fall back to arbitrary installed fonts: only the
/// families named in `fontFamilyFallback` are searched for a missing glyph, and
/// Material's default list (Ubuntu, Cantarell, DejaVu Sans, Liberation Sans,
/// Arial) covers Arabic via DejaVu but not Devanagari or CJK. A style that sets
/// its own `fontFamily` and lands in a `DefaultTextStyle` that replaces the
/// ambient one (the NavigationRail labels) has no list at all, so Arabic
/// rendered as boxes there. Names that are not installed are skipped.
const List<String> kFontFallback = [
  'Noto Sans',
  'Noto Sans Arabic',
  'Noto Sans Arabic UI',
  'Noto Naskh Arabic',
  'Noto Sans Devanagari',
  'Noto Sans Devanagari UI',
  'Noto Sans CJK SC',
  'Noto Sans CJK JP',
  'Noto Sans SC',
  'Noto Sans JP',
  'Ubuntu',
  'Cantarell',
  'DejaVu Sans',
  'Liberation Sans',
  'Arial',
];

ThemeData buildTheme(Brightness brightness, {Color accent = const Color(0xFF3F51E0), bool compact = false}) {
  final theme = _buildTheme(brightness, accent, compact);
  return theme.copyWith(
    textTheme: theme.textTheme.apply(fontFamilyFallback: kFontFallback),
    primaryTextTheme: theme.primaryTextTheme.apply(fontFamilyFallback: kFontFallback),
  );
}

ThemeData _buildTheme(Brightness brightness, Color accent, bool compact) {
  final dark = brightness == Brightness.dark;
  final base = ColorScheme.fromSeed(seedColor: accent, brightness: brightness);
  final scheme = base.copyWith(
    primary: dark ? Color.lerp(accent, Colors.white, 0.28) : accent,
    onPrimary: dark ? const Color(0xFF0F1115) : Colors.white,
    surface: dark ? const Color(0xFF0F1115) : const Color(0xFFF7F8FA),
    surfaceContainerLowest: dark ? const Color(0xFF0F1115) : Colors.white,
    surfaceContainerLow: dark ? const Color(0xFF171A21) : Colors.white,
    surfaceContainer: dark ? const Color(0xFF171A21) : Colors.white,
    surfaceContainerHigh: dark ? const Color(0xFF232733) : const Color(0xFFEEF0F4),
    surfaceContainerHighest: dark ? const Color(0xFF2B303D) : const Color(0xFFE6E9EF),
    error: const Color(0xFFDC2626),
  );
  final colors = dark ? AppColors.dark : AppColors.light;
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius));
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(kRadius),
    borderSide: BorderSide(color: scheme.outlineVariant),
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: scheme.surface,
    extensions: [colors],
    visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
    cardTheme: CardThemeData(
      color: colors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadius),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: dark ? 0.5 : 0.7)),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: kFontFallback,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.card,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: scheme.primary, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(44, 44),
        shape: shape,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(minimumSize: const Size(44, 44), shape: shape),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: const Size(44, 44), shape: shape),
    ),
    listTileTheme: ListTileThemeData(
      shape: shape,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant.withValues(alpha: 0.6), space: 1, thickness: 1),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.card,
      surfaceTintColor: Colors.transparent,
      indicatorColor: scheme.primary.withValues(alpha: dark ? 0.22 : 0.12),
      height: 68,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontFamily: 'Inter', fontFamilyFallback: kFontFallback, fontSize: 12, fontWeight: FontWeight.w500, color: scheme.onSurface),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: colors.card,
      indicatorColor: scheme.primary.withValues(alpha: dark ? 0.22 : 0.12),
      selectedLabelTextStyle: TextStyle(fontFamily: 'Inter', fontFamilyFallback: kFontFallback, fontWeight: FontWeight.w600, color: scheme.primary),
      unselectedLabelTextStyle: TextStyle(fontFamily: 'Inter', fontFamilyFallback: kFontFallback, color: scheme.onSurfaceVariant),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.card,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kSheetRadius)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kSheetRadius)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: shape,
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: BorderSide(color: scheme.outlineVariant),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Colors.white : null,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}

SystemUiOverlayStyle overlayFor(Brightness b) => b == Brightness.dark
    ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
    : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent);

/// Layout breakpoints.
enum LayoutSize { compact, medium, expanded }

LayoutSize layoutFor(double width) => width >= 840
    ? LayoutSize.expanded
    : width >= 600
    ? LayoutSize.medium
    : LayoutSize.compact;

extension LayoutX on BuildContext {
  double get _w => MediaQuery.sizeOf(this).width;
  LayoutSize get layout => layoutFor(_w);
  bool get isExpanded => _w >= 840;
  bool get isCompact => _w < 840;
}
