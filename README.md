# Inherited Stream

[![Pub](https://img.shields.io/pub/v/inherited_stream.svg)](https://pub.dev/packages/inherited_stream)
[![build](https://github.com/felangel/inherited_stream/workflows/build/badge.svg)](https://github.com/felangel/inherited_stream/actions)
[![coverage](https://raw.githubusercontent.com/felangel/inherited_stream/main/coverage_badge.svg)](https://github.com/felangel/inherited_stream/actions)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

An InheritedWidget for Streams, which updates its dependencies when the Stream emits.

## Usage

### Create an InheritedStream

```dart
class ProgressModel extends InheritedStream<ValueStream<double>> {
  const ProgressModel({
    Key? key,
    required ValueStream<double> stream,
    required Widget child,
  }) : super(key: key, stream: stream, child: child);

  static double of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ProgressModel>()!
        .stream
        .value!;
  }
}
```

### Insert into the Widget Tree

```dart
class _MyState extends State<MyPage> {
  final _subject = BehaviorSubject<double>.seeded(0.0);

  @override
  void dispose() {
    _subject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProgressModel(
        stream: _subject.stream,
        child: Progress(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _subject.add(Random.nextDouble()),
      ),
    );
  }
}
```

### Register Dependant(s)

```dart
class Progress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(value: ProgressModel.of(context));
  }
}
```
