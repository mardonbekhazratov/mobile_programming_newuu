import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'models.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/classifier.dart';
import 'services/image_sources.dart';
import 'services/smoke_test.dart';
import 'theme/app_theme.dart';

/// Owns the one and only classifier (T11): created here at start-up, handed
/// down by constructor injection, closed when the app shuts down. No screen
/// calls [Classifier.load] itself.
class ClassifierApp extends StatefulWidget {
  const ClassifierApp({super.key, this.loader = Classifier.load});
  final Future<ImageClassifier> Function() loader;

  @override
  State<ClassifierApp> createState() => _ClassifierAppState();
}

class _ClassifierAppState extends State<ClassifierApp> {
  final _navigator = GlobalKey<NavigatorState>();
  final _history = History();
  final _sources = ImageSources();
  late Future<ImageClassifier> _loading;
  ImageClassifier? _classifier;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _load();
    _lifecycle = AppLifecycleListener(onDetach: _close);
  }

  void _load() {
    _loading = widget.loader().then((c) {
      _classifier = c;
      if (kDebugMode) runSmokeTest(c);
      return c;
    });
  }

  void _close() {
    _classifier?.close();
    _classifier = null;
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _close();
    _history.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lens',
      navigatorKey: _navigator,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: WelcomeScreen(
        loading: _loading,
        onRetry: () => setState(_load),
        onStart: (c) => _navigator.currentState!.pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomeShell(classifier: c, history: _history, sources: _sources),
          ),
        ),
      ),
    );
  }
}
