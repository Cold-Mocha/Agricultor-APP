import 'dart:math' as math;

enum MoonPhaseName {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  fullMoon,
  waningGibbous,
  lastQuarter,
  waningCrescent,
}

/// Moon phase computed on the device from the mean synodic month. Accurate to
/// about a day, which is enough for a field notebook and works offline.
final class MoonPhase {
  const MoonPhase({
    required this.name,
    required this.illumination,
    required this.ageDays,
    required this.nextFullMoon,
    required this.nextNewMoon,
  });

  factory MoonPhase.at(DateTime instant) {
    final elapsedDays =
        instant.toUtc().difference(_referenceNewMoon).inSeconds /
        Duration.secondsPerDay;
    final age = elapsedDays % synodicMonthDays;
    final halfCycle = synodicMonthDays / 2;
    final untilFull = age < halfCycle
        ? halfCycle - age
        : synodicMonthDays + halfCycle - age;
    return MoonPhase(
      name: _nameForAge(age),
      illumination: (1 - math.cos(2 * math.pi * age / synodicMonthDays)) / 2,
      ageDays: age,
      nextFullMoon: instant.add(_days(untilFull)),
      nextNewMoon: instant.add(_days(synodicMonthDays - age)),
    );
  }

  static const synodicMonthDays = 29.530588853;

  /// New moon of 2000-01-06 18:14 UTC, the usual astronomical reference.
  static final _referenceNewMoon = DateTime.utc(2000, 1, 6, 18, 14);

  final MoonPhaseName name;

  /// Lit fraction of the disc, from 0 (new) to 1 (full).
  final double illumination;
  final double ageDays;
  final DateTime nextFullMoon;
  final DateTime nextNewMoon;

  /// The next full or new moon, whichever comes first.
  ({bool full, DateTime at}) get nextMilestone =>
      nextFullMoon.isBefore(nextNewMoon)
      ? (full: true, at: nextFullMoon)
      : (full: false, at: nextNewMoon);

  static MoonPhaseName _nameForAge(double age) {
    final eighth = synodicMonthDays / 8;
    final index = ((age + eighth / 2) / eighth).floor() % 8;
    return MoonPhaseName.values[index];
  }

  static Duration _days(double days) =>
      Duration(seconds: (days * Duration.secondsPerDay).round());
}
