import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:inherited_stream/inherited_stream.dart';
import 'package:rxdart/rxdart.dart';

void main() => runApp(MyApp());

/// Root Material App
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}

/// Home Page which manages the state of the [ValueStream].
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _subject = BehaviorSubject<double>.seeded(0.0);

  @override
  void dispose() {
    _subject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: ProgressModel(stream: _subject.stream, child: Progress()),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              final random = (Random().nextDouble() * 0.1);
              final value = _subject.value + random >= 1.0
                  ? 1.0
                  : _subject.value + random;
              _subject.add(value);
            },
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            child: const Icon(Icons.clear),
            onPressed: () => _subject.add(0),
          ),
        ],
      ),
    );
  }
}

/// StatelessWidget which renders a [CircularProgressIndicator] based
/// on the value of the [ProgressModel].
class Progress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final progress = ProgressModel.of(context);
    final percentage = (progress * 100).toStringAsFixed(2);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(value: progress, strokeWidth: 8),
        const SizedBox(height: 16),
        Text('$percentage%', style: Theme.of(context).textTheme.headline6),
      ],
    );
  }
}

/// {@template progress_model}
/// [InheritedStream] which exposes a [ValueStream<double>] which can be
/// used to notify dependents when the stream emits a new `double`.
/// {@endtemplate}
class ProgressModel extends InheritedStream<ValueStream<double>> {
  /// {@macro progress_model}
  const ProgressModel({
    Key key,
    ValueStream<double> stream,
    Widget child,
  }) : super(key: key, stream: stream, child: child);

  /// static method that calls [BuildContext.dependOnInheritedWidgetOfExactType]
  /// to register the context as a dependent and expose a `double`.
  static double of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ProgressModel>()
        .stream
        .value;
  }
}
