import 'package:stoppapp/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Tag', () {
    test('Format und Parse', () {
      expect(const Tag(2026, 3, 5).toString(), '2026-03-05');
      expect(Tag.parse('2026-03-05'), const Tag(2026, 3, 5));
    });
    test('Wochentag und Rechnen', () {
      expect(const Tag(2026, 11, 6).wochentag, 5);
      expect(const Tag(2026, 12, 31).plusTage(1), const Tag(2027, 1, 1));
      expect(const Tag(2027, 1, 1).tageSeit(const Tag(2026, 12, 25)), 7);
    });
  });

  group('Tageswechsel', () {
    test('Zeitpunkt vor dem Tageswechsel gehört zum Vortag', () {
      expect(tagFuer(DateTime(2026, 11, 7, 3, 59), 240), const Tag(2026, 11, 6));
      expect(tagFuer(DateTime(2026, 11, 7, 4, 0), 240), const Tag(2026, 11, 7));
      expect(tagFuer(DateTime(2026, 11, 7, 0, 10), 0), const Tag(2026, 11, 7));
    });
    test('Uhrzeit im Tag: 01:30 bei 04:00 ist der folgende Kalendertag', () {
      expect(uhrzeitImTag(const Tag(2026, 11, 6), 1, 30, 240), DateTime(2026, 11, 7, 1, 30));
      expect(uhrzeitImTag(const Tag(2026, 11, 6), 4, 0, 240), DateTime(2026, 11, 6, 4, 0));
    });
    test('Tagesgrenzen', () {
      expect(tagesBeginn(const Tag(2026, 11, 6), 240), DateTime(2026, 11, 6, 4));
      expect(tagesEnde(const Tag(2026, 11, 6), 240), DateTime(2026, 11, 7, 4));
    });
  });

  group('Dauerformat', () {
    test('unter 10 Min m:ss Min', () {
      expect(formatDauer(const Duration(minutes: 3, seconds: 7)), '3:07 Min');
      expect(formatDauer(const Duration(seconds: 599)), '9:59 Min');
    });
    test('unter 60 Min n Min', () {
      expect(formatDauer(const Duration(minutes: 10)), '10 Min');
      expect(formatDauer(const Duration(minutes: 59, seconds: 59)), '59 Min');
    });
    test('ab 60 Min h h mm', () {
      expect(formatDauer(const Duration(minutes: 60)), '1 h 00');
      expect(formatDauer(const Duration(hours: 2, minutes: 5)), '2 h 05');
    });
    test('Laufzeit', () {
      expect(formatLaufzeit(const Duration(minutes: 12, seconds: 5)), '12:05');
      expect(formatLaufzeit(const Duration(hours: 1, minutes: 2, seconds: 5)), '1:02:05');
    });
  });
}
