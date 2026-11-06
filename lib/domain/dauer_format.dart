/// Dauerformat der ganzen App: unter 10 Min `m:ss Min`, unter 60 Min
/// `n Min`, ab 60 Min `h h mm`.
String formatDauer(Duration d) {
  if (d.isNegative) d = Duration.zero;
  final sekunden = d.inSeconds;
  if (sekunden < 600) {
    final m = sekunden ~/ 60;
    final s = sekunden % 60;
    return '$m:${s.toString().padLeft(2, '0')} Min';
  }
  final minuten = d.inMinutes;
  if (minuten < 60) return '$minuten Min';
  final h = minuten ~/ 60;
  final m = minuten % 60;
  return '$h h ${m.toString().padLeft(2, '0')}';
}

/// Live-Zeit einer laufenden Messung, z. B. `12:05` oder `1:02:05`.
String formatLaufzeit(Duration d) {
  if (d.isNegative) d = Duration.zero;
  final h = d.inHours;
  final m = d.inMinutes % 60;
  final s = d.inSeconds % 60;
  String zwei(int x) => x.toString().padLeft(2, '0');
  return h > 0 ? '$h:${zwei(m)}:${zwei(s)}' : '${zwei(m)}:${zwei(s)}';
}

/// Uhrzeit `HH:MM` in Ortszeit.
String formatUhrzeit(DateTime t) {
  final l = t.toLocal();
  return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
}
