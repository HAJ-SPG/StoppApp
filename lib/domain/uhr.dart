/// Injizierbare Zeitquelle, damit Tests feste Zeiten nutzen können.
abstract class Uhr {
  DateTime jetzt();
}

class SystemUhr implements Uhr {
  const SystemUhr();
  @override
  DateTime jetzt() => DateTime.now();
}

/// Uhr für Tests: steht, bis man sie weiterstellt.
class FesteUhr implements Uhr {
  FesteUhr(this._jetzt);
  DateTime _jetzt;

  @override
  DateTime jetzt() => _jetzt;

  void stellen(DateTime zeit) => _jetzt = zeit;
  void vor(Duration d) => _jetzt = _jetzt.add(d);
}
