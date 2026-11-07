import 'package:flutter/material.dart';

const schriftUeberschrift = 'Bricolage Grotesque';
const schriftText = 'Atkinson Hyperlegible';
const schriftZahl = 'IBM Plex Mono';

/// Farb-Tokens aus den Prototypen (`--paper`, `--go`, `--k1` …).
@immutable
class StoppFarben extends ThemeExtension<StoppFarben> {
  const StoppFarben({
    required this.paper,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.line,
    required this.go,
    required this.goSoft,
    required this.stop,
    required this.stopSoft,
    required this.warn,
    required this.warnSoft,
    required this.skip,
    required this.onSolid,
    required this.ketten,
    required this.kettenHell,
  });

  final Color paper, surface, ink, muted, line, go, goSoft, stop, stopSoft, warn, warnSoft, skip, onSolid;

  /// Kettenfarben Blau, Ocker, Violett, Grün, Beere, Schiefer (`--k1`…`--k6`).
  final List<Color> ketten;

  /// Helle Varianten für „aus der Wochenregel“ (`--k1s`…`--k6s`).
  final List<Color> kettenHell;

  Color kette(int farbe) => ketten[farbe.clamp(0, 5)];
  Color ketteHell(int farbe) => kettenHell[farbe.clamp(0, 5)];

  static const hell = StoppFarben(
    paper: Color(0xFFEEF2EF),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF14201B),
    muted: Color(0xFF5E6D66),
    line: Color(0xFFCED8D3),
    go: Color(0xFF1E7A57),
    goSoft: Color(0xFFD3EADF),
    stop: Color(0xFFC8442C),
    stopSoft: Color(0xFFF6DDD6),
    warn: Color(0xFF8A5A00),
    warnSoft: Color(0xFFF6ECD3),
    skip: Color(0xFF9AA6A0),
    onSolid: Color(0xFFFFFFFF),
    ketten: [
      Color(0xFF2F64A8),
      Color(0xFFA86A12),
      Color(0xFF7E4A9E),
      Color(0xFF1E7A57),
      Color(0xFFB23A5B),
      Color(0xFF4F6B73),
    ],
    kettenHell: [
      Color(0xFFDCE6F4),
      Color(0xFFF4E6CF),
      Color(0xFFEBDDF2),
      Color(0xFFD3EADF),
      Color(0xFFF4DAE1),
      Color(0xFFDDE6E8),
    ],
  );

  static const dunkel = StoppFarben(
    paper: Color(0xFF0F1714),
    surface: Color(0xFF18221E),
    ink: Color(0xFFE6EEEA),
    muted: Color(0xFF93A39B),
    line: Color(0xFF2C3A34),
    go: Color(0xFF3FBF8A),
    goSoft: Color(0xFF173A2C),
    stop: Color(0xFFF06A50),
    stopSoft: Color(0xFF43211A),
    warn: Color(0xFFE6B85C),
    warnSoft: Color(0xFF3A2E14),
    skip: Color(0xFF5D6B65),
    onSolid: Color(0xFF0F1714),
    ketten: [
      Color(0xFF6FA2E8),
      Color(0xFFE0A54A),
      Color(0xFFBE8DDC),
      Color(0xFF3FBF8A),
      Color(0xFFEC7C9A),
      Color(0xFF93B3BC),
    ],
    kettenHell: [
      Color(0xFF1C2B40),
      Color(0xFF3A2C14),
      Color(0xFF312238),
      Color(0xFF173A2C),
      Color(0xFF3D1C26),
      Color(0xFF222E31),
    ],
  );

  @override
  StoppFarben copyWith() => this;

  @override
  StoppFarben lerp(ThemeExtension<StoppFarben>? other, double t) =>
      other is StoppFarben && t >= 0.5 ? other : this;
}

const kettenFarbNamen = ['Blau', 'Ocker', 'Violett', 'Grün', 'Beere', 'Schiefer'];

extension StoppKontext on BuildContext {
  StoppFarben get farben => Theme.of(this).extension<StoppFarben>()!;
}

TextStyle ueberschrift(double groesse, {FontWeight gewicht = FontWeight.w700, Color? farbe}) => TextStyle(
      fontFamily: schriftUeberschrift,
      fontSize: groesse,
      fontWeight: gewicht,
      fontVariations: [FontVariation('wght', gewicht.value.toDouble())],
      height: 1.1,
      color: farbe,
    );

TextStyle zahl(double groesse, {FontWeight gewicht = FontWeight.w500, Color? farbe}) => TextStyle(
      fontFamily: schriftZahl,
      fontSize: groesse,
      fontWeight: gewicht,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: farbe,
    );

ThemeData stoppTheme(Brightness helligkeit) {
  final f = helligkeit == Brightness.dark ? StoppFarben.dunkel : StoppFarben.hell;
  final schema = ColorScheme.fromSeed(
    seedColor: f.go,
    brightness: helligkeit,
  ).copyWith(
    primary: f.go,
    onPrimary: f.onSolid,
    secondary: f.go,
    error: f.stop,
    surface: f.paper,
    onSurface: f.ink,
    surfaceContainerLowest: f.surface,
    surfaceContainerLow: f.surface,
    surfaceContainer: f.surface,
    surfaceContainerHigh: f.surface,
    surfaceContainerHighest: f.surface,
    outline: f.line,
    outlineVariant: f.line,
    onSurfaceVariant: f.muted,
  );
  final basis = ThemeData(
    colorScheme: schema,
    brightness: helligkeit,
    fontFamily: schriftText,
    scaffoldBackgroundColor: f.paper,
    useMaterial3: true,
    extensions: [f],
  );
  return basis.copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: f.paper,
      foregroundColor: f.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: ueberschrift(20, farbe: f.ink),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: f.surface,
      indicatorColor: f.goSoft,
      labelTextStyle: WidgetStatePropertyAll(TextStyle(fontFamily: schriftText, fontSize: 12, color: f.ink)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: f.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    ),
    dividerTheme: DividerThemeData(color: f.line, space: 1),
    snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, actionTextColor: f.goSoft),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: f.muted,
        textStyle: const TextStyle(fontFamily: schriftText, fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    cardTheme: CardThemeData(
      color: f.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: f.line)),
    ),
    listTileTheme: ListTileThemeData(iconColor: f.muted),
  );
}
