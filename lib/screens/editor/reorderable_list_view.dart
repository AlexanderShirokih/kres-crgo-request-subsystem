import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Taken from https://dartpad.dev/0fbfd605659c9d57bcf02843b6bc366c
class MyReorderableListView extends StatefulWidget {
  final List<Widget> children;
  final ReorderCallback onReorder;
  final EdgeInsets padding;
  final ScrollController scrollController;

  MyReorderableListView({
    Key key,
    this.padding,
    this.scrollController,
    @required this.children,
    @required this.onReorder,
  })  : assert(children != null),
        assert(onReorder != null),
        assert(
          children.every((Widget w) => w.key != null),
          'All children of this widget must have a key.',
        ),
        super(key: key);

  @override
  _ReorderableListViewState createState() => _ReorderableListViewState();
}

class _ReorderableListViewState extends State<MyReorderableListView> {
  final GlobalKey _overlayKey =
      GlobalKey(debugLabel: '$ReorderableListView overlay key');

  OverlayEntry _listOverlayEntry;

  @override
  void initState() {
    super.initState();
    _listOverlayEntry = OverlayEntry(
      opaque: true,
      builder: (BuildContext context) {
        return _ReorderableListContent(
          widget.children,
          widget.onReorder,
          widget.padding,
          widget.scrollController,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => Overlay(
        key: _overlayKey,
        initialEntries: <OverlayEntry>[
          _listOverlayEntry,
        ],
      );
}

class _ReorderableListContent extends StatefulWidget {
  final List<Widget> children;
  final ReorderCallback onReorder;
  final EdgeInsets padding;
  final ScrollController scrollController;

  const _ReorderableListContent(
    this.children,
    this.onReorder,
    this.padding,
    this.scrollController,
  );

  @override
  __ReorderableListContentState createState() =>
      __ReorderableListContentState();
}

class __ReorderableListContentState extends State<_ReorderableListContent>
    with TickerProviderStateMixin<_ReorderableListContent> {
  static const double _defaultDropAreaExtent = 100.0;

  // The additional margin to place around a computed drop area.
  static const double _dropAreaMargin = 8.0;

  // How long an animation to reorder an element in the list takes.
  static const Duration _reorderAnimationDuration = Duration(milliseconds: 200);

  // How long an animation to scroll to an off-screen element in the
  // list takes.
  static const Duration _scrollAnimationDuration = Duration(milliseconds: 200);

  // Controls scrolls and measures scroll progress.
  ScrollController _scrollController;

  // This controls the entrance of the dragging widget into a new place.
  AnimationController _entranceController;

  // This controls the 'ghost' of the dragging widget, which is left behind
  // where the widget used to be.
  AnimationController _ghostController;

  // The member of widget.children currently being dragged.
  //
  // Null if no drag is underway.
  Key _dragging;

  // The last computed size of the feedback widget being dragged.
  Size _draggingFeedbackSize;

  // The location that the dragging widget occupied before it started to drag.
  int _dragStartIndex = 0;

  // The index that the dragging widget most recently left.
  // This is used to show an animation of the widget's position.
  int _ghostIndex = 0;

  // The index that the dragging widget currently occupies.
  int _currentIndex = 0;

  // The widget to move the dragging widget too after the current index.
  int _nextIndex = 0;

  // Whether or not we are currently scrolling this view to show a widget.
  bool _scrolling = false;

  double get _dropAreaExtent {
    if (_draggingFeedbackSize == null) {
      return _defaultDropAreaExtent;
    }

    return _draggingFeedbackSize.height + _dropAreaMargin;
  }

  @override
  void initState() {
    super.initState();
    _entranceController =
        AnimationController(vsync: this, duration: _reorderAnimationDuration);
    _ghostController =
        AnimationController(vsync: this, duration: _reorderAnimationDuration);
    _entranceController.addStatusListener(_onEntranceStatusChanged);
  }

  @override
  void didChangeDependencies() {
    _scrollController = widget.scrollController ??
        PrimaryScrollController.of(context) ??
        ScrollController();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _ghostController.dispose();
    super.dispose();
  }

  // Animates the droppable space from _currentIndex to _nextIndex.
  void _requestAnimationToNextIndex() {
    if (_entranceController.isCompleted) {
      _ghostIndex = _currentIndex;
      if (_nextIndex == _currentIndex) {
        return;
      }
      _currentIndex = _nextIndex;
      _ghostController.reverse(from: 1.0);
      _entranceController.forward(from: 0.0);
    }
  }

  // Requests animation to the latest next index if it changes during an animation.
  void _onEntranceStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _requestAnimationToNextIndex();
      });
    }
  }

  // Scrolls to a target context if that context is not on the screen.
  void _scrollTo(BuildContext context) {
    if (_scrolling) {
      return;
    }
    final contextObject = context.findRenderObject();
    final viewport = RenderAbstractViewport.of(contextObject);
    assert(viewport != null);
    // If and only if the current scroll offset falls in-between the offsets
    // necessary to reveal the selected context at the top or bottom of the
    // screen, then it is already on-screen.
    final margin = _dropAreaExtent;
    final scrollOffset = _scrollController.offset;
    final topOffset = max(
      _scrollController.position.minScrollExtent,
      viewport.getOffsetToReveal(contextObject, 0.0).offset - margin,
    );
    final bottomOffset = min(
      _scrollController.position.maxScrollExtent,
      viewport.getOffsetToReveal(contextObject, 1.0).offset + margin,
    );
    final onScreen = scrollOffset <= topOffset && scrollOffset >= bottomOffset;

    // If the context is off screen, then we request a scroll to make it visible.
    if (!onScreen) {
      _scrolling = true;
      _scrollController.position
          .animateTo(
        scrollOffset < bottomOffset ? bottomOffset : topOffset,
        duration: _scrollAnimationDuration,
        curve: Curves.easeInOut,
      )
          .then((void value) {
        setState(() {
          _scrolling = false;
        });
      });
    }
  }

  // Wraps children in Row or Column, so that the children flow in
  // the widget's scrollDirection.
  Widget _buildContainerForScrollDirection({List<Widget> children}) =>
      Column(children: children);

  // Wraps one of the widget's children in a DragTarget and Draggable.
  // Handles up the logic for dragging and reordering items in the list.
  Widget _wrap(Widget toWrap, int index, BoxConstraints constraints) {
    assert(toWrap.key != null);
    final keyIndexGlobalKey = GlobalObjectKey(toWrap.key);
    // We pass the toWrapWithGlobalKey into the Draggable so that when a list
    // item gets dragged, the accessibility framework can preserve the selected
    // state of the dragging item.

    // Starts dragging toWrap.
    void onDragStarted() {
      setState(() {
        _dragging = toWrap.key;
        _dragStartIndex = index;
        _ghostIndex = index;
        _currentIndex = index;
        _entranceController.value = 1.0;
        _draggingFeedbackSize = keyIndexGlobalKey.currentContext.size;
      });
    }

    // Places the value from startIndex one space before the element at endIndex.
    void reorder(int startIndex, int endIndex) {
      setState(() {
        if (startIndex != endIndex) widget.onReorder(startIndex, endIndex);
        // Animates leftover space in the drop area closed.
        _ghostController.reverse(from: 0.1);
        _entranceController.reverse(from: 0.1);
        _dragging = null;
      });
    }

    // Drops toWrap into the last position it was hovering over.
    void onDragEnded() {
      reorder(_dragStartIndex, _currentIndex);
    }

    Widget wrapWithSemantics() {
      // First, determine which semantics actions apply.
      final semanticsActions = <CustomSemanticsAction, VoidCallback>{};

      // Create the appropriate semantics actions.
      void moveToStart() => reorder(index, 0);
      void moveToEnd() => reorder(index, widget.children.length);
      void moveBefore() => reorder(index, index - 1);
      // To move after, we go to index+2 because we are moving it to the space
      // before index+2, which is after the space at index+1.
      void moveAfter() => reorder(index, index + 2);

      final localizations = MaterialLocalizations.of(context);

      // If the item can move to before its current position in the list.
      if (index > 0) {
        semanticsActions[CustomSemanticsAction(
            label: localizations.reorderItemToStart)] = moveToStart;
        var reorderItemBefore = localizations.reorderItemUp;

        semanticsActions[CustomSemanticsAction(label: reorderItemBefore)] =
            moveBefore;
      }

      // If the item can move to after its current position in the list.
      if (index < widget.children.length - 1) {
        var reorderItemAfter = localizations.reorderItemDown;

        semanticsActions[CustomSemanticsAction(label: reorderItemAfter)] =
            moveAfter;
        semanticsActions[
                CustomSemanticsAction(label: localizations.reorderItemToEnd)] =
            moveToEnd;
      }

      // We pass toWrap with a GlobalKey into the Draggable so that when a list
      // item gets dragged, the accessibility framework can preserve the selected
      // state of the dragging item.
      //
      // We also apply the relevant custom accessibility actions for moving the item
      // up, down, to the start, and to the end of the list.
      return KeyedSubtree(
        key: keyIndexGlobalKey,
        child: MergeSemantics(
          child: Semantics(
            customSemanticsActions: semanticsActions,
            child: toWrap,
          ),
        ),
      );
    }

    Widget buildDragTarget(BuildContext context, List<Key> acceptedCandidates,
        List<dynamic> rejectedCandidates) {
      final toWrapWithSemantics = wrapWithSemantics();

      // We build the draggable inside of a layout builder so that we can
      // constrain the size of the feedback dragging widget.

      // NOTE: allow drag 'n' drop w/o longpress
      //  Widget child = LongPressDraggable<Key>(
      Widget child = Draggable<Key>(
        maxSimultaneousDrags: 1,
        axis: Axis.vertical,
        data: toWrap.key,
        ignoringFeedbackSemantics: false,
        feedback: Container(
          alignment: Alignment.topLeft,
          // These constraints will limit the cross axis of the drawn widget.
          constraints: constraints,
          child: Material(
            elevation: 6.0,
            child: toWrapWithSemantics,
          ),
        ),
        child: _dragging == toWrap.key ? const SizedBox() : toWrapWithSemantics,
        childWhenDragging: const SizedBox(),
        dragAnchor: DragAnchor.child,
        onDragStarted: onDragStarted,
        // When the drag ends inside a DragTarget widget, the drag
        // succeeds, and we reorder the widget into position appropriately.
        onDragCompleted: onDragEnded,
        // When the drag does not end inside a DragTarget widget, the
        // drag fails, but we still reorder the widget to the last position it
        // had been dragged to.
        onDraggableCanceled: (Velocity velocity, Offset offset) {
          onDragEnded();
        },
      );

      // The target for dropping at the end of the list doesn't need to be
      // draggable.
      if (index >= widget.children.length) {
        child = toWrap;
      }

      // Determine the size of the drop area to show under the dragging widget.
      final spacing = SizedBox(height: _dropAreaExtent);

      // We open up a space under where the dragging widget currently is to
      // show it can be dropped.
      if (_currentIndex == index) {
        return _buildContainerForScrollDirection(children: <Widget>[
          SizeTransition(
            sizeFactor: _entranceController,
            axis: Axis.vertical,
            child: spacing,
          ),
          child,
        ]);
      }
      // We close up the space under where the dragging widget previously was
      // with the ghostController animation.
      if (_ghostIndex == index) {
        return _buildContainerForScrollDirection(children: <Widget>[
          SizeTransition(
            sizeFactor: _ghostController,
            axis: Axis.vertical,
            child: spacing,
          ),
          child,
        ]);
      }
      return child;
    }

    // We wrap the drag target in a Builder so that we can scroll to its specific context.
    return Builder(builder: (BuildContext context) {
      return DragTarget<Key>(
        builder: buildDragTarget,
        onWillAccept: (Key toAccept) {
          setState(() {
            _nextIndex = index;
            _requestAnimationToNextIndex();
          });
          _scrollTo(context);
          // If the target is not the original starting point, then we will accept the drop.
          return _dragging == toAccept && toAccept != toWrap.key;
        },
        onAccept: (Key accepted) {},
        onLeave: (Object leaving) {},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    // We use the layout builder to constrain the cross-axis size of dragging child widgets.
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      const endWidgetKey = Key('DraggableList - End Widget');
      final finalDropArea = SizedBox(
        key: endWidgetKey,
        height: _defaultDropAreaExtent,
        width: constraints.maxWidth,
      );

      // If the reorderable list only has one child element, reordering
      // should not be allowed.
      final hasMoreThanOneChildElement = widget.children.length > 1;

      return SingleChildScrollView(
        padding: widget.padding,
        controller: _scrollController,
        child: _buildContainerForScrollDirection(
          children: <Widget>[
            for (int i = 0; i < widget.children.length; i += 1)
              _wrap(widget.children[i], i, constraints),
            if (hasMoreThanOneChildElement)
              _wrap(finalDropArea, widget.children.length, constraints),
          ],
        ),
      );
    });
  }
}
