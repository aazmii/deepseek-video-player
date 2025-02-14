part of '../extensions.dart';

extension ContextExt on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  bool get isPotrait => mediaQuery.orientation == Orientation.portrait;
  double get screenWidth => mediaQuery.size.width;
  double get screenHeight => mediaQuery.size.height;
  double get acpectRatio => screenWidth / screenHeight;
}
