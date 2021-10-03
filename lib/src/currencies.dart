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

import 'currency.dart';
import 'money.dart';
import 'pattern_decoder.dart';

// ignore: avoid_classes_with_only_static_members
/// A factory for registering and accessing [Currency] instances.
///
/// The [Currencies] class is a convenience class that you aren't required to
/// use.
///
/// Money2 does not register a default set of currencies instead you need to
/// explicitly create each currency or register one or more of the [Currency]s
/// from the list of [CommonCurrencies]s.
///
/// The [Currencies] class lets you register each [Currency] for easy
/// reuse and access from this singleton.
///
/// You don't need to register [Currency]s, you can just create [Currency]s
/// and use them as needed.
///
/// see:
///   [Currency]
///   [CommonCurrencies]

// ignore: avoid_classes_with_only_static_members
class Currencies {
  // static Currencies _self = Currencies._internal();

  /// Maps a currency 'code' to its associated currency.
  static final Map<String, Currency> _directory = {};

  /// Register a Currency
  /// Once a Currency has been registered the
  /// [Currencies.parse] method will be able to recognize
  /// the currencey code in String and return the correct type.
  /// ```dart
  /// Currency usd = Currency.create('USD', 2);
  /// Currencies.register(usd);
  /// final usdAmount = Currencies.parse(r'$USD1500.0');
  /// ```
  /// See:
  /// [Currencies.parse]
  /// [Currencies.registerAll]
  /// [CommonCurrencies.registeryAll]
  /// [Currencies.find]
  static void register(Currency currency) {
    _directory[currency.code] = currency;
  }

  /// Register a list of currencies.
  /// Once a Currency has been registered the
  /// [Currencies.parse] method will be able to recognize
  /// the currencey code in String and return the correct type.
  ///
  /// See [Currencies.register]
  /// [Currencies.parse]
  ///
  /// ```dart
  /// Currency usd = Currency.create('USD', 2);
  /// Currency aud = Currency.create('AUD', 2);
  /// Currencies.registerAll([usd, aud]);
  /// final usdAmount = Currencies.parse(r'$USD1500.0');
  /// ```
  /// See:
  /// [Currencies.parse]
  /// [Currencies.register]
  /// [CommonCurrencies.registeryAll]
  /// [Currencies.find]
  static void registerList(Iterable<Currency> currencies) {
    for (final currency in currencies) {
      _directory[currency.code] = currency;
    }
  }

  ///
  /// Parses a string containing a money amount including a currency code.
  ///
  /// Provided the passed currency code belongs to a [Currency]
  /// that has been registered via [Currencies.register] or
  /// [Currencies.registerList] then this method will return a
  /// [Money] instance of that [Currency] type.
  ///
  /// [monetaryAmount] is the monetary value that you want parsed.
  ///
  /// The [pattern] is the pattern to use when parsing the [monetaryAmount].
  /// The [pattern] is optional and if not passed then the default pattern
  /// registered with the [Currency] will be used to parse the [monetaryAmount].
  ///
  ///
  /// A [MoneyParseException] is thrown if the [monetaryAmount]
  /// doesn't match the [pattern].
  ///
  /// An [UnknownCurrencyException] is thrown if the [monetaryAmount]
  /// does not contain a known currency.
  /// ```dart
  /// Currency usd = Currency.create('USD', 2);
  /// Currency aud = Currency.create('AUD', 2);
  /// Currencies.registerAll([usd, aud]);
  /// final usdAmount = Currencies.parse(r'$USD1500.0');
  /// ```
  ///
  /// or
  /// ```dart
  /// CommonCurrencies().registerAll();
  /// final usdAmount = Currencies.parse(r'$USD1500.0');
  /// ```dart
  ///
  /// See:
  /// [Currencies.register]
  /// [Currencies.registerAll]
  /// [CommonCurrencies.registeryAll]
  /// [Currencies.find]
  static Money parse(String monetaryAmountWithCode, [String? pattern]) {
    Currency? currency;
    if (pattern == null) {
      /// No pattern? so find the currency based on the currency
      /// code in the [monetaryAmount].
      currency = findByCode(monetaryAmountWithCode);
    } else {
      final codeLength = _getCodeLength(pattern);

      if (codeLength < 2) {
        throw MoneyParseException(
          'The Country Code length (e.g. CC) must be at '
          'least 2 characters long',
        );
      }

      final code = _extractCode(monetaryAmountWithCode, codeLength);

      currency = find(code);
    }

    if (currency == null) {
      throw UnknownCurrencyException(monetaryAmountWithCode);
    }

    pattern ??= currency.pattern;

    var monetaryAmount = monetaryAmountWithCode;

    if (!containsCode(pattern)) {
      /// The default patterns often don't contain a currency
      /// code so as a conveniencce we strip the code out of the
      /// [monetaryAmount]. I hope this is a good idea :)
      monetaryAmount = _stripCode(currency, monetaryAmountWithCode);
    }

    final decoder = PatternDecoder(currency, pattern);
    final moneyData = decoder.decode(monetaryAmount);

    return Money.fromInt(moneyData.minorUnits.toInt(), currency);
  }

  /// Strips the currency code out of a [monetaryAmount]
  /// e.g.
  /// $USD10.00 becomes $10.00
  static String _stripCode(Currency? currency, String monetaryAmountWithCode) {
    String monetaryAmount;
    if (currency != null && !containsCode(currency.pattern)) {
      final code = _extractCode(monetaryAmountWithCode, currency.code.length);

      /// Remove the currency code
      monetaryAmount = monetaryAmountWithCode.replaceFirst(code, '');
    } else {
      monetaryAmount = monetaryAmountWithCode;
    }
    return monetaryAmount;
  }

  ///
  @Deprecated("use [Currencies.parse()")
  static Money fromString(String monetaryAmount, String pattern) {
    return Currencies.parse(monetaryAmount, pattern);
  }

  /* Protocol *****************************************************************/

  /// Searches the list of registered [Currency]s.
  ///
  /// Returns the [Currency] that matches [code] or `null` if
  /// no matching [code] is found.
  /// ```dart
  /// CommonCurrencies().registerAll();
  /// final usdAmount = Currencies.parse(r'$USD1500.0');
  /// ```dart
  ///
  /// See:
  /// [Currencies.register]
  /// [Currencies.registerAll]
  /// [CommonCurrencies.registeryAll]
  static Currency? find(String code) {
    return _directory[code];
  }

  /// Returns all currently registered [Currency]s
  ///
  /// ```dart
  /// final usd = Currency.create('USD', 2);
  /// final eur = Currency.create('EUR', 2);
  /// Currencies.registerList([usd, eur]);
  /// expect(Currencies.getRegistered(), [usd, eur]);
  /// expect(Currencies.getRegistered().map((c) => c.code), ['USD', 'EUR']);
  /// ```
  ///
  /// see:
  /// [Currency.register]
  /// [Currency.registerList]
  /// [CommonCurrencies.registeryAll]
  static Iterable<Currency> getRegistered() {
    return _directory.values;
  }

  /// Counts the number of 'C' in a pattern
  static int _getCodeLength(String pattern) {
    var count = 0;
    for (var i = 0; i < pattern.length; i++) {
      if (pattern[i] == 'C') count++;
    }
    return count;
  }

  /// Extracts the currency code from a [monetaryValue] on that
  /// assumption that it is [codeLength] long.
  static String _extractCode(String monetaryValue, int codeLength) {
    final regEx = RegExp('[A-Za-z]' * codeLength);

    final matches = regEx.allMatches(monetaryValue);
    if (matches.isEmpty) {
      throw MoneyParseException(
        'No currency code found in the pattern: $monetaryValue',
      );
    }

    if (matches.length > 1) {
      throw MoneyParseException(
        'More than one currency code found in the pattern: $monetaryValue',
      );
    }

    return monetaryValue.substring(matches.first.start, matches.first.end);
  }

  /// Searches for the matching registered Currency by comparing
  /// the currency codes in a monetaryAmount.
  static Currency? findByCode(String monetaryAmount) {
    Currency? match;
    var longToShort = <Currency>[];

    longToShort = _directory.values.toList();
    longToShort.sort((lhs, rhs) => lhs.code.length - rhs.code.length);

    for (final currency in longToShort) {
      if (monetaryAmount.contains(currency.code)) {
        match = currency;
        break;
      }
    }
    return match;
  }

  /// tests a pattern to see if it contains a currency code.
  static bool containsCode(String pattern) {
    return pattern.contains('C');
  }
}

/// Throw if the currency is not registered.
class UnknownCurrencyException implements Exception {
  /// The code or monetary amount that contained the unknow currency
  String code;

  ///
  UnknownCurrencyException(this.code);

  @override
  String toString() {
    return "An unknown currency '$code' was passed. Register the currency"
        ' via [Currencies.register()] and try again.';
  }
}
