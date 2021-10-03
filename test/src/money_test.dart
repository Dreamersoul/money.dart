/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2016 - 2019 LitGroup LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the 'Software'), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import 'package:money2/money2.dart';
import 'package:test/test.dart';

void main() {
  final usd = Currency.create('USD', 2);
  final eur = Currency.create('EUR', 2);

  group('Money', () {
    group('instantiation', () {
      test('fromInt', () {
        var _ = Money.fromInt(0, usd);
        _ = Money.fromInt(1, usd);
        _ = Money.fromInt(-1, usd);
      });

      test('from', () {
        expect(Money.from(0, usd), equals(Money.fromInt(0, usd)));
        expect(Money.from(1, usd), equals(Money.fromInt(100, usd)));
        expect(Money.from(-1, usd), equals(Money.fromInt(-100, usd)));
        expect(Money.from(1.99, usd), equals(Money.fromInt(199, usd)));
        expect(Money.from(-1.99, usd), equals(Money.fromInt(-199, usd)));
      });
    });

    test('High Precision', () {
      final currency = Currency.create('BIG', 63);
      Currencies.register(currency);

      expect(Money.from(10.0, currency).minorUnits / currency.precisionFactor,
          equals(10.0));
      expect(Money.from(-10.0, currency).minorUnits / currency.precisionFactor,
          equals(-10.0));
    });

    test('bigint hash value', () {
      final fiveDollars = Money.fromInt(500, usd);

      expect(fiveDollars.hashCode, equals(Money.fromInt(500, usd).hashCode));
    });

    test('int hash value', () {
      final fiveDollars = Money.fromInt(500, usd);

      expect(fiveDollars.hashCode, equals(Money.fromInt(500, usd).hashCode));
    });

    test('predicate of currency', () {
      final oneDollars = Money.fromInt(100, usd);

      expect(oneDollars.isInCurrency(usd), isTrue);
      expect(oneDollars.isInCurrency(eur), isFalse);
    });

    test('predicate of currency match', () {
      final oneDollar = Money.fromInt(100, usd);
      final twoDollars = Money.fromInt(200, usd);
      final oneEuro = Money.fromInt(100, eur);

      expect(oneDollar.isInSameCurrencyAs(twoDollars), isTrue);
      expect(oneDollar.isInSameCurrencyAs(oneEuro), isFalse);
    });

    group('big int amount predicates:', () {
      final zeroCents = Money.fromInt(0, usd);
      final oneCent = Money.fromInt(1, usd);
      final minusOneCent = Money.fromInt(-1, usd);

      moneyAmountPredicates(zeroCents, oneCent, minusOneCent);
    }); // big int amount predicates

    group('int amount predicates:', () {
      final zeroCents = Money.fromInt(0, usd);
      final oneCent = Money.fromInt(1, usd);
      final minusOneCent = Money.fromInt(-1, usd);

      moneyAmountPredicates(zeroCents, oneCent, minusOneCent);
    }); //
    group('comparison', () {
      final fourDollars = Money.fromInt(400, usd);
      final fiveDollars = Money.fromInt(500, usd);
      final sixDollars = Money.fromInt(600, usd);

      final fiveEuros = Money.fromInt(500, eur);

      test('==()', () {
        expect(fiveDollars, equals(Money.fromInt(500, usd)));
        expect(fiveDollars, isNot(equals(fourDollars)));
        expect(fiveDollars, isNot(equals(sixDollars)));
        expect(fiveDollars, isNot(equals(fiveEuros)));
      });

      test('<()', () {
        expect(fiveDollars < sixDollars, isTrue);
        expect(fiveDollars < fiveDollars, isFalse);
        expect(fiveDollars < fourDollars, isFalse);

        // Cannot compare money in different currencies:
        expect(() => fiveDollars < fiveEuros, throwsArgumentError);
      });

      test('<=()', () {
        expect(fiveDollars <= sixDollars, isTrue);
        expect(fiveDollars <= fiveDollars, isTrue);
        expect(fiveDollars <= fourDollars, isFalse);

        // Cannot compare money in different currencies:
        expect(() => fiveDollars <= fiveEuros, throwsArgumentError);
      });

      test('>()', () {
        expect(fiveDollars > fourDollars, isTrue);
        expect(fiveDollars > fiveDollars, isFalse);
        expect(fiveDollars > sixDollars, isFalse);

        // Cannot compare money in different currencies:
        expect(() => fiveDollars > fiveEuros, throwsArgumentError);
      });

      test('>=()', () {
        expect(fiveDollars >= fourDollars, isTrue);
        expect(fiveDollars >= fiveDollars, isTrue);
        expect(fiveDollars >= sixDollars, isFalse);

        // Cannot compare money in different currencies:
        expect(() => fiveDollars >= fiveEuros, throwsArgumentError);
      });

      test('conformance to Comparable', () {
        expect(fiveDollars, isA<Comparable<Money>>());

        expect(fiveDollars.compareTo(fiveDollars), isZero);
        expect(fiveDollars.compareTo(fourDollars), isPositive);
        expect(fiveDollars.compareTo(sixDollars), isNegative);
        expect(() => fiveDollars.compareTo(fiveEuros), throwsArgumentError);
      });
    }); // comparison

    group('arithmetic:', () {
      test('addition', () {
        final oneDollar = Money.fromInt(100, usd);
        final twoDollars = Money.fromInt(200, usd);
        final threeDollars = Money.fromInt(300, usd);

        expect(oneDollar + twoDollars, equals(threeDollars));
      });

      test('addition error for summands in different currencies', () {
        final oneDollar = Money.fromInt(100, usd);
        final oneEuro = Money.fromInt(100, eur);

        expect(() => oneDollar + oneEuro, throwsArgumentError);
      });

      test('unary minus', () {
        final oneDollar = Money.fromInt(100, usd);
        final minusOneDollar = Money.fromInt(-100, usd);

        expect(-oneDollar, equals(minusOneDollar));
        expect(-minusOneDollar, equals(oneDollar));
      });

      test('subtraction', () {
        final oneDollar = Money.fromInt(100, usd);
        final twoDollars = Money.fromInt(200, usd);
        final threeDollars = Money.fromInt(300, usd);

        expect(threeDollars - oneDollar, equals(twoDollars));
      });

      test('subtraction error for operands in different currencies', () {
        final oneDollar = Money.fromInt(100, usd);
        final oneEuro = Money.fromInt(100, eur);

        expect(() => oneDollar - oneEuro, throwsArgumentError);
      });

      test('multiplication', () {
        final zeroDollars = Money.fromInt(0, usd);
        final oneDollar = Money.fromInt(100, usd);
        final twoDollars = Money.fromInt(200, usd);

        // Test integral multiplication:
        expect(oneDollar * 0, equals(zeroDollars));
        expect(oneDollar * 2, equals(twoDollars));
        expect(oneDollar * -2, equals(-twoDollars));

        // Test floating-point multiplication:
        expect(oneDollar * 0.0, equals(zeroDollars));
        expect(oneDollar * -0.0, equals(zeroDollars));
        expect(oneDollar * 1.0, equals(oneDollar));
        expect(oneDollar * -1.0, equals(-oneDollar));

        expect(oneDollar * 0.5, equals(Money.fromInt(50, usd)));
        expect(oneDollar * 2.01, equals(Money.fromInt(201, usd)));
        expect(oneDollar * 0.99, equals(Money.fromInt(99, usd)));

        // Test schoolbook rounding:
        expect(oneDollar * 0.094, equals(Money.fromInt(9, usd)));
        expect(oneDollar * -0.094, equals(Money.fromInt(-9, usd)));

        expect(oneDollar * 0.095, equals(Money.fromInt(10, usd)));
        expect(oneDollar * -0.095, equals(Money.fromInt(-10, usd)));
      });

      test('division', () {
        final zeroDollars = Money.fromInt(0, usd);
        final fiftyCents = Money.fromInt(50, usd);
        final oneDollar = Money.fromInt(100, usd);
        final twoDollars = Money.fromInt(200, usd);

        // Test with integral divisor:
        expect(zeroDollars / 2, equals(zeroDollars));
        expect(twoDollars / 1, equals(twoDollars));

        expect(twoDollars / 2, equals(oneDollar));
        expect(twoDollars / -2, equals(-oneDollar));

        expect(oneDollar / 2, equals(fiftyCents));
        expect(oneDollar / 3, equals(Money.fromInt(33, usd)));

        // Test with floating-point divisor:
        expect(oneDollar / 0.5, equals(twoDollars));
        expect(oneDollar / 0.5, equals(twoDollars));

        expect(oneDollar / 1.094, equals(Money.fromInt(91, usd)));
        expect(oneDollar / -1.094, equals(Money.fromInt(-91, usd)));

        expect(oneDollar / 1.092, equals(Money.fromInt(92, usd)));
        expect(oneDollar / -1.092, equals(Money.fromInt(-92, usd)));
      });
    }); // arithmetic

    group('allocation according to ratios', () {
      test('throws an error when list of ratios is empty', () {
        final money = Money.fromInt(1, usd);

        expect(() => money.allocationAccordingTo([]), throwsArgumentError);
      });

      test('throws an error if any of ratios is negative', () {
        final money = Money.fromInt(1, usd);

        expect(() => money.allocationAccordingTo([-1]), throwsArgumentError);
        expect(() => money.allocationAccordingTo([4, -1]), throwsArgumentError);
      });

      test('throws an error if sum of ratios euals zero', () {
        final money = Money.fromInt(1, usd);

        expect(() => money.allocationAccordingTo([0]), throwsArgumentError);
        expect(() => money.allocationAccordingTo([0, 0]), throwsArgumentError);
      });

      test('provides list with allocated money values', () {
        void testAllocation(
            int minorUnits, List<int> ratios, List<int> result) {
          final money = Money.fromInt(minorUnits, usd);

          expect(
              money.allocationAccordingTo(ratios),
              equals(
                  result.map((minorUnits) => Money.fromInt(minorUnits, usd))));
        }

        // Allocation of zero amount:
        testAllocation(0, [1], [0]);
        testAllocation(0, [1, 1], [0, 0]);
        testAllocation(0, [1, 0], [0, 0]);

        // Allocation of positive amount:
        testAllocation(100, [50], [100]);
        testAllocation(100, [1, 1], [50, 50]);
        testAllocation(100, [1, 1, 1], [34, 33, 33]);
        testAllocation(101, [1, 1, 1], [34, 34, 33]);
        testAllocation(2, [1, 1, 1], [1, 1, 0]);
        testAllocation(5, [3, 7], [2, 3]);
        testAllocation(5, [7, 3], [4, 1]);
        testAllocation(5, [0, 7, 3], [0, 4, 1]);
        testAllocation(5, [7, 0, 3], [4, 0, 1]);
        testAllocation(5, [7, 3, 0], [4, 1, 0]);
        testAllocation(5, [0, 0, 1], [0, 0, 5]);

        // Allocation of negative amount:
        testAllocation(-100, [50], [-100]);
        testAllocation(-100, [1, 1], [-50, -50]);
        testAllocation(-100, [1, 1, 1], [-34, -33, -33]);
        testAllocation(-101, [1, 1, 1], [-34, -34, -33]);
        testAllocation(-2, [1, 1, 1], [-1, -1, 0]);
        testAllocation(-5, [3, 7], [-2, -3]);
        testAllocation(-5, [7, 3], [-4, -1]);
        testAllocation(-5, [0, 7, 3], [0, -4, -1]);
        testAllocation(-5, [7, 0, 3], [-4, 0, -1]);
        testAllocation(-5, [7, 3, 0], [-4, -1, 0]);
        testAllocation(-5, [0, 0, 1], [0, 0, -5]);
      });
    });

    group('allocation to targets', () {
      test('throws an error if number of targets less than one', () {
        final money = Money.fromInt(100, usd);

        expect(() => money.allocationTo(0), throwsArgumentError);
        expect(() => money.allocationTo(-1), throwsArgumentError);
      });

      test('returns a list with values allocated among N targets', () {
        void testAllocation(int minorUnits, int targets, List<int> result) {
          final money = Money.fromInt(minorUnits, usd);

          expect(
              money.allocationTo(targets),
              equals(result
                  .map((minorUnits) => Money.fromInt(minorUnits, usd))
                  .toList()));
        }

        // Allocation of zero amount:
        testAllocation(0, 1, [0]);
        testAllocation(0, 2, [0, 0]);

        // Allocation of positive amount:
        testAllocation(100, 1, [100]);
        testAllocation(100, 2, [50, 50]);
        testAllocation(101, 2, [51, 50]);

        // Allocation of negative amount:
        testAllocation(-100, 1, [-100]);
        testAllocation(-100, 2, [-50, -50]);
        testAllocation(-101, 2, [-51, -50]);
      });
    });

    test('currency property', () {
      expect(usd, Money.fromInt(1000, usd).currency);
      expect(eur, Money.fromInt(1000, eur).currency);
    });

    test('minorUnits property', () {
      expect(Money.fromInt(2000, usd).minorUnits, BigInt.from(2000));
      expect(Money.fromInt(1001, eur).minorUnits, BigInt.from(1001));
    });
  });
}

void moneyAmountPredicates(Money zeroCents, Money oneCent, Money minusOneCent) {
  test('isZero', () {
    expect(zeroCents.isZero, isTrue);
    expect(oneCent.isZero, isFalse);
    expect(minusOneCent.isZero, isFalse);
  });

  test('isPositive', () {
    expect(oneCent.isPositive, isTrue);
    expect(zeroCents.isPositive, isFalse);
    expect(minusOneCent.isPositive, isFalse);
  });

  test('isNegative', () {
    expect(minusOneCent.isNegative, isTrue);
    expect(zeroCents.isNegative, isFalse);
    expect(oneCent.isNegative, isFalse);
  });
}
