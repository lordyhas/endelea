import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/format.dart';

/// Text showing the time elapsed since [since], refreshed every second.
class ElapsedTime extends StatefulWidget {
  const ElapsedTime({super.key, required this.since, this.style});

  final DateTime since;
  final TextStyle? style;

  @override
  State<ElapsedTime> createState() => _ElapsedTimeState();
}

class _ElapsedTimeState extends State<ElapsedTime> {
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formatDuration(DateTime.now().difference(widget.since), clock: true),
      style: widget.style,
    );
  }
}
