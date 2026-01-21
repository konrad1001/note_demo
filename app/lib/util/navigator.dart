import 'package:flutter/material.dart';

class DefaultNavigator {
  final BuildContext context;

  DefaultNavigator.of(this.context);

  void push(Widget route) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (context) => route));
  }

  void pop() {
    Navigator.of(context).pop();
  }
}
