import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tick.dart';
import '../services/tick_feed.dart';

/// Overridable in tests and in the error demo.
final tickFeedProvider = Provider<TickFeed>((ref) => TickFeed());

final tickerProvider = StreamProvider.autoDispose<List<Tick>>(
  (ref) {
    return ref.watch(tickFeedProvider).watch();
  },
  // Riverpod 3 retries failed providers automatically, which turns a feed
  // error into AsyncLoading(retrying: true) instead of AsyncError.
  // Disable it so errors surface and the user retries manually.
  retry: (_, _) => null,
);
