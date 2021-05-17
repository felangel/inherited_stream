import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inherited_stream/inherited_stream.dart';

class InheritedIntStream extends InheritedStream<Stream<int>> {
  InheritedIntStream({
    Key? key,
    required Stream<int> stream,
    required Widget child,
  }) : super(key: key, stream: stream, child: child);
}

class DeferredInheritedIntStream extends DeferredInheritedStream<Stream<int>> {
  DeferredInheritedIntStream({
    Key? key,
    required Future<Stream<int>> deferredStream,
    required Widget child,
  }) : super(key: key, deferredStream: deferredStream, child: child);
}

void main() {
  group('InheritedStream', () {
    testWidgets('does not rebuild unnecessarily', (tester) async {
      var buildCount = 0;
      final controller = StreamController<int>();
      final Widget builder = Builder(builder: (BuildContext context) {
        context.dependOnInheritedWidgetOfExactType<InheritedIntStream>();
        buildCount += 1;
        return Container();
      });
      final Widget inner = InheritedIntStream(
        stream: controller.stream,
        child: builder,
      );

      await tester.pumpWidget(inner);
      expect(buildCount, equals(1));

      await tester.pumpWidget(inner);
      expect(buildCount, equals(1));

      await tester.pump();
      expect(buildCount, equals(1));
    });

    testWidgets('updates dependents when stream emits', (tester) async {
      var buildCount = 0;
      final controller = StreamController<int>();
      final Widget builder = Builder(builder: (BuildContext context) {
        context.dependOnInheritedWidgetOfExactType<InheritedIntStream>();
        buildCount += 1;
        return Container();
      });
      final Widget inner = InheritedIntStream(
        stream: controller.stream,
        child: builder,
      );

      await tester.pumpWidget(inner);
      expect(buildCount, equals(1));

      controller.add(1);
      await tester.pumpAndSettle();

      expect(buildCount, equals(2));

      await tester.pumpWidget(inner);
      expect(buildCount, equals(2));
    });

    testWidgets('updates dependents when stream changes', (tester) async {
      var buildCount = 0;
      final controller = StreamController<int>();
      final Widget builder = Builder(builder: (BuildContext context) {
        context.dependOnInheritedWidgetOfExactType<InheritedIntStream>();
        buildCount += 1;
        return Container();
      });
      final Widget inner = InheritedIntStream(
        stream: controller.stream,
        child: builder,
      );

      await tester.pumpWidget(inner);
      expect(buildCount, equals(1));

      await tester.pumpWidget(InheritedIntStream(
        stream: const Stream<int>.empty(),
        child: builder,
      ));
      expect(buildCount, equals(2));
    });
  });

  group('DeferredInheritedStream', () {
    testWidgets('does not rebuild unnecessarily', (tester) async {
      var buildCount = 0;
      final completer = Completer<Stream<int>>();
      final Widget builder = Builder(builder: (BuildContext context) {
        context
            .dependOnInheritedWidgetOfExactType<DeferredInheritedIntStream>();
        buildCount += 1;
        return Container();
      });
      final Widget inner = DeferredInheritedIntStream(
        deferredStream: completer.future,
        child: builder,
      );

      await tester.pumpWidget(inner);
      expect(buildCount, equals(1));

      await tester.pumpWidget(inner);
      expect(buildCount, equals(1));

      await tester.pump();
      expect(buildCount, equals(1));
    });

    testWidgets('updates dependents when deferred stream emits',
        (tester) async {
      var buildCount = 0;
      final controller = StreamController<int>();
      final completer = Completer<Stream<int>>();
      final Widget builder = Builder(builder: (BuildContext context) {
        context
            .dependOnInheritedWidgetOfExactType<DeferredInheritedIntStream>();
        buildCount += 1;
        return Container();
      });
      final Widget inner = DeferredInheritedIntStream(
        deferredStream: completer.future,
        child: builder,
      );

      await tester.pumpWidget(inner);
      expect(buildCount, equals(1));

      controller.add(1);
      await tester.pumpAndSettle();

      expect(buildCount, equals(1));

      completer.complete(controller.stream);

      await tester.pumpWidget(inner);
      expect(buildCount, equals(2));

      await tester.pumpWidget(inner);
      expect(buildCount, equals(2));
    });

    testWidgets('updates dependents when deferred stream changes',
        (tester) async {
      var buildCount = 0;
      final completer = Completer<Stream<int>>();
      final Widget builder = Builder(builder: (BuildContext context) {
        context
            .dependOnInheritedWidgetOfExactType<DeferredInheritedIntStream>();
        buildCount += 1;
        return Container();
      });
      final Widget inner = DeferredInheritedIntStream(
        deferredStream: completer.future,
        child: builder,
      );

      await tester.pumpWidget(inner);
      expect(buildCount, equals(1));

      await tester.pumpWidget(DeferredInheritedIntStream(
        deferredStream: Future.value(Stream.value(0)),
        child: builder,
      ));
      expect(buildCount, equals(2));
    });
  });
}
