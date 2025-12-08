import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tinycolor2/tinycolor2.dart';

final infinity = String.fromCharCode(0x221E);
const endash = '–';
const emdash = '——';

extension NumberX on num {
  T bounded<T extends num>({T? min, T? max}) {
    assert(min != null || max != null);

    if (min != null) {
      if (max != null) {
        return math.min<T>(math.max<T>(this as T, min), max);
      } else {
        return math.max<T>(this as T, min);
      }
    } else if (max != null) {
      return math.min<T>(this as T, max);
    }

    return this as T;
  }

  /// These reverse the meaning of min/max. [minOf] means "restrict to minimum value", and vice versa.
  T minOf<T extends num>(T minimum) => math.max(this as T, minimum);
  T maxOf<T extends num>(T maximum) => math.min(this as T, maximum);
}

extension DoubleX on double {
  double roundToNearestFraction(int denominator) => (this * denominator).round() / denominator;
}

extension StringX on String {
  bool toBool() => this == "true" ? true : false;
  T toEnum<T extends Enum>(List<T> values) => values.firstWhere((value) => value.name == this);

  String toFormattedUSPhone() {
    final cleaned = replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length != 10) {
      return this;
    }
    final areaCode = cleaned.substring(0, 3);
    final prefix = cleaned.substring(3, 6);
    final suffix = cleaned.substring(6);
    return '($areaCode) $prefix-$suffix';
  }

  String toDigitsOnly() => replaceAll(RegExp(r'\D'), '');
}

extension IterableIntX on Iterable<int> {
  int sum() => fold(0, (total, current) => total + current);
}

extension IterableDoubleX on Iterable<double> {
  double sum() => fold(0, (total, current) => total + current);
}

extension IterableBoolX on Iterable<bool> {
  bool get anyTrue => any((value) => value);

  bool get allTrue => !any((value) => !value);
}

extension IterableWidgetX on Iterable<Widget> {
  Iterable<Widget> joinWidgetList(Widget separator) {
    final Iterator<Widget> iterator = this.iterator;

    final List<Widget> result = [];

    if (!iterator.moveNext()) {
      return result;
    }

    result.add(iterator.current);

    while (iterator.moveNext()) {
      result.add(separator);
      result.add(iterator.current);
    }

    return result;
  }

  Iterable<Widget> padAll(EdgeInsets padding) {
    return map((widget) {
      return Padding(
        padding: padding,
        child: widget,
      );
    });
  }
}

extension ListX<T> on List<T> {
  void replaceAt(int index, T replacement) {
    this[index] = replacement;
  }

  void replaceWith(T original, T replacement) {
    if (contains(original)) {
      replaceAt(indexOf(original), replacement);
    }
  }

  void replaceWithOrAdd(T original, T replacement) {
    if (contains(original)) {
      replaceWith(original, replacement);
    } else {
      add(replacement);
    }
  }

  void removeAll(Iterable<T> values) {
    for (final value in values) {
      remove(value);
    }
  }

  T randomElement() {
    if (isEmpty) throw StateError('Cannot get a random element from an empty list.');
    return this[math.Random().nextInt(length)];
  }
}

extension SetX<T> on Set<T> {
  /// Adds the [value] if it's not in the set, or removes it if it is.
  void toggleValue(T value) {
    // `Set.add` returns `false` if the item was already in the set.
    if (!add(value)) {
      remove(value);
    }
  }
}

Color dimColor(Color value, {int amount = 30}) => value.isLight ? value.darken(amount) : value.lighten(amount);

Color foregroundColorForBackground(Color bgColor, {Color light = Colors.white, Color dark = Colors.black}) {
  return bgColor.computeLuminance() > 0.5 ? dark : light;
}

T strToEnum<T extends Enum>(List<T> values, String str) => values.firstWhere((value) => value.name == str);

T fullStrToEnum<T extends Enum>(List<T> values, String str) => values.firstWhere((value) => value.toString() == str);

extension TextEditingControllerExt on TextEditingController {
  void selectAll() {
    if (text.isEmpty) return;
    selection = TextSelection(baseOffset: 0, extentOffset: text.length);
  }
}

extension BuildContextX on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
}