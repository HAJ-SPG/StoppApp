import 'package:stoppapp/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

import 'hilfen.dart';

void main() {
  test('Wochenregel ergibt die Tageskette', () {
    final i = tageskette(beispielDaten(), freitag);
    expect(i.kette?.name, 'Arbeitstag');
    expect(i.quelle, KettenQuelle.wochenregel);
    expect(tageskette(beispielDaten(), freitag.plusTage(1)).kette?.name, 'Wochenende');
  });

  test('Tagesausnahme überschreibt die Wochenregel', () {
    final d = beispielDaten().kopie(tagesausnahmen: {freitag: 2});
    final i = tageskette(d, freitag);
    expect(i.kette?.name, 'Wochenende');
    expect(i.quelle, KettenQuelle.ausnahme);
  });

  test('Ausnahme „Keine Kette“', () {
    final d = beispielDaten().kopie(tagesausnahmen: {freitag: null});
    final i = tageskette(d, freitag);
    expect(i.kette, isNull);
    expect(i.quelle, KettenQuelle.ausnahme);
  });

  test('ohne Regel und Ausnahme keine Kette', () {
    final d = beispielDaten().kopie(wochenregel: {});
    expect(tageskette(d, freitag).quelle, KettenQuelle.keine);
  });
}
