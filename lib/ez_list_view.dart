import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A defensive, self-aware drop-in replacement for [ListView] that prevents
/// layout crashes when placed inside parents with unbounded constraints.
///
/// In standard Flutter, placing a [ListView] inside a [Column], [Row],
/// [Flex], or nested scroll view results in a fatal layout exception:
/// * `"Vertical viewport was given unbounded height"`
/// * `"Horizontal viewport was given unbounded width"`
///
/// [EzListView] intercepts these unbounded constraints before they cause
/// a crash:
///
/// * **Crash Prevention:** Automatically detects unbounded dimensions in the scrolling
///   or cross axes and applies a sensible, bounded fallback size.
/// * **Developer Feedback:** In debug mode, displays a visible red indicator and logs
///   a detailed, actionable [FlutterError] explaining the exact parent culprit
///   (e.g., [Column], [Row]) and how to permanently fix it.
/// * **Silent Protection:** In release mode, silently resolves the layout so users
///   never experience a red screen of death.
/// * **100% Drop-in Parity:** Supports all constructors from standard [ListView]:
///   [EzListView.new], [EzListView.builder], [EzListView.separated], and [EzListView.custom].
///
/// ## Layout algorithm
///
/// 1. Uses a [LayoutBuilder] to inspect incoming box constraints.
/// 2. If constraints are bounded in both the scrolling and cross axes (or if [shrinkWrap] is true),
///    renders standard [ListView] directly.
/// 3. If unbounded constraints are detected:
///    - Calculates a safe fallback size based on available screen space via [MediaQuery] or [View].
///    - Reports a structured error with culprit diagnosis via [_EzListViewHelper.reportUnboundedError] in debug mode.
///    - Invokes [onUnboundedDetected] callback if provided.
///    - Wraps the [ListView] in a [SizedBox] with bounded dimensions.
///    - When [showDebugIndicator] is true and running in debug mode, applies a red outline border.
///
/// ## Examples
///
/// ### Safe inside a Column (Crash Prevention)
///
/// ```dart
/// Column(
///   children: [
///     const Text('Header'),
///     // Won't crash! Automatically constrained with a debug warning.
///     EzListView.builder(
///       itemCount: 20,
///       itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
///     ),
///   ],
/// )
/// ```
///
/// ### Default children constructor
///
/// ```dart
/// EzListView(
///   children: const [
///     ListTile(title: Text('First')),
///     ListTile(title: Text('Second')),
///   ],
/// )
/// ```
///
/// ### Separated constructor
///
/// ```dart
/// EzListView.separated(
///   itemCount: 10,
///   itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
///   separatorBuilder: (context, index) => const Divider(),
/// )
/// ```
///
/// See also:
///
///  * [ListView], the standard Flutter scrollable list widget.
///  * [EzCustomScrollView], the companion defensive sliver scroll view.
class EzListView extends StatelessWidget {
  /// The builder used to construct children for [EzListView.builder] and [EzListView.separated].
  final NullableIndexedWidgetBuilder? itemBuilder;

  /// The number of items for [EzListView.builder] and [EzListView.separated].
  final int? itemCount;

  /// The delegate that supplies children for this list view.
  final SliverChildDelegate childrenDelegate;

  /// See [ListView.scrollDirection].
  final Axis scrollDirection;

  /// See [ListView.reverse].
  final bool reverse;

  /// See [ListView.controller].
  final ScrollController? controller;

  /// See [ListView.primary].
  final bool? primary;

  /// See [ListView.physics].
  final ScrollPhysics? physics;

  /// See [ListView.shrinkWrap].
  final bool shrinkWrap;

  /// See [ListView.padding].
  final EdgeInsetsGeometry? padding;

  /// See [ListView.itemExtent].
  final double? itemExtent;

  /// See [ListView.prototypeItem].
  final Widget? prototypeItem;

  /// See [ListView.addAutomaticKeepAlives].
  final bool addAutomaticKeepAlives;

  /// See [ListView.addRepaintBoundaries].
  final bool addRepaintBoundaries;

  /// See [ListView.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// See [ListView.cacheExtent].
  @Deprecated('Use scrollCacheExtent in Flutter 3.41+.')
  final double? cacheExtent;

  /// See [ListView.scrollCacheExtent].
  final double? scrollCacheExtent;

  /// See [ListView.semanticChildCount].
  final int? semanticChildCount;

  /// See [ListView.dragStartBehavior].
  final DragStartBehavior dragStartBehavior;

  /// See [ListView.keyboardDismissBehavior].
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// See [ListView.restorationId].
  final String? restorationId;

  /// See [ListView.clipBehavior].
  final Clip clipBehavior;

  /// See [ListView.hitTestBehavior].
  final HitTestBehavior hitTestBehavior;

  /// See [ListView.builder.findChildIndexCallback].
  final ChildIndexGetter? findChildIndexCallback;

  /// Whether to display a red border indicator in debug mode when unbounded constraints are detected.
  ///
  /// Defaults to `true`. Has no effect in release mode.
  final bool showDebugIndicator;

  /// Optional custom fallback height to use when unbounded height is detected.
  ///
  /// If `null`, defaults to 50% of available screen height.
  final double? fallbackHeight;

  /// Optional custom fallback width to use when unbounded width is detected.
  ///
  /// If `null`, defaults to 50% of available screen width.
  final double? fallbackWidth;

  /// Optional callback invoked when unbounded constraints are detected.
  ///
  /// Useful for automated telemetry, testing, or custom diagnostic logging.
  final void Function({
    required bool isWidthUnbounded,
    required bool isHeightUnbounded,
    required String? culprit,
  })? onUnboundedDetected;

  /// Creates a defensive version of [ListView] with explicit child widgets.
  EzListView({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemExtent,
    this.prototypeItem,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    @Deprecated('Use scrollCacheExtent in Flutter 3.41+.') this.cacheExtent,
    this.scrollCacheExtent,
    List<Widget> children = const <Widget>[],
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.showDebugIndicator = true,
    this.fallbackHeight,
    this.fallbackWidth,
    this.onUnboundedDetected,
  })  : itemBuilder = null,
        itemCount = children.length,
        findChildIndexCallback = null,
        childrenDelegate = SliverChildListDelegate(
          children,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
        );

  /// Creates a defensive, self-aware version of [ListView.builder].
  EzListView.builder({
    super.key,
    required NullableIndexedWidgetBuilder itemBuilder,
    this.itemCount,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemExtent,
    this.prototypeItem,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    @Deprecated('Use scrollCacheExtent in Flutter 3.41+.') this.cacheExtent,
    this.scrollCacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.findChildIndexCallback,
    this.showDebugIndicator = true,
    this.fallbackHeight,
    this.fallbackWidth,
    this.onUnboundedDetected,
  })  : itemBuilder = itemBuilder,
        childrenDelegate = SliverChildBuilderDelegate(
          itemBuilder,
          findChildIndexCallback: findChildIndexCallback,
          childCount: itemCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
        );

  /// Creates a defensive, self-aware version of [ListView.separated].
  EzListView.separated({
    super.key,
    required NullableIndexedWidgetBuilder itemBuilder,
    this.findChildIndexCallback,
    required IndexedWidgetBuilder separatorBuilder,
    required int itemCount,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemExtent,
    this.prototypeItem,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    @Deprecated('Use scrollCacheExtent in Flutter 3.41+.') this.cacheExtent,
    this.scrollCacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.showDebugIndicator = true,
    this.fallbackHeight,
    this.fallbackWidth,
    this.onUnboundedDetected,
  })  : itemBuilder = itemBuilder,
        itemCount = itemCount,
        semanticChildCount = itemCount,
        childrenDelegate = SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            final int itemIndex = index ~/ 2;
            if (index.isEven) {
              return itemBuilder(context, itemIndex);
            }
            return separatorBuilder(context, itemIndex);
          },
          findChildIndexCallback: findChildIndexCallback,
          childCount: _computeActualChildCount(itemCount),
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
          semanticIndexCallback: (Widget widget, int index) {
            return index.isEven ? index ~/ 2 : null;
          },
        );

  /// Creates a defensive version of [ListView.custom].
  const EzListView.custom({
    super.key,
    required this.childrenDelegate,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemExtent,
    this.prototypeItem,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    @Deprecated('Use scrollCacheExtent in Flutter 3.41+.') this.cacheExtent,
    this.scrollCacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.findChildIndexCallback,
    this.showDebugIndicator = true,
    this.fallbackHeight,
    this.fallbackWidth,
    this.onUnboundedDetected,
  })  : itemBuilder = null,
        itemCount = null;

  static int _computeActualChildCount(int itemCount) {
    return math.max(0, itemCount * 2 - 1);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isUnboundedHeight = constraints.maxHeight.isInfinite;
        final bool isUnboundedWidth = constraints.maxWidth.isInfinite;

        final bool isVertical = scrollDirection == Axis.vertical;

        bool needsFixHeight = false;
        bool needsFixWidth = false;

        if (isVertical) {
          if (isUnboundedHeight && !shrinkWrap) needsFixHeight = true;
          if (isUnboundedWidth) needsFixWidth = true;
        } else {
          if (isUnboundedWidth && !shrinkWrap) needsFixWidth = true;
          if (isUnboundedHeight) needsFixHeight = true;
        }

        final Widget listView = _buildListView();

        if (!needsFixHeight && !needsFixWidth) {
          return listView;
        }

        final fallbackDimensions =
            _EzListViewHelper.calculateFallbackDimensions(
          context: context,
          constraints: constraints,
          needsFixWidth: needsFixWidth,
          needsFixHeight: needsFixHeight,
          customFallbackWidth: fallbackWidth,
          customFallbackHeight: fallbackHeight,
        );

        if (kDebugMode) {
          final culprit = _EzListViewHelper.findCulprit(context);

          _EzListViewHelper.reportUnboundedError(
            needsFixWidth: needsFixWidth,
            needsFixHeight: needsFixHeight,
            scrollDirection: scrollDirection,
            shrinkWrap: shrinkWrap,
            culprit: culprit,
          );

          if (onUnboundedDetected != null) {
            onUnboundedDetected!(
              isWidthUnbounded: needsFixWidth,
              isHeightUnbounded: needsFixHeight,
              culprit: culprit,
            );
          }

          if (showDebugIndicator) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2.5),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: SizedBox(
                width: fallbackDimensions.width,
                height: fallbackDimensions.height,
                child: listView,
              ),
            );
          }
        }

        return SizedBox(
          width: fallbackDimensions.width,
          height: fallbackDimensions.height,
          child: listView,
        );
      },
    );
  }

  Widget _buildListView() {
    final effectiveCacheExtent = scrollCacheExtent ?? cacheExtent;
    return ListView.custom(
      childrenDelegate: childrenDelegate,
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      primary: primary,
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemExtent: itemExtent,
      prototypeItem: prototypeItem,
      // ignore: deprecated_member_use
      cacheExtent: effectiveCacheExtent,
      semanticChildCount: semanticChildCount,
      dragStartBehavior: dragStartBehavior,
      keyboardDismissBehavior: keyboardDismissBehavior,
      restorationId: restorationId,
      clipBehavior: clipBehavior,
      hitTestBehavior: hitTestBehavior,
    );
  }
}

/// Internal helper for [EzListView] layout diagnostics and fallback size calculation.
abstract final class _EzListViewHelper {
  /// Calculates fallback dimensions when unbounded constraints are encountered.
  static Size calculateFallbackDimensions({
    required BuildContext context,
    required BoxConstraints constraints,
    required bool needsFixWidth,
    required bool needsFixHeight,
    required double? customFallbackWidth,
    required double? customFallbackHeight,
  }) {
    final mediaQuery = MediaQuery.maybeOf(context);
    final view = View.maybeOf(context);

    final Size screenSize;
    if (mediaQuery != null) {
      screenSize = mediaQuery.size;
    } else if (view != null && view.devicePixelRatio > 0) {
      screenSize = view.physicalSize / view.devicePixelRatio;
    } else {
      screenSize = const Size(360.0, 640.0);
    }

    final double availableHeight = (screenSize.height -
            (mediaQuery?.padding.top ?? 0) -
            (mediaQuery?.padding.bottom ?? 0) -
            kToolbarHeight)
        .clamp(100.0, double.infinity);

    final double effectiveHeight;
    if (needsFixHeight) {
      if (constraints.maxHeight.isInfinite) {
        effectiveHeight = customFallbackHeight ?? (availableHeight * 0.5);
      } else {
        effectiveHeight = constraints.maxHeight;
      }
    } else {
      effectiveHeight = constraints.maxHeight;
    }

    final double effectiveWidth;
    if (needsFixWidth) {
      if (constraints.maxWidth.isInfinite) {
        effectiveWidth = customFallbackWidth ??
            (screenSize.width * 0.5).clamp(100.0, double.infinity);
      } else {
        effectiveWidth = constraints.maxWidth;
      }
    } else {
      effectiveWidth = constraints.maxWidth;
    }

    return Size(effectiveWidth, effectiveHeight);
  }

  /// Traverses ancestors to find the widget responsible for the unbounded constraint.
  static String findCulprit(BuildContext context) {
    String culprit = 'an unknown parent';
    context.visitAncestorElements((element) {
      final widget = element.widget;
      if (widget is Flex ||
          widget is ScrollView ||
          widget is Wrap ||
          widget is UnconstrainedBox) {
        culprit = widget.runtimeType.toString();
        return false;
      }
      return true;
    });
    return culprit;
  }

  /// Reports a detailed error to [FlutterError] explaining the exact cause and resolution.
  static void reportUnboundedError({
    required bool needsFixWidth,
    required bool needsFixHeight,
    required Axis scrollDirection,
    required bool shrinkWrap,
    required String culprit,
  }) {
    final String problematicDimension;
    if (needsFixWidth && needsFixHeight) {
      problematicDimension = 'width and height';
    } else if (needsFixWidth) {
      problematicDimension = 'width';
    } else {
      problematicDimension = 'height';
    }

    final String axisName =
        scrollDirection == Axis.vertical ? 'vertical' : 'horizontal';

    FlutterError.reportError(
      FlutterErrorDetails(
        exception:
            'EzListView: Unbounded $problematicDimension detected in $axisName scroll direction.',
        library: 'EzListView',
        context: ErrorDescription('while building EzListView'),
        informationCollector: () => [
          ErrorSummary(
              'EzListView has applied an automatic layout fallback to prevent a crash.'),
          ErrorDescription(
            'This widget was placed inside a $culprit with infinite $problematicDimension. '
            'In standard Flutter, this causes a fatal "Vertical/Horizontal viewport was given unbounded height/width" exception.',
          ),
          ErrorHint(
            'ACTION REQUIRED: For a permanent fix, wrap EzListView in an Expanded or Flexible (inside Flex/Column/Row), or a SizedBox with explicit dimensions.',
          ),
          if (!shrinkWrap &&
              ((scrollDirection == Axis.vertical && needsFixHeight) ||
                  (scrollDirection == Axis.horizontal && needsFixWidth)))
            ErrorHint(
              'Alternatively, if the list is intended to be only as tall/wide as its children, set shrinkWrap: true.',
            ),
        ],
      ),
    );
  }
}
