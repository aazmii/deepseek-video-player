part of '../extensions.dart';

extension ContextExt on BuildContext {
  MediaQueryData get mq => MediaQuery.of(this);
  double get width => mq.size.width;
  bool get isPotrait => mq.orientation == Orientation.portrait;
  double get screenWidth => mq.size.width;
  double get screenHeight => mq.size.height;
  double get acpectRatio => screenWidth / screenHeight;
}
