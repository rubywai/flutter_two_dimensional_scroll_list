import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

//List<double> width = List.generate(10, (index) => 200);

List<double> width = [
  100,
  200,
  150,
  200,
  120,
  110,
  130,
  150,
  200,
  200,
  100,
  200,
  150,
  200,
  120,
  110,
  130,
  150,
  200,
  200,
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: PointerDeviceKind.values.toSet(),
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Two Dimension Scrollable'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  ChildVicinity? child;
  PointerEvent? event;

  MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Scrollbar(
        trackVisibility: true,
        thumbVisibility: true,
        controller: _horizontalController,
        child: Scrollbar(
          controller: _verticalController,
          trackVisibility: true,
          thumbVisibility: true,
          child: TwoDimensionalGridView(
            horizontalDetails:
                ScrollableDetails.horizontal(controller: _horizontalController),
            verticalDetails:
                ScrollableDetails.vertical(controller: _verticalController),
            diagonalDragBehavior: DiagonalDragBehavior.free,
            widths: width,
            pinColumnCount: 2,
            tableGroupHeader: const {0: "header", 5: "header"},
            onMouseExit: (child) {
              // print('on mouse exit $child');
            },
            onEvent: (child, event) {
              print('event $event');
            },
            delegate: TwoDimensionalChildBuilderDelegate(
              maxXIndex: 19,
              maxYIndex: 19,
              builder: (BuildContext context, ChildVicinity vicinity) {
                return Container(
                  color: vicinity.xIndex.isEven && vicinity.yIndex.isEven
                      ? Colors.green[50]
                      : (vicinity.xIndex.isOdd && vicinity.yIndex.isOdd
                          ? Colors.red[50]
                          : Colors.indigo),
                  height: vicinity.xIndex.isEven
                      ? width[vicinity.yIndex]
                      : width[vicinity.yIndex] + 50,
                  width: width[vicinity.xIndex],
                  child: Center(
                    child: Text(
                        'Row ${vicinity.yIndex}: Column ${vicinity.xIndex}'),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class TwoDimensionalGridView extends TwoDimensionalScrollView {
  const TwoDimensionalGridView({
    super.key,
    super.primary,
    super.mainAxis = Axis.vertical,
    super.verticalDetails = const ScrollableDetails.vertical(),
    super.horizontalDetails = const ScrollableDetails.horizontal(),
    required TwoDimensionalChildBuilderDelegate delegate,
    super.cacheExtent,
    super.diagonalDragBehavior = DiagonalDragBehavior.none,
    super.dragStartBehavior = DragStartBehavior.start,
    super.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    super.clipBehavior = Clip.hardEdge,
    required this.widths,
    required this.pinColumnCount,
    required this.tableGroupHeader,
    required this.onEvent,
    required this.onMouseExit,
  }) : super(delegate: delegate);
  final List<double> widths;
  final int pinColumnCount;
  final Map<int, String?> tableGroupHeader;
  final Function(ChildVicinity, PointerEvent) onEvent;
  final Function(ChildVicinity) onMouseExit;

  @override
  Widget buildViewport(
    BuildContext context,
    ViewportOffset verticalOffset,
    ViewportOffset horizontalOffset,
  ) {
    return TwoDimensionalGridViewport(
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalDetails.direction,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalDetails.direction,
      mainAxis: mainAxis,
      delegate: delegate as TwoDimensionalChildBuilderDelegate,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
      widths: widths,
      pinColumnCount: pinColumnCount,
      tableGroupHeader: tableGroupHeader,
      onEvent: onEvent,
      onMouseExit: onMouseExit,
    );
  }
}

class TwoDimensionalGridViewport extends TwoDimensionalViewport {
  const TwoDimensionalGridViewport({
    super.key,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required TwoDimensionalChildBuilderDelegate super.delegate,
    required super.mainAxis,
    required this.widths,
    required this.pinColumnCount,
    super.cacheExtent,
    required this.tableGroupHeader,
    super.clipBehavior = Clip.hardEdge,
    required this.onEvent,
    required this.onMouseExit,
  });

  final List<double> widths;
  final int pinColumnCount;
  final Map<int, String?> tableGroupHeader;
  final Function(ChildVicinity, PointerEvent) onEvent;
  final Function(ChildVicinity) onMouseExit;

  @override
  RenderTwoDimensionalViewport createRenderObject(BuildContext context) {
    return RenderTwoDimensionalGridViewport(
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalAxisDirection,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalAxisDirection,
      mainAxis: mainAxis,
      delegate: delegate as TwoDimensionalChildBuilderDelegate,
      childManager: context as TwoDimensionalChildManager,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
      tableGroupHeader: tableGroupHeader,
      widths: width,
      pinColumnCount: pinColumnCount,
      onEvent: onEvent,
      onMouseExit: onMouseExit,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderTwoDimensionalGridViewport renderObject,
  ) {
    renderObject
      ..horizontalOffset = horizontalOffset
      ..horizontalAxisDirection = horizontalAxisDirection
      ..verticalOffset = verticalOffset
      ..verticalAxisDirection = verticalAxisDirection
      ..mainAxis = mainAxis
      ..delegate = delegate
      ..cacheExtent = cacheExtent
      ..clipBehavior = clipBehavior;
  }
}

class RenderTwoDimensionalGridViewport extends RenderTwoDimensionalViewport {
  RenderTwoDimensionalGridViewport({
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required TwoDimensionalChildBuilderDelegate delegate,
    required super.mainAxis,
    required super.childManager,
    required this.widths,
    required this.pinColumnCount,
    required this.tableGroupHeader,
    super.cacheExtent,
    super.clipBehavior = Clip.hardEdge,
    required this.onEvent,
    required this.onMouseExit,
  }) : super(delegate: delegate);

  List<double> rowHeightList = [];
  final Map<int, String?> tableGroupHeader;
  List<double> widths;
  ChildVicinity? lastNonPin;
  ChildVicinity? firstNonPin;
  ChildVicinity? firstPin;
  ChildVicinity? lastPin;
  final int pinColumnCount;
  double pinColumnWidth = 0;
  List<TableGroupHeaderModel> tableGroupList = [];
  final Function(ChildVicinity, PointerEvent) onEvent;
  final Function(ChildVicinity) onMouseExit;

  @override
  void layoutChildSequence() {
    tableGroupList.clear();
    final double horizontalPixels = horizontalOffset.pixels;
    final double verticalPixels = verticalOffset.pixels;
    final double viewportHeight = viewportDimension.height + cacheExtent;
    final double viewportWidth = viewportDimension.width + cacheExtent;

    final TwoDimensionalChildBuilderDelegate builderDelegate =
        delegate as TwoDimensionalChildBuilderDelegate;
    final int maxRowIndex = builderDelegate.maxYIndex!;
    final int maxColumnIndex = builderDelegate.maxXIndex!;
    final double horizontalExtent = _sum(width);

    final int leadingColumn = _calculateLeadingColumn(horizontalPixels, width);
    final int leadingRow = _calculateLeadingRow(verticalPixels, rowHeightList);
    double remainingHeight = viewportHeight;
    double yLayoutOffset =
        calculateOffset(rowHeightList, leadingRow, verticalOffset.pixels);
    final int trailingColumn = findTrailingColumn(
        horizontalPixels, viewportWidth, width, maxColumnIndex);
    int row = leadingRow;
    while (remainingHeight > 0 && row <= maxRowIndex) {
      double xLayoutOffset = calculateOffset(
        width,
        leadingColumn,
        horizontalOffset.pixels,
      );
      //record height list to equal the height
      List<double> heightList = [];
      //child list to redefine the height
      List<RenderBox?> childList =
          List.filled(trailingColumn - leadingColumn + 1, null);
      //to check it is tale header or not
      bool isTableGroupHeaders = tableGroupHeader[row] != null;
      double pinXOffset = 0;

      for (int column = leadingColumn; column <= trailingColumn; column++) {
        final ChildVicinity vicinity =
            ChildVicinity(xIndex: column, yIndex: row);
        final RenderBox child = buildOrObtainChildFor(vicinity)!;
        childList[column - leadingColumn] = child;
        child.layout(constraints.loosen(), parentUsesSize: true);
        heightList.add(child.size.height);
        if (column < pinColumnCount) {
          double pinXLayoutOffset = _sum(widths.sublist(0, column));
          parentDataOf(child).layoutOffset = Offset(
            pinXLayoutOffset,
            yLayoutOffset,
          );
        } else {
          parentDataOf(child).layoutOffset =
              Offset(xLayoutOffset, yLayoutOffset);
        }
        xLayoutOffset += width[column];
      }
      double maxHeight = heightList.reduce(max);

      //pin row render
      for (int j = 0; (j < leadingColumn && j < pinColumnCount); j++) {
        final ChildVicinity vicinity = ChildVicinity(xIndex: j, yIndex: row);
        final RenderBox child = buildOrObtainChildFor(vicinity)!;
        child.layout(constraints.loosen(), parentUsesSize: true);
        if (child.size.height < maxHeight) {
          child.layout(BoxConstraints.tightFor(height: maxHeight),
              parentUsesSize: true);
        } else {
          maxHeight = child.size.height;
        }
        heightList.add(maxHeight);
        parentDataOf(child).layoutOffset = Offset(pinXOffset, yLayoutOffset);
        pinXOffset += widths[j];
      }

      //for equal height
      if (heightList.toSet().length > 1) {
        for (int i = 0; i < childList.length; i++) {
          childList[i]?.layout(BoxConstraints.tightFor(height: maxHeight),
              parentUsesSize: true);
        }
      }
      //header
      if (isTableGroupHeaders) {
        RenderBox firstChild;
        if (leadingColumn > 0 && pinColumnCount > 0) {
          final ChildVicinity vicinity = ChildVicinity(xIndex: 0, yIndex: row);
          firstChild = getChildFor(vicinity)!;
        } else {
          firstChild = childList.first!;
        }
        firstChild.layout(
            BoxConstraints.tightFor(
              height: maxHeight,
              width: viewportWidth,
            ),
            parentUsesSize: true);
        parentDataOf(firstChild).layoutOffset = Offset(0, yLayoutOffset);
        tableGroupList.add(
          TableGroupHeaderModel(
            x: 0,
            y: yLayoutOffset,
            row: row,
            height: maxHeight,
            width: viewportWidth,
          ),
        );
      }
      //increase height
      yLayoutOffset += maxHeight;
      row++;
      remainingHeight -= maxHeight;

      //set up for equal height
      if (row - 1 < rowHeightList.length) {
        rowHeightList[row - 1] = maxHeight;
      } else {
        rowHeightList.add(maxHeight);
      }
      pinColumnWidth = xLayoutOffset;
    }

    //re-render for pin column

    //define the first Non-pin and last non-pin
    firstNonPin = ChildVicinity(
      xIndex: leadingColumn < pinColumnCount ? pinColumnCount : leadingColumn,
      yIndex: leadingRow,
    );
    lastNonPin = ChildVicinity(
      xIndex: trailingColumn,
      yIndex: row,
    );

    firstPin = ChildVicinity(
      xIndex: 0,
      yIndex: leadingRow,
    );
    lastPin = ChildVicinity(
      xIndex: pinColumnCount - 1,
      yIndex: row,
    );
    // Set the min and max scroll extents for each axis.
    final double verticalExtent = _sum(rowHeightList);

    //set up vertical offset
    verticalOffset.applyContentDimensions(
      0.0,
      clampDouble(
        verticalExtent - viewportDimension.height,
        0.0,
        double.infinity,
      ),
    );
    //set up horizontal offset
    horizontalOffset.applyContentDimensions(
      0.0,
      clampDouble(
        horizontalExtent - viewportDimension.width,
        0.0,
        double.infinity,
      ),
    );
  }

  int _calculateLeadingColumn(double pixels, List<double> widths) {
    int leadingColumn = 0;
    double currentWidth = 0;

    while (currentWidth + widths[leadingColumn] < pixels &&
        leadingColumn < widths.length) {
      currentWidth += widths[leadingColumn];
      leadingColumn++;
    }

    return leadingColumn;
  }

  final LayerHandle<ClipRectLayer> _clipCellsHandle =
      LayerHandle<ClipRectLayer>();
  final LayerHandle<ClipRectLayer> _clipPinnedColumnsHandle =
      LayerHandle<ClipRectLayer>();

  @override
  void paint(PaintingContext context, Offset offset) {
    bool isTablePin = pinColumnCount > 0;
    double pinColumnWidth = _sum(widths.sublist(0, pinColumnCount));
    double pinRowExtend = 0;
    if (!isTablePin) {
      super.paint(context, offset);
    }
    if (isTablePin) {
      _clipPinnedColumnsHandle.layer = context.pushClipRect(
        needsCompositing,
        offset,
        Rect.fromLTWH(
          axisDirectionIsReversed(horizontalAxisDirection)
              ? viewportDimension.width - pinColumnWidth
              : 0.0,
          axisDirectionIsReversed(verticalAxisDirection) ? 0.0 : 0,
          pinColumnWidth,
          viewportDimension.height - 0,
        ),
        (PaintingContext context, Offset offset) {
          _paintCells(
            context: context,
            offset: offset,
            leading: firstPin!,
            trailing: lastPin!,
          );
        },
        clipBehavior: clipBehavior,
        oldLayer: _clipPinnedColumnsHandle.layer,
      );
    } else {
      _clipPinnedColumnsHandle.layer = null;
    }
    if (isTablePin) {
      _clipCellsHandle.layer = context.pushClipRect(
        needsCompositing,
        offset,
        Rect.fromLTWH(
          pinColumnWidth,
          pinRowExtend,
          viewportDimension.width - pinColumnWidth,
          viewportDimension.height - pinRowExtend,
        ),
        (PaintingContext context, Offset offset) {
          _paintCells(
            context: context,
            offset: offset,
            leading: firstNonPin!,
            trailing: lastNonPin!,
          );
        },
        clipBehavior: clipBehavior,
        oldLayer: _clipCellsHandle.layer,
      );
    } else {
      _clipCellsHandle.layer = null;
    }
    List groupHeaderHandleList = List.generate(
      tableGroupList.length,
      (_) => LayerHandle<ClipRectLayer>(),
    );
    for (int i = 0; i < tableGroupList.length; i++) {
      final header = tableGroupList[i];
      final layerHandle = LayerHandle<ClipRectLayer>();
      layerHandle.layer = context.pushClipRect(
        needsCompositing,
        offset,
        Rect.fromLTWH(
          header.x,
          header.y,
          header.width,
          header.height,
        ),
        (PaintingContext context, Offset offset) {
          _paintCells(
            context: context,
            offset: offset,
            leading: ChildVicinity(xIndex: 0, yIndex: header.row),
            trailing: ChildVicinity(xIndex: 0, yIndex: header.row + 1),
          );
        },
        clipBehavior: clipBehavior,
        oldLayer: groupHeaderHandleList[i].layer,
      );
      groupHeaderHandleList.add(layerHandle);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderBox? cell = firstChild;
    while (cell != null) {
      final cellParentData = parentDataOf(cell);
      if (!cellParentData.isVisible) {
        cell = childAfter(cell);
        continue;
      }
      final Rect cellRect = cellParentData.paintOffset! & cell.size;
      if (cellRect.contains(position)) {
        result.addWithPaintOffset(
          offset: cellParentData.paintOffset,
          position: position,
          hitTest: (BoxHitTestResult result, Offset transformed) {
            assert(transformed == position - cellParentData.paintOffset!);
            return cell!.hitTest(result, position: transformed);
          },
        );
        final span = _Span(
          column: cellParentData.vicinity.xIndex,
          row: cellParentData.vicinity.yIndex,
          onEvent: onEvent,
          onMouseExit: onMouseExit,
          recognizerFactories: <Type, GestureRecognizerFactory>{
            TapGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
              () => TapGestureRecognizer(),
              (TapGestureRecognizer t) {
                t.onTapDown = (_) => print('Tap row down');
                t.onTapUp = (_) => print('Tap row up');
              },
            ),
          },
        );
        result.add(HitTestEntry(span));
        return true;
      }
      cell = childAfter(cell);
    }
    return false;
  }

  void _paintCells({
    required PaintingContext context,
    required ChildVicinity leading,
    required ChildVicinity trailing,
    required Offset offset,
  }) {
    for (int column = leading.xIndex; column <= trailing.xIndex; column++) {
      for (int row = leading.yIndex; row <= trailing.yIndex - 1; row++) {
        final RenderBox cell = getChildFor(
          ChildVicinity(xIndex: column, yIndex: row),
        )!;
        final cellParentData = parentDataOf(cell);
        if (cellParentData.isVisible) {
          context.paintChild(cell, offset + cellParentData.paintOffset!);
        }
      }
    }
  }

  int _calculateLeadingRow(double pixels, List<double> heights) {
    int leadingRow = 0;
    double currentHeight = 0;
    if (rowHeightList.isEmpty) {
      return leadingRow;
    }
    while (currentHeight + heights[leadingRow] < pixels &&
        leadingRow < heights.length) {
      currentHeight += heights[leadingRow];
      leadingRow++;
    }

    return leadingRow;
  }

  double calculateOffset(List<double> widths, int index, double scrollOffset,
      {bool isPin = false}) {
    double offset = 0;
    for (int i = 0; i < index; i++) {
      offset += widths[i];
    }
    if (!isPin) {
      offset -= scrollOffset;
    }
    return offset;
  }

  int findTrailingColumn(double horizontalPixels, double viewportWidth,
      List<double> widths, int maxColumnIndex) {
    double totalWidth = 0.0;
    int index = 0;

    while (totalWidth < horizontalPixels + viewportWidth &&
        index <= maxColumnIndex &&
        index < widths.length) {
      totalWidth += widths[index];
      index++;
    }

    return math.min(index - 1, maxColumnIndex);
  }

  double _sum(List<double> numList) {
    var result = 0.0;
    for (var value in numList) {
      result += value;
    }
    return result;
  }
}

class TableGroupHeaderModel {
  final double x;
  final double y;
  final int row;
  final double height;
  final double width;

  TableGroupHeaderModel({
    required this.x,
    required this.y,
    required this.row,
    required this.height,
    required this.width,
  });
}

class _Span
    with Diagnosticable
    implements HitTestTarget, MouseTrackerAnnotation {
  final int row;
  final int column;

  _Span({
    required this.column,
    required this.row,
    required this.onEvent,
    required this.onMouseExit,
    required this.recognizerFactories,
  });

  final Function(ChildVicinity childVicinity, PointerEvent event) onEvent;
  final Function(ChildVicinity) onMouseExit;
  final Map<Type, GestureRecognizerFactory> recognizerFactories;

  Map<Type, GestureRecognizer>? _recognizers;

  void _syncRecognizers() {
    if (recognizerFactories.isEmpty) {
      _disposeRecognizers();
      return;
    }
    final Map<Type, GestureRecognizer> newRecognizers =
        <Type, GestureRecognizer>{};
    for (final Type type in recognizerFactories.keys) {
      assert(!newRecognizers.containsKey(type));
      newRecognizers[type] = _recognizers?.remove(type) ??
          recognizerFactories[type]!.constructor();
      assert(
        newRecognizers[type].runtimeType == type,
        'GestureRecognizerFactory of type $type created a GestureRecognizer of '
        'type ${newRecognizers[type].runtimeType}. The '
        'GestureRecognizerFactory must be specialized with the type of the '
        'class that it returns from its constructor method.',
      );
      recognizerFactories[type]!.initializer(newRecognizers[type]!);
    }
    _disposeRecognizers();
    _recognizers = newRecognizers;
  }

  void _disposeRecognizers() {
    if (_recognizers != null) {
      for (final GestureRecognizer recognizer in _recognizers!.values) {
        recognizer.dispose();
      }
      _recognizers = null;
    }
  }

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    if (event is PointerDownEvent && recognizerFactories.isNotEmpty) {
      if (_recognizers == null) {
        _syncRecognizers();
      }
      assert(_recognizers != null);
      for (final GestureRecognizer recognizer in _recognizers!.values) {
        recognizer.addPointer(event);
      }
    }
  }

  @override
  MouseCursor get cursor => MouseCursor.defer;

  @override
  PointerEnterEventListener? get onEnter => (enterEvent) {
        onEvent(
          ChildVicinity(xIndex: column, yIndex: row),
          enterEvent,
        );
      };

  @override
  PointerExitEventListener? get onExit => (_) {
        onMouseExit(
          ChildVicinity(
            xIndex: column,
            yIndex: row,
          ),
        );
      };

  @override
  bool get validForMouseTracker => true;
}
