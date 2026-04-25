import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides a clock stream that emits immediately and then snaps to minute
/// boundaries so time-sensitive UI updates happen exactly when a block rolls
/// over instead of drifting from subscription time.
final clockProvider = StreamProvider.autoDispose<DateTime>((ref) {
  return Stream<DateTime>.multi((controller) {
    controller.add(DateTime.now());

    final now = DateTime.now();
    final nextMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 1,
    );

    Timer? periodicTimer;
    final alignTimer = Timer(nextMinute.difference(now), () {
      controller.add(DateTime.now());
      periodicTimer = Timer.periodic(const Duration(minutes: 1), (_) {
        controller.add(DateTime.now());
      });
    });

    ref.onDispose(() {
      alignTimer.cancel();
      periodicTimer?.cancel();
    });
  });
});
