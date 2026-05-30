import 'package:flutter/material.dart';

/// Shows [text] in a snack bar at the bottom of the screen.
void showMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}
