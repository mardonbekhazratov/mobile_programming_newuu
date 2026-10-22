import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/tick.dart';
import 'providers/ticker_providers.dart';
import 'widgets/tick_row.dart';

class TickerPage extends ConsumerWidget {
  const TickerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticks = ref.watch(tickerProvider);

    Widget list(List<Tick> value) =>
        ListView(children: [for (final t in value) TickRow(t, key: ValueKey(t.symbol))]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live ticker'),
        actions: [
          IconButton(
            tooltip: 'Fail after 5 ticks',
            icon: const Icon(Icons.wifi_off),
            onPressed: () => ref.read(failAfterProvider.notifier).state = 5,
          ),
          IconButton(
            tooltip: 'Stable feed',
            icon: const Icon(Icons.wifi),
            onPressed: () => ref.read(failAfterProvider.notifier).state = null,
          ),
        ],
      ),
      // Wraps the whole switch so the indicator survives the switch from the
      // data arm to the refresh arm while the reload is in flight.
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(tickerProvider.future),
        child: switch (ticks) {
          // Refresh / retry in progress, keep rows, show thin progress bar.
          // Sits first: a retry from an error is AsyncError(isLoading: true),
          // and should show progress rather than the stale banner.
          AsyncValue(:final value?, isLoading: true) => Column(children: [
              const LinearProgressIndicator(),
              Expanded(child: list(value)),
            ]),

          // Error with stale data: show rows dimmed, banner on top
          AsyncError(:final error, :final value?) => Column(children: [
              MaterialBanner(
                content: Text('Feed error: $error — showing last prices'),
                actions: [
                  TextButton(
                    onPressed: () => ref.invalidate(tickerProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
              Expanded(child: Opacity(opacity: 0.5, child: list(value))),
            ]),

          // Error with nothing to show
          AsyncError(:final error) => Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('Could not load ticker\n$error', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(tickerProvider),
                  child: const Text('Retry'),
                ),
              ]),
            ),

          AsyncData(:final value) => list(value),
          AsyncLoading() => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}
