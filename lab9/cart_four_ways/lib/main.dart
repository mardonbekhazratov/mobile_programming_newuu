import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bloc/cart_page_bloc.dart';
import 'cubit/cart_page_cubit.dart';
import 'riverpod/cart_page_riverpod.dart';
import 'setstate/cart_page_setstate.dart';

void main() {
  Bloc.observer = const TransitionLogger();
  runApp(const ProviderScope(child: MainApp()));
}

class TransitionLogger extends BlocObserver {
  const TransitionLogger();

  @override
  void onTransition(Bloc<dynamic, dynamic> bloc, Transition<dynamic, dynamic> transition) {
    super.onTransition(bloc, transition);
    debugPrint('${bloc.runtimeType}: ${transition.currentState} '
        '--${transition.event.runtimeType}--> ${transition.nextState}');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(home: HomePage());
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget open(String label, Widget page) => FilledButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page)),
          child: Text(label),
        );
    return Scaffold(
      appBar: AppBar(title: const Text('One Cart, Four Ways')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, spacing: 12, children: [
          open('setState', const SetStateCartPage()),
          open('Riverpod', const RiverpodCartPage()),
          open('Cubit', const CubitCartPage()),
          open('Bloc', const BlocCartPage()),
        ]),
      ),
    );
  }
}
