import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() => runApp(const MyApp());

//List<double> width = List.generate(10, (index) => 200);

List<double> width = [100, 200, 150, 200, 120, 110, 130, 150, 200, 200,100, 200, 150, 200, 120, 110, 130, 150, 200, 200,];

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
      home:  MyHomePage(title: 'Two Dimension Scrollable'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

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
            horizontalDetails: ScrollableDetails.horizontal(controller: _horizontalController),
            verticalDetails: ScrollableDetails.vertical(controller: _verticalController),
            diagonalDragBehavior: DiagonalDragBehavior.free,
            widths: width,
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
                            'Row ${vicinity.yIndex}: Column ${vicinity.xIndex}')),
                  );
                }),
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
  }) : super(delegate: delegate);
  final List<double> widths;
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
    super.cacheExtent,
    super.clipBehavior = Clip.hardEdge,
  });
  final List<double> widths;
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
      widths: width,
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
    super.cacheExtent,
    super.clipBehavior = Clip.hardEdge,
  }) : super(delegate: delegate);

  List<double> rowHeightList = [];
  final List<double> widths;

  @override
  void layoutChildSequence() {
    final double horizontalPixels = horizontalOffset.pixels;
    final double verticalPixels = verticalOffset.pixels;
    final double viewportHeight = viewportDimension.height + cacheExtent;
    final double viewportWidth = viewportDimension.width + cacheExtent;

    final TwoDimensionalChildBuilderDelegate builderDelegate =
    delegate as TwoDimensionalChildBuilderDelegate;
    final int maxRowIndex = builderDelegate.maxYIndex!;
    final int maxColumnIndex = builderDelegate.maxXIndex!;

    final int leadingColumn = _calculateLeadingColumn(horizontalPixels, width);
    final int leadingRow = _calculateLeadingRow(verticalPixels, rowHeightList);
    double remainingHeight = viewportHeight;
    double yLayoutOffset =
    calculateOffset(rowHeightList, leadingRow, verticalOffset.pixels);
    final int trailingColumn = findTrailingColumn(
        horizontalPixels, viewportWidth, width, maxColumnIndex);
    int row = leadingRow;
    while (remainingHeight > 0 && row <= maxRowIndex) {
      double xLayoutOffset =
      calculateOffset(width, leadingColumn, horizontalOffset.pixels);
      List<double> heightList = [];
      List<RenderBox?> childList = List.filled(trailingColumn - leadingColumn + 1, null);
      for (int column = leadingColumn; column <= trailingColumn; column++) {
        final ChildVicinity vicinity =
        ChildVicinity(xIndex: column, yIndex: row);
        final RenderBox child = buildOrObtainChildFor(vicinity)!;
        childList[column - leadingColumn] = child;
        child.layout(constraints.loosen(), parentUsesSize: true);
        heightList.add(child.size.height);
        parentDataOf(child).layoutOffset = Offset(xLayoutOffset, yLayoutOffset);
        xLayoutOffset += width[column];
      }
      double maxHeight = heightList.reduce(max);
      if(heightList.toSet().length > 1){
        for(int i=0;i<childList.length;i++){
          childList[i]?.layout(BoxConstraints.tightFor(height: maxHeight), parentUsesSize: true);
        }
      }
      yLayoutOffset += maxHeight;
      row++;
      remainingHeight -= maxHeight;
      if (row - 1 < rowHeightList.length) {
        rowHeightList[row - 1] = maxHeight;
      } else {
        rowHeightList.add(maxHeight);
      }
    }
    // Set the min and max scroll extents for each axis.
    final double verticalExtent = _sum(rowHeightList);
    verticalOffset.applyContentDimensions(
      0.0,
      clampDouble(
        verticalExtent - viewportDimension.height,
        0.0,
        double.infinity,
      ),
    );
    final double horizontalExtent = _sum(width);
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

  double calculateOffset(List<double> widths, int index, double scrollOffset) {
    double offset = 0;
    for (int i = 0; i < index; i++) {
      offset += widths[i];
    }
    offset -= scrollOffset;
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
