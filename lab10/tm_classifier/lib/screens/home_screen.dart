import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models.dart';
import '../services/classifier.dart';
import '../services/image_sources.dart';
import '../services/smoke_test.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'history_screen.dart';
import 'model_screen.dart';
import 'result_screen.dart';

/// Bottom navigation for Home, History and Model. Owns the single
/// classification path: bytes -> classify -> history -> Result screen.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.classifier, required this.history, required this.sources});
  final ImageClassifier classifier;
  final History history;
  final ImageSources sources;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;
  bool _busy = false;

  /// The one path every source goes through.
  Future<void> _run(ImageOrigin origin, Future<Uint8List?> Function() acquire) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = await acquire();
      if (bytes == null || !mounted) return; // cancelled: stay where we are
      setState(() => _busy = true);
      await WidgetsBinding.instance.endOfFrame; // let the spinner paint
      final watch = Stopwatch()..start();
      final predictions = widget.classifier.classify(bytes); // UI thread
      watch.stop();
      debugPrint('[classify] ${origin.label}: ${watch.elapsedMilliseconds} ms');
      final record = ClassificationRecord(bytes, predictions, origin, watch.elapsed);
      widget.history.add(record);
      if (mounted) open(record);
    } on FormatException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } on SourceException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } on PlatformException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('${origin.label} unavailable: ${e.message ?? e.code}')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void open(ClassificationRecord record) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => ResultScreen(record: record)));

  Future<Uint8List?> _asset(String path) async => (await rootBundle.load(path)).buffer.asUint8List();

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _HomeTab(
        history: widget.history,
        busy: _busy,
        onCamera: () => _run(ImageOrigin.camera, widget.sources.fromCamera),
        onGallery: () => _run(ImageOrigin.gallery, widget.sources.fromGallery),
        onDownload: () => _run(ImageOrigin.download, () => showDownloadSheet(context, widget.sources)),
        onOpen: open,
      ),
      HistoryScreen(history: widget.history, onOpen: open, onStart: () => setState(() => _tab = 0)),
      ModelScreen(
        info: widget.classifier.info,
        onSample: () => _run(ImageOrigin.sample, () => _asset(kSampleAsset)),
        onTextFile: () => _run(ImageOrigin.sample, () async => utf8.encode('Not a picture.')),
      ),
    ];
    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: IndexedStack(index: _tab, children: tabs),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.history), label: 'History'),
              NavigationDestination(
                icon: Icon(Icons.memory_outlined),
                selectedIcon: Icon(Icons.memory),
                label: 'Model',
              ),
            ],
          ),
        ),
        if (_busy) const _Busy(),
      ],
    );
  }
}

class _Busy extends StatelessWidget {
  const _Busy();
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.35),
    child: const Center(
      child: Card(
        child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()),
      ),
    ),
  );
}

/// Screen 2.
class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.history,
    required this.busy,
    required this.onCamera,
    required this.onGallery,
    required this.onDownload,
    required this.onOpen,
  });
  final History history;
  final bool busy;
  final VoidCallback onCamera, onGallery, onDownload;
  final void Function(ClassificationRecord) onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = context.tokens;
    return ListView(
      padding: EdgeInsets.all(t.gutter),
      children: [
        Text('What are we looking at?', style: theme.textTheme.headlineSmall),
        SizedBox(height: t.gapXl),
        _Action(
          Icons.photo_camera_outlined,
          'Take a photo',
          'Use the phone camera',
          scheme.primaryContainer,
          scheme.onPrimaryContainer,
          busy ? null : onCamera,
        ),
        SizedBox(height: t.gapM),
        _Action(
          Icons.photo_library_outlined,
          'Choose from gallery',
          'Pick a saved picture or screenshot',
          scheme.secondaryContainer,
          scheme.onSecondaryContainer,
          busy ? null : onGallery,
        ),
        SizedBox(height: t.gapM),
        _Action(
          Icons.link,
          'Download an image',
          'Paste the address of a picture',
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
          busy ? null : onDownload,
        ),
        SizedBox(height: t.gapXl),
        Text('LATEST RESULT', style: theme.textTheme.labelSmall),
        SizedBox(height: t.gapS),
        ListenableBuilder(
          listenable: history,
          builder: (context, _) {
            final latest = history.latest;
            return Card(
              child: latest == null
                  ? Padding(
                      padding: EdgeInsets.all(t.gapL),
                      child: Text(
                        'Nothing classified yet. Your latest result shows up here.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    )
                  : RecordTile(record: latest, onTap: () => onOpen(latest)),
            );
          },
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action(this.icon, this.title, this.subtitle, this.bg, this.fg, this.onTap);
  final IconData icon;
  final String title, subtitle;
  final Color bg, fg;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tokens;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(t.radiusL),
      child: InkWell(
        borderRadius: BorderRadius.circular(t.radiusL),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(t.gapL + 2),
          child: Row(
            children: [
              Icon(icon, color: fg, size: 28),
              SizedBox(width: t.gapL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium?.copyWith(color: fg)),
                    Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: fg)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}

/// Asks for an image address and downloads it. Returns null when dismissed.
Future<Uint8List?> showDownloadSheet(BuildContext context, ImageSources sources) => showModalBottomSheet<Uint8List>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _DownloadSheet(sources),
);

class _DownloadSheet extends StatefulWidget {
  const _DownloadSheet(this.sources);
  final ImageSources sources;
  @override
  State<_DownloadSheet> createState() => _DownloadSheetState();
}

class _DownloadSheetState extends State<_DownloadSheet> {
  final _url = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _download() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bytes = await widget.sources.fromUrl(_url.text);
      if (mounted) Navigator.pop(context, bytes);
    } on SourceException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.message;
        });
      }
    }
  }

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: EdgeInsets.fromLTRB(t.gutter, 0, t.gutter, MediaQuery.viewInsetsOf(context).bottom + t.gutter),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Download an image', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: t.gapL),
          TextField(
            controller: _url,
            enabled: !_loading,
            autofocus: true,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: 'Image address',
              hintText: 'https://…/mug.jpg',
              errorText: _error,
              errorMaxLines: 3,
            ),
            onSubmitted: (_) => _download(),
          ),
          SizedBox(height: t.gapM),
          if (_loading) const LinearProgressIndicator() else SizedBox(height: 4),
          SizedBox(height: t.gapM),
          FilledButton(onPressed: _loading ? null : _download, child: const Text('Download and classify')),
        ],
      ),
    );
  }
}
