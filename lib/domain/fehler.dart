import 'modelle.dart';

/// Ein fachlicher Fehler mit deutscher Meldung für die Oberfläche.
class FachFehler implements Exception {
  const FachFehler(this.meldung);
  final String meldung;
  @override
  String toString() => meldung;
}

/// Eine Messung würde sich mit einer anderen überschneiden.
class UeberschneidungFehler extends FachFehler {
  const UeberschneidungFehler(this.andere, String meldung) : super(meldung);
  final Messung andere;
}
