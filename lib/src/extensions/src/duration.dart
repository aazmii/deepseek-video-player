part of '../extensions.dart';
extension DurationExt on Duration {
  
  String get toTwoDigitsString {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(inMinutes.remainder(60));
    String seconds = twoDigits(inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

}