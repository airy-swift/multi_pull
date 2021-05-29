import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

// The over-scroll distance that moves the indicator to its maximum
// displacement, as a percentage of the scrollable's container extent.
const double _kDragContainerExtentPercentage = 0.25;

// How much the scroll's drag gesture can overshoot the RefreshIndicator's
// displacement; max displacement = _kDragSizeFactorLimit * displacement.
const double _kDragSizeFactorLimit = 1.5;

const double _widgetScale = 0.8;

const double _actionSize = 70;

// When the scroll ends, the duration of the refresh indicator's animation
// to the RefreshIndicator's displacement.

// The duration of the ScaleTransition that starts when the refresh action
// has completed.
const Duration _kIndicatorScaleDuration = Duration(milliseconds: 200);

/// The signature for a function that's called when the user has dragged a
/// [RefreshIndicator] far enough to demonstrate that they want the app to
/// refresh. The returned [Future] must complete when the refresh operation is
/// finished.
///
/// Used by [RefreshIndicator.onRefresh].
typedef RefreshCallback = Future<void> Function();

// The state machine moves through these modes only when the scrollable
// identified by scrollableKey has been scrolled to its min or max limit.
enum _RefreshIndicatorMode {
  drag, // Pointer is down.
  armed, // Dragged far enough that an up event will run the onRefresh callback.
  snap, // Animating to the indicator's final "displacement".
  refresh, // Running the refresh callback.
  done, // Animating the indicator's fade-out after refreshing.
  canceled, // Animating the indicator's fade-out after not arming.
}

/// A widget that supports the Material "swipe to refresh" idiom.
///
/// When the child's [Scrollable] descendant overscrolls, an animated circular
/// progress indicator is faded into view. When the scroll ends, if the
/// indicator has been dragged far enough for it to become completely opaque,
/// the [onRefresh] callback is called. The callback is expected to update the
/// scrollable's contents and then complete the [Future] it returns. The refresh
/// indicator disappears after the callback's [Future] has completed.
///
/// ## Troubleshooting
///
/// ### Refresh indicator does not show up
///
/// The [RefreshIndicator] will appear if its scrollable descendant can be
/// overscrolled, i.e. if the scrollable's content is bigger than its viewport.
/// To ensure that the [RefreshIndicator] will always appear, even if the
/// scrollable's content fits within its viewport, set the scrollable's
/// [Scrollable.physics] property to [AlwaysScrollableScrollPhysics]:
///
/// ```dart
/// ListView(
///   physics: const AlwaysScrollableScrollPhysics(),
///   children: ...
/// )
/// ```
///
/// A [RefreshIndicator] can only be used with a vertical scroll view.
///
/// See also:
///
///  * <https://material.io/design/platform-guidance/android-swipe-to-refresh.html>
///  * [RefreshIndicatorState], can be used to programmatically show the refresh indicator.
///  * [RefreshProgressIndicator], widget used by [RefreshIndicator] to show
///    the inner circular progress spinner during refreshes.
///  * [CupertinoSliverRefreshControl], an iOS equivalent of the pull-to-refresh pattern.
///    Must be used as a sliver inside a [CustomScrollView] instead of wrapping
///    around a [ScrollView] because it's a part of the scrollable instead of
///    being overlaid on top of it.
class MultiPull extends StatefulWidget {
  /// Creates a refresh indicator.
  ///
  /// The [onRefresh], [child], and [notificationPredicate] arguments must be
  /// non-null. The default
  /// [displacement] is 40.0 logical pixels.
  ///
  /// The [semanticsLabel] is used to specify an accessibility label for this widget.
  /// If it is null, it will be defaulted to [MaterialLocalizations.refreshIndicatorSemanticLabel].
  /// An empty string may be passed to avoid having anything read by screen reading software.
  /// The [semanticsValue] may be used to specify progress on the widget.
  const MultiPull(
      {Key key,
      @required this.child,
      this.displacement = 40.0,
      @required this.actionWidgets,
      this.circleOpacity = 0.3,
      this.circleColor = Colors.grey,
      this.circleMoveDuration,
      this.circleMoveCurve = Curves.easeIn,
      this.color,
      this.backgroundColor,
      this.notificationPredicate = defaultScrollNotificationPredicate,
      this.semanticsLabel,
      this.semanticsValue,
      this.strokeWidth = 2.0})
      : assert(child != null),
        assert(actionWidgets != null),
        assert(notificationPredicate != null),
        assert(strokeWidth != null),
        super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// The refresh indicator will be stacked on top of this child. The indicator
  /// will appear when child's Scrollable descendant is over-scrolled.
  ///
  /// Typically a [ListView] or [CustomScrollView].
  final Widget child;

  /// The distance from the child's top or bottom edge to where the refresh
  /// indicator will settle. During the drag that exposes the refresh indicator,
  /// its actual displacement may significantly exceed this value.
  final double displacement;

  final List<ActionWidget> actionWidgets;

  final double circleOpacity;

  final Color circleColor;

  final Duration circleMoveDuration;

  final Curve circleMoveCurve;

  /// The progress indicator's foreground color. The current theme's
  /// [ThemeData.accentColor] by default.
  final Color color;

  /// The progress indicator's background color. The current theme's
  /// [ThemeData.canvasColor] by default.
  final Color backgroundColor;

  /// A check that specifies whether a [ScrollNotification] should be
  /// handled by this widget.
  ///
  /// By default, checks whether `notification.depth == 0`. Set it to something
  /// else for more complicated layouts.
  final ScrollNotificationPredicate notificationPredicate;

  /// {@macro flutter.material.progressIndicator.semanticsLabel}
  ///
  /// This will be defaulted to [MaterialLocalizations.refreshIndicatorSemanticLabel]
  /// if it is null.
  final String semanticsLabel;

  /// {@macro flutter.material.progressIndicator.semanticsValue}
  final String semanticsValue;

  /// Defines `strokeWidth` for `RefreshIndicator`.
  ///
  /// By default, the value of `strokeWidth` is 2.0 pixels.
  final double strokeWidth;

  @override
  MultiPullState createState() => MultiPullState();
}

/// Contains the state for a [RefreshIndicator]. This class can be used to
/// programmatically show the refresh indicator, see the [show] method.
class MultiPullState extends State<MultiPull>
    with TickerProviderStateMixin<MultiPull> {
  AnimationController _positionController;
  AnimationController _horizonPositionController;
  AnimationController _scaleController;
  Animation<double> _positionFactor;
  Animation<double> _scaleFactor;
  Animation<double> _value;
  Animation<Color> _valueColor;

  _RefreshIndicatorMode _mode;
  Future<void> _pendingRefreshFuture;
  bool _isIndicatorAtTop;
  double _dragOffset;

  GlobalKey _key = GlobalKey();

  double indicatorWidth;
  List<double> clampList;

  int _circlePreviousPositionIndex;

  Widget _indicator;

  static final Animatable<double> _threeQuarterTween =
      Tween<double>(begin: 0.0, end: 0.75);
  static final Animatable<double> _kDragSizeFactorLimitTween =
      Tween<double>(begin: 0.0, end: _kDragSizeFactorLimit);
  static final Animatable<double> _oneToZeroTween =
      Tween<double>(begin: 1.0, end: 0.0);

  @override
  void initState() {
    super.initState();

    _positionController = AnimationController(vsync: this);
    _positionFactor = _positionController.drive(_kDragSizeFactorLimitTween);
    _value = _positionController.drive(
        _threeQuarterTween); // The "value" of the circular progress indicator during a drag.

    _horizonPositionController = AnimationController(vsync: this, value: 0.5);

    _scaleController = AnimationController(vsync: this);
    _scaleFactor = _scaleController.drive(_oneToZeroTween);
  }

  @override
  void didChangeDependencies() {
    final ThemeData theme = Theme.of(context);
    _valueColor = _positionController.drive(
      ColorTween(
        begin: (widget.color ?? theme.accentColor).withOpacity(0.0),
        end: (widget.color ?? theme.accentColor).withOpacity(1.0),
      ).chain(
          CurveTween(curve: const Interval(0.0, 1.0 / _kDragSizeFactorLimit))),
    );
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _positionController.dispose();
    _horizonPositionController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!widget.notificationPredicate(notification)) return false;
    if (notification is ScrollStartNotification &&
        notification.metrics.extentBefore == 0.0 &&
        _mode == null &&
        _start(notification.metrics.axisDirection)) {
      setState(() {
        _mode = _RefreshIndicatorMode.drag;

        _indicator = Container(
          height: _actionSize,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: widget.actionWidgets,
          ),
        );
      });
      return false;
    }
    bool indicatorAtTopNow;
    switch (notification.metrics.axisDirection) {
      case AxisDirection.down:
        indicatorAtTopNow = true;
        break;
      case AxisDirection.up:
        indicatorAtTopNow = false;
        break;
      case AxisDirection.left:
      case AxisDirection.right:
        indicatorAtTopNow = null;
        break;
    }
    if (indicatorAtTopNow != _isIndicatorAtTop) {
      if (_mode == _RefreshIndicatorMode.drag ||
          _mode == _RefreshIndicatorMode.armed)
        _dismiss(_RefreshIndicatorMode.canceled);
    } else if (notification is ScrollUpdateNotification) {
      if (_mode == _RefreshIndicatorMode.drag ||
          _mode == _RefreshIndicatorMode.armed) {
        if (notification.metrics.extentBefore > 0.0) {
          _dismiss(_RefreshIndicatorMode.canceled);
        } else {
          _dragOffset -= notification.scrollDelta;
          _checkDragOffset(notification.dragDetails);
        }
      }
      if (_mode == _RefreshIndicatorMode.armed &&
          notification.dragDetails == null) {
        _show();
      }
    } else if (notification is OverscrollNotification) {
      if (_mode == _RefreshIndicatorMode.drag ||
          _mode == _RefreshIndicatorMode.armed) {
        _dragOffset -= notification.overscroll / 2.0;
        _checkDragOffset(notification.dragDetails);
      }
    } else if (notification is ScrollEndNotification) {
      switch (_mode) {
        case _RefreshIndicatorMode.armed:
          _show();
          break;
        case _RefreshIndicatorMode.drag:
          _dismiss(_RefreshIndicatorMode.canceled);
          break;
        default:
          // do nothing
          break;
      }
    }
    return false;
  }

  bool _handleGlowNotification(OverscrollIndicatorNotification notification) {
    if (notification.depth != 0 || !notification.leading) return false;
    if (_mode == _RefreshIndicatorMode.drag) {
      notification.disallowGlow();
      return true;
    }
    return false;
  }

  bool _start(AxisDirection direction) {
    assert(_mode == null);
    assert(_isIndicatorAtTop == null);
    assert(_dragOffset == null);
    switch (direction) {
      case AxisDirection.down:
        _isIndicatorAtTop = true;
        break;
      case AxisDirection.up:
        _isIndicatorAtTop = false;
        break;
      case AxisDirection.left:
      case AxisDirection.right:
        _isIndicatorAtTop = null;
        // we do not support horizontal scroll views.
        return false;
    }
    _dragOffset = 0.0;
    _scaleController.value = 0.0;
    _positionController.value = 0.0;

    _horizonPositionController.value = 0.5;

    indicatorWidth = _key.currentContext.size.width - _actionSize / 2;
    final spaceWidth = 1 / (widget.actionWidgets.length + 1);
    clampList =
        List.generate(widget.actionWidgets.length, (i) => (i + 1) * spaceWidth);
    return true;
  }

  void _checkDragOffset(DragUpdateDetails details) {
    assert(_mode == _RefreshIndicatorMode.drag ||
        _mode == _RefreshIndicatorMode.armed);
    if (details?.globalPosition == null) return;
    double newValue = _dragOffset /
        (details.globalPosition.dy * _kDragContainerExtentPercentage);
    if (_mode == _RefreshIndicatorMode.armed)
      newValue = math.max(newValue, 1.0 / _kDragSizeFactorLimit);
    _positionController.value =
        newValue.clamp(0.0, 1.0) as double; // this triggers various rebuilds

    if (_mode == _RefreshIndicatorMode.armed) {
      final dynamicPos =
          ((details.globalPosition.dx * _widgetScale) / indicatorWidth)
              .clamp(0.0, 1.0);
      final nextPositionIndex = _clampIndex(dynamicPos);
      if (nextPositionIndex != _circlePreviousPositionIndex) {
        _circlePreviousPositionIndex = nextPositionIndex;
        _horizonPositionController.animateTo(
          clampList[nextPositionIndex],
          duration: widget.circleMoveDuration ?? Duration(milliseconds: 500),
          curve: widget.circleMoveCurve,
        );
        // _horizonPositionController.value
      }
    }

    if (_mode == _RefreshIndicatorMode.drag && _valueColor.value.alpha == 0xFF)
      _mode = _RefreshIndicatorMode.armed;
  }

  // Stop showing the refresh indicator.
  Future<void> _dismiss(_RefreshIndicatorMode newMode) async {
    await Future<void>.value();
    // This can only be called from _show() when refreshing and
    // _handleScrollNotification in response to a ScrollEndNotification or
    // direction change.
    assert(newMode == _RefreshIndicatorMode.canceled ||
        newMode == _RefreshIndicatorMode.done);
    setState(() {
      _mode = newMode;
    });
    switch (_mode) {
      case _RefreshIndicatorMode.done:
        await _scaleController.animateTo(1.0,
            duration: _kIndicatorScaleDuration);
        break;
      case _RefreshIndicatorMode.canceled:
        await _positionController.animateTo(0.0,
            duration: _kIndicatorScaleDuration);
        await _horizonPositionController.animateTo(0.0,
            duration: _kIndicatorScaleDuration);
        break;
      default:
        assert(false);
    }
    if (mounted && _mode == newMode) {
      _dragOffset = null;
      _isIndicatorAtTop = null;
      setState(() {
        _mode = null;
      });
    }
  }

  int _clampIndex(double value) {
    final _clampList = clampList.map((x) => (x - value).abs()).toList();
    final _min = _clampList.reduce(math.min);
    return _clampList.indexOf(_min);
  }

  void _show() {
    assert(_mode != _RefreshIndicatorMode.refresh);
    assert(_mode != _RefreshIndicatorMode.snap);
    final Completer<void> completer = Completer<void>();
    _pendingRefreshFuture = completer.future;
    _mode = _RefreshIndicatorMode.snap;

    final selectedIndex = _clampIndex(_horizonPositionController.value);

    if (widget.actionWidgets[selectedIndex].action != null) {
      widget.actionWidgets[selectedIndex].action();

      completer.complete();
      _dismiss(_RefreshIndicatorMode.done);
    } else if (widget.actionWidgets[selectedIndex].onRefresh != null) {
      if (mounted && _mode == _RefreshIndicatorMode.snap) {
        setState(() {
          _mode = _RefreshIndicatorMode.refresh;
        });
      }
      final bool showIndeterminateIndicator =
          _mode == _RefreshIndicatorMode.refresh ||
              _mode == _RefreshIndicatorMode.done;
      setState(() {
        _indicator = RefreshProgressIndicator(
          semanticsLabel: widget.semanticsLabel ??
              MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
          semanticsValue: widget.semanticsValue,
          value: showIndeterminateIndicator ? null : _value.value,
          valueColor: _valueColor,
          backgroundColor: widget.backgroundColor,
          strokeWidth: widget.strokeWidth,
        );
      });
      final Future<void> refreshResult =
          widget.actionWidgets[selectedIndex].onRefresh();
      assert(() {
        if (refreshResult == null)
          FlutterError.reportError(FlutterErrorDetails(
            exception: FlutterError('The onRefresh callback returned null.\n'
                'The RefreshIndicator onRefresh callback must return a Future.'),
            context: ErrorDescription('when calling onRefresh'),
            library: 'material library',
          ));
        return true;
      }());
      if (refreshResult == null) return;
      refreshResult.whenComplete(() {
        if (mounted && _mode == _RefreshIndicatorMode.refresh) {
          completer.complete();
          _dismiss(_RefreshIndicatorMode.done);
        }
      });
    } else {
      assert(false);
    }
  }

  /// Show the refresh indicator and run the refresh callback as if it had
  /// been started interactively. If this method is called while the refresh
  /// callback is running, it quietly does nothing.
  ///
  /// Creating the [RefreshIndicator] with a [GlobalKey<RefreshIndicatorState>]
  /// makes it possible to refer to the [RefreshIndicatorState].
  ///
  /// The future returned from this method completes when the
  /// [RefreshIndicator.onRefresh] callback's future completes.
  ///
  /// If you await the future returned by this function from a [State], you
  /// should check that the state is still [mounted] before calling [setState].
  ///
  /// When initiated in this manner, the refresh indicator is independent of any
  /// actual scroll view. It defaults to showing the indicator at the top. To
  /// show it at the bottom, set `atTop` to false.
  Future<void> show({bool atTop = true}) {
    if (_mode != _RefreshIndicatorMode.refresh &&
        _mode != _RefreshIndicatorMode.snap) {
      if (_mode == null) _start(atTop ? AxisDirection.down : AxisDirection.up);
      _show();
    }
    return _pendingRefreshFuture;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final Widget child = NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: _handleGlowNotification,
        child: widget.child,
      ),
    );
    assert(() {
      if (_mode == null) {
        assert(_dragOffset == null);
        assert(_isIndicatorAtTop == null);
      } else {
        assert(_dragOffset != null);
        assert(_isIndicatorAtTop != null);
      }
      return true;
    }());

    return Stack(
      key: _key,
      children: <Widget>[
        child,

        /// action
        if (_mode != null)
          Positioned(
            top: _isIndicatorAtTop ? 0.0 : null,
            bottom: !_isIndicatorAtTop ? 0.0 : null,
            left: 0.0,
            right: 0.0,
            child: SizeTransition(
              axisAlignment: _isIndicatorAtTop ? 1.0 : -1.0,
              sizeFactor: _positionFactor, // this is what brings it down
              child: Container(
                padding: _isIndicatorAtTop
                    ? EdgeInsets.only(top: widget.displacement)
                    : EdgeInsets.only(bottom: widget.displacement),
                alignment: _isIndicatorAtTop
                    ? Alignment.topCenter
                    : Alignment.bottomCenter,
                child: ScaleTransition(
                  scale: _scaleFactor,
                  child: AnimatedBuilder(
                    animation: _positionController,
                    builder: (BuildContext context, Widget child) {
                      return FractionallySizedBox(
                        widthFactor: _widgetScale,
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 500),
                          child: _indicator,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

        /// circle
        if (_mode != null)
          Positioned(
            top: _isIndicatorAtTop ? 0.0 : null,
            bottom: !_isIndicatorAtTop ? 0.0 : null,
            left: 0.0,
            right: 0.0,
            child: SizeTransition(
              axisAlignment: _isIndicatorAtTop ? 1.0 : -1.0,
              sizeFactor: _positionFactor, // this is what brings it down
              child: Container(
                padding: _isIndicatorAtTop
                    ? EdgeInsets.only(top: widget.displacement)
                    : EdgeInsets.only(bottom: widget.displacement),
                alignment: _isIndicatorAtTop
                    ? Alignment.topCenter
                    : Alignment.bottomCenter,
                child: ScaleTransition(
                  scale: _scaleFactor,
                  child: AnimatedBuilder(
                      animation: _horizonPositionController,
                      builder: (context, child) {
                        return Transform.translate(
                          child: Opacity(
                            opacity: _mode == _RefreshIndicatorMode.refresh ||
                                    _mode == _RefreshIndicatorMode.done
                                ? 0.0
                                : widget.circleOpacity,
                            child: Container(
                              width: _actionSize,
                              height: _actionSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.circleColor,
                              ),
                            ),
                          ),
                          offset: Offset(
                            (_horizonPositionController.value *
                                    indicatorWidth) -
                                (indicatorWidth / 2),
                            0,
                          ),
                        );
                      }),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// TODO: write what is this
class ActionWidget extends StatelessWidget {
  const ActionWidget({
    @required this.icon,
    this.label,
    this.action,
    this.onRefresh,
  }) : assert((action != null) != (onRefresh != null));

  final Widget icon;
  final String label;
  final Function action;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: _actionSize - 30,
          height: _actionSize - 30,
          child: icon,
        ),
        if (label != null) //
          Text(label),
      ],
    );
  }
}
