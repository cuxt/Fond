import 'package:flutter/material.dart';

class FondToast {
  // Toast显示位置控制
  static const int bottom = 0;
  static const int center = 1;
  static const int top = 2;

  // Toast显示时长控制
  static const int lengthShort = 2;
  static const int lengthLong = 4;

  static final GlobalKey<ScaffoldMessengerState> navigatorKey =
      GlobalKey<ScaffoldMessengerState>();

  // 显示Toast消息
  static void show(
    String msg, {
    int duration = lengthShort,
    int gravity = bottom,
  }) {
    dismissAll(); // 先清除之前的所有SnackBar

    navigatorKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: Duration(seconds: duration),
        behavior: SnackBarBehavior.floating,
        margin: _getMarginByGravity(gravity),
        action: SnackBarAction(
          label: '关闭',
          onPressed: () {
            navigatorKey.currentState?.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // 根据位置获取边距
  static EdgeInsets _getMarginByGravity(int gravity) {
    switch (gravity) {
      case top:
        return const EdgeInsets.only(bottom: 400, left: 20, right: 20);
      case center:
        return const EdgeInsets.only(bottom: 200, left: 20, right: 20);
      case bottom:
      default:
        return const EdgeInsets.only(bottom: 50, left: 20, right: 20);
    }
  }

  // 移除所有Toast
  static void dismissAll() {
    navigatorKey.currentState?.clearSnackBars();
  }
}
