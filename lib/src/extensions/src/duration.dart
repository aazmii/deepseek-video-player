part of '../extensions.dart';

extension DurationExt on Duration {
  String get toTwoDigitsString {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(inMinutes.remainder(60));
    String seconds = twoDigits(inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  String get formatInHMS {
    int minutes = inMinutes;
    int seconds = inSeconds.remainder(60);
    int tenths = (inMilliseconds.remainder(1000)) ~/ 100; // Tenths of a second

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}:'
        '$tenths';
  }
}
