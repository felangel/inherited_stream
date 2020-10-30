import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inherited_stream/inherited_stream.dart';

class InheritedIntStream extends InheritedStream<Stream<int>> {
  InheritedIntStream({
    Key key,
    Stream<int> stream,
    Widget child,
  }) : super(key: key, stream: stream, child: child);
}

void main() {
  group('InheritedStream', () {
    test('throws AssertionError when child is null', () {
      expect(
        () => InheritedIntStream(stream: Stream.value(0), child: null),
        throwsAssertionError,
      );
    });

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
        stream: null,
        child: builder,
      ));
      expect(buildCount, equals(2));
    });
  });
}
