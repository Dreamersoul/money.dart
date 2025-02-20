/* Copyright (C) S. Brett Sutton - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:money2/money2.dart';
import 'package:test/test.dart';

void main() {
  group('Currencies Register', () {
    final usd = Currency.create('USD', 2);
    final eur = Currency.create('EUR', 2);

    setUp(() {
      Currencies().registerList([usd, eur]);
    });

    test('returns a currency identified by code', () {
      expect(Currencies().find('USD'), equals(usd));
      expect(Currencies().find('EUR'), equals(eur));
    });

    test('returns null if a currency cannot be found', () {
      expect(Currencies().find('DDD'), isNull);
    });

    test('returns all currencies correctly', () {
      expect(Currencies().getRegistered(), [...CommonCurrencies().asList()]);
      expect(Currencies().getRegistered().map((c) => c.code),
          [...CommonCurrencies().asList().map((currency) => currency.code)]);
    });

    test('operators', () {
      expect(Currencies()['USD'], equals(Currencies().find('USD')));
      Currencies()['TEST'] = Currency.create('TEST', 2);
      expect(Currencies().find('TEST'), isNotNull);
    });
  });
}
