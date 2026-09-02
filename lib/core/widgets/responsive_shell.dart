import 'package:flutter/material.dart';

class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child);
  }
}
