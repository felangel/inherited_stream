library inherited_stream;

import 'dart:async';

import 'package:flutter/widgets.dart';

/// {@template inherited_stream}
/// An inherited widget for a [Stream], which updates its
/// dependencies when the [Stream] emits.
///
/// This is a variant of [InheritedWidget], specialized for subclasses of
/// [Stream].
///
/// Dependents are notified whenever the [stream] emits, or
/// whenever the identity of the [stream] changes.
///
/// Multiple emissions are coalesced, so that dependents only rebuild once
/// even if the [stream] emits multiple times between two frames.
///
/// Typically this class is subclassed with a class that provides an `of` static
/// method that calls [BuildContext.dependOnInheritedWidgetOfExactType]
/// with that class.
///
/// The [updateShouldNotify] method may also be overridden, to change the logic
/// in the cases where [stream] itself is changed. The [updateShouldNotify]
/// method is called with the old [stream] in the case of the [stream] being
/// changed. When it returns true, the dependents are marked as needing to be
/// rebuilt this frame.
/// {@endtemplate}
abstract class InheritedStream<T extends Stream<dynamic>>
    extends InheritedWidget {
  /// {@macro inherited_Stream}
  const InheritedStream({
    Key key,
    this.stream,
    @required Widget child,
  })  : assert(child != null),
        super(key: key, child: child);

  /// The [Stream] object to which to subscribe.
  ///
  /// Whenever this object emits data, the dependents of this
  /// widget are updated.
  ///
  /// By default, whenever the [stream] is changed (including when changing to
  /// or from null), if the old [stream] is not equal to the new [stream] (as
  /// determined by the `==` operator), dependents are updated. This behavior
  /// can be overridden by overriding [updateShouldNotify].
  ///
  /// While the [stream] is null, dependents are not updated.
  final T stream;

  @override
  bool updateShouldNotify(InheritedStream<T> oldWidget) {
    return oldWidget.stream != stream;
  }

  @override
  _InheritedStreamElement<T> createElement() =>
      _InheritedStreamElement<T>(this);
}

class _InheritedStreamElement<T extends Stream<dynamic>>
    extends InheritedElement {
  _InheritedStreamElement(InheritedStream<T> widget) : super(widget) {
    _subscription = widget.stream?.listen((dynamic _) => _handleUpdate());
  }

  StreamSubscription _subscription;

  @override
  InheritedStream<T> get widget => super.widget as InheritedStream<T>;

  bool _dirty = false;

  @override
  void update(InheritedStream<T> newWidget) {
    final oldStream = widget.stream;
    final newStream = newWidget.stream;
    if (oldStream != newStream) {
      _subscription?.cancel();
      _subscription = newStream?.listen((dynamic _) => _handleUpdate());
    }
    super.update(newWidget);
  }

  @override
  Widget build() {
    if (_dirty) notifyClients(widget);
    return super.build();
  }

  void _handleUpdate() {
    _dirty = true;
    markNeedsBuild();
  }

  @override
  void notifyClients(InheritedStream<T> oldWidget) {
    super.notifyClients(oldWidget);
    _dirty = false;
  }

  @override
  void unmount() {
    _subscription?.cancel();
    super.unmount();
  }
}

/// {@template deferred_inherited_stream}
/// A variant of [InheritedStream] which supports a deferred subscription
/// to the [Stream].
///
/// See also:
///
/// * [InheritedStream], like [DeferredInheritedStream] but immediately
/// subscribes to the [Stream].
/// {@endtemplate}
abstract class DeferredInheritedStream<T extends Stream<dynamic>>
    extends InheritedWidget {
  /// {@macro deferred_inherited_strem}
  const DeferredInheritedStream({
    Key key,
    this.deferredStream,
    @required Widget child,
  })  : assert(child != null),
        super(key: key, child: child);

  /// The deferred [Stream] object to which to subscribe.
  final Future<T> deferredStream;

  @override
  bool updateShouldNotify(DeferredInheritedStream<T> oldWidget) {
    return oldWidget.deferredStream != deferredStream;
  }

  @override
  _DeferredInheritedStreamElement<T> createElement() =>
      _DeferredInheritedStreamElement<T>(this);
}

class _DeferredInheritedStreamElement<T extends Stream<dynamic>>
    extends InheritedElement {
  _DeferredInheritedStreamElement(
    DeferredInheritedStream<T> widget,
  ) : super(widget) {
    widget.deferredStream?.then((stream) {
      _subscription = stream?.listen((dynamic _) => _handleUpdate());
    });
  }

  StreamSubscription _subscription;

  @override
  DeferredInheritedStream<T> get widget =>
      super.widget as DeferredInheritedStream<T>;

  bool _dirty = false;

  @override
  void update(DeferredInheritedStream<T> newWidget) {
    final oldStream = widget.deferredStream;
    final newStream = newWidget.deferredStream;
    if (oldStream != newStream) {
      _subscription?.cancel();
      newStream?.then((stream) {
        _subscription = stream?.listen((dynamic _) => _handleUpdate());
      });
    }
    super.update(newWidget);
  }

  @override
  Widget build() {
    if (_dirty) notifyClients(widget);
    return super.build();
  }

  void _handleUpdate() {
    _dirty = true;
    markNeedsBuild();
  }

  @override
  void notifyClients(DeferredInheritedStream<T> oldWidget) {
    super.notifyClients(oldWidget);
    _dirty = false;
  }

  @override
  void unmount() {
    _subscription?.cancel();
    super.unmount();
  }
}
