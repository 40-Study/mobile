import 'package:flutter/material.dart';

/// The visual foundation for 40Study.
///
/// The palette is intentionally restrained: neutral surfaces carry the UI,
/// blue communicates action, and teal/amber are reserved for status.
class MaterialTheme {
  const MaterialTheme(this.textTheme);

  final TextTheme textTheme;

  static const brandMagenta = Color(0xFFBE185D);
  static const brandOrange = Color(0xFFB45309);
  static const darkBlue = Color(0xFF14171F);
  static const softLavender = Color(0xFFDCE4FF);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF3D5FC4),
      surfaceTint: Colors.transparent,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFEDF1FF),
      onPrimaryContainer: Color(0xFF17327F),
      inversePrimary: Color(0xFFB9C7FF),
      secondary: Color(0xFF087F73),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFE4F5F1),
      onSecondaryContainer: Color(0xFF075A53),
      tertiary: Color(0xFFB86B12),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFFFF0DD),
      onTertiaryContainer: Color(0xFF7C3E08),
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF93000A),
      surface: Color(0xFFF8F9FC),
      onSurface: Color(0xFF24262E),
      onSurfaceVariant: Color(0xFF707480),
      outline: Color(0xFFE7E9EF),
      outlineVariant: Color(0xFFF0F1F5),
      shadow: Color(0xFF111318),
      scrim: Color(0xFF111318),
      inverseSurface: Color(0xFF2F3037),
      onInverseSurface: Color(0xFFF3F3F5),
      surfaceDim: Color(0xFFEDEEF2),
      surfaceBright: Color(0xFFFFFFFF),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF4F5F8),
      surfaceContainer: Color(0xFFF0F1F5),
      surfaceContainerHigh: Color(0xFFEBEDF2),
      surfaceContainerHighest: Color(0xFFE5E8EE),
      primaryFixed: Color(0xFFE9EEFF),
      onPrimaryFixed: Color(0xFF17327F),
      primaryFixedDim: Color(0xFFCAD5FF),
      onPrimaryFixedVariant: Color(0xFF2948AA),
      secondaryFixed: Color(0xFFDDF4EF),
      onSecondaryFixed: Color(0xFF075A53),
      secondaryFixedDim: Color(0xFFB8E4DB),
      onSecondaryFixedVariant: Color(0xFF087F73),
      tertiaryFixed: Color(0xFFFFEDD5),
      onTertiaryFixed: Color(0xFF7C3E08),
      tertiaryFixedDim: Color(0xFFF4D1A6),
      onTertiaryFixedVariant: Color(0xFF9A570E),
    );
  }

  ThemeData light() => theme(lightScheme());

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFBAC8FF),
      surfaceTint: Colors.transparent,
      onPrimary: Color(0xFF10276D),
      primaryContainer: Color(0xFF283866),
      onPrimaryContainer: Color(0xFFE4E9FF),
      inversePrimary: Color(0xFF3157D5),
      secondary: Color(0xFF87D5C9),
      onSecondary: Color(0xFF003731),
      secondaryContainer: Color(0xFF164842),
      onSecondaryContainer: Color(0xFFB4EEE5),
      tertiary: Color(0xFFF3C17E),
      onTertiary: Color(0xFF4C2A00),
      tertiaryContainer: Color(0xFF59401E),
      onTertiaryContainer: Color(0xFFFFE2BA),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: Color(0xFF12151B),
      onSurface: Color(0xFFE7E5EA),
      onSurfaceVariant: Color(0xFFB8BAC4),
      outline: Color(0xFF343943),
      outlineVariant: Color(0xFF252A33),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: Color(0xFFE5E2E8),
      onInverseSurface: Color(0xFF2F3036),
      surfaceDim: Color(0xFF0F1217),
      surfaceBright: Color(0xFF343840),
      surfaceContainerLowest: Color(0xFF181B22),
      surfaceContainerLow: Color(0xFF161920),
      surfaceContainer: Color(0xFF1C1F27),
      surfaceContainerHigh: Color(0xFF232730),
      surfaceContainerHighest: Color(0xFF2B3039),
      primaryFixed: Color(0xFFDCE4FF),
      onPrimaryFixed: Color(0xFF10276D),
      primaryFixedDim: Color(0xFFB9C7FF),
      onPrimaryFixedVariant: Color(0xFF2948AA),
      secondaryFixed: Color(0xFFB4EEE5),
      onSecondaryFixed: Color(0xFF003731),
      secondaryFixedDim: Color(0xFF87D5C9),
      onSecondaryFixedVariant: Color(0xFF075A53),
      tertiaryFixed: Color(0xFFFFDDB0),
      onTertiaryFixed: Color(0xFF321A00),
      tertiaryFixedDim: Color(0xFFF3C17E),
      onTertiaryFixedVariant: Color(0xFF68400E),
    );
  }

  ThemeData dark() => theme(darkScheme());

  ThemeData theme(ColorScheme colors) {
    final resolvedTextTheme = textTheme.apply(
      bodyColor: colors.onSurface,
      displayColor: colors.onSurface,
    );
    final border = BorderSide(color: colors.outline);
    final softBorder = BorderSide(color: colors.outlineVariant);

    return ThemeData(
      useMaterial3: true,
      brightness: colors.brightness,
      colorScheme: colors,
      textTheme: resolvedTextTheme,
      scaffoldBackgroundColor: colors.surface,
      canvasColor: colors.surface,
      dividerColor: colors.outlineVariant,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: 20,
        toolbarHeight: 64,
        titleTextStyle: resolvedTextTheme.titleLarge?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: softBorder,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titleTextStyle: resolvedTextTheme.titleLarge?.copyWith(
          color: colors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainerLowest,
        hintStyle: resolvedTextTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
        prefixIconColor: colors.onSurfaceVariant,
        suffixIconColor: colors.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: border,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: border,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: resolvedTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48),
          elevation: 0,
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          side: border,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: resolvedTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(44, 44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: resolvedTextTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(44),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceContainerLowest,
        selectedColor: colors.primaryContainer,
        side: border,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: resolvedTextTheme.labelMedium,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: colors.surfaceContainerLowest,
        indicatorColor: colors.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? colors.primary
                : colors.onSurfaceVariant,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return resolvedTextTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? colors.primary
                : colors.onSurfaceVariant,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          );
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearTrackColor: colors.surfaceContainerHighest,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.inverseSurface,
        contentTextStyle: resolvedTextTheme.bodyMedium?.copyWith(
          color: colors.onInverseSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minTileHeight: 56,
        iconColor: colors.onSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colors.inverseSurface,
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: resolvedTextTheme.bodySmall?.copyWith(
          color: colors.onInverseSurface,
        ),
      ),
    );
  }
}
