import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ResponsiveLayout {
  const ResponsiveLayout._();

  /// Returns the width available to page content.
  ///
  /// Individual screens own their inner padding, so this must not subtract a
  /// second set of gutters on tablets, foldables, or desktop-sized windows.
  static double contentMaxWidth(double width) => width;

  static bool isCompactLandscape(double width, double height) =>
      width > height && height < 600;

  static ui.DisplayFeature? verticalHinge(BuildContext context) {
    final displaySize = MediaQuery.sizeOf(context);

    for (final feature in MediaQuery.displayFeaturesOf(context)) {
      final bounds = feature.bounds;
      final spansDisplayHeight = bounds.height >= displaySize.height * 0.8;
      final isVertical = bounds.height > bounds.width;
      final hasHinge =
          bounds.shortestSide > 0 ||
          feature.state == ui.DisplayFeatureState.postureHalfOpened;

      if (spansDisplayHeight && isVertical && hasHinge) return feature;
    }

    return null;
  }

  static int columnsForWidth(
    double width, {
    ui.DisplayFeature? hinge,
    double threeColumnMinWidth = 1000,
    double twoColumnMinWidth = 600,
  }) {
    if (hinge != null) return 2;
    if (width >= threeColumnMinWidth) return 3;
    if (width >= twoColumnMinWidth) return 2;
    return 1;
  }

  static double spacingFor(BuildContext context, {double minimum = 16}) {
    final hinge = verticalHinge(context);
    if (hinge == null) return minimum;
    return math.max(minimum, hinge.bounds.width + 16);
  }
}

class ResponsiveCardGrid extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double maxWidth;
  final double cardHeight;
  final double? maxCardHeight;
  final double spacing;
  final double threeColumnMinWidth;
  final double twoColumnMinWidth;
  final int maxColumns;

  const ResponsiveCardGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.maxWidth = double.infinity,
    this.cardHeight = 178,
    this.maxCardHeight,
    this.spacing = 16,
    this.threeColumnMinWidth = 1000,
    this.twoColumnMinWidth = 600,
    this.maxColumns = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final hinge = ResponsiveLayout.verticalHinge(context);
            final screenSize = MediaQuery.sizeOf(context);
            final suggestedColumns = ResponsiveLayout.columnsForWidth(
              constraints.maxWidth,
              hinge: hinge,
              threeColumnMinWidth: threeColumnMinWidth,
              twoColumnMinWidth: twoColumnMinWidth,
            );
            final columns = math.min(maxColumns, suggestedColumns);
            final horizontalSpacing = hinge == null
                ? spacing
                : math.max(spacing, hinge.bounds.width + 16);
            final compactLandscape = ResponsiveLayout.isCompactLandscape(
              screenSize.width,
              screenSize.height,
            );
            final heightFactor = compactLandscape
                ? 0.32
                : columns == 1
                ? 0.24
                : 0.29;
            final targetCardHeight = screenSize.height * heightFactor;
            final maximumCardHeight = maxCardHeight ??
                (compactLandscape ? 178.0 : 340.0);
            final adaptiveCardHeight = maxCardHeight != null
                ? targetCardHeight.clamp(cardHeight, maximumCardHeight)
                : compactLandscape
                ? targetCardHeight.clamp(150.0, maximumCardHeight)
                : targetCardHeight.clamp(cardHeight, maximumCardHeight);
            Widget buildItem(int index) => SizedBox(
              height: adaptiveCardHeight.toDouble(),
              child: itemBuilder(context, index),
            );
            final rows = <Widget>[];

            for (var first = 0; first < itemCount; first += columns) {
              if (first > 0) rows.add(SizedBox(height: spacing));

              final remaining = itemCount - first;
              final count = math.min(columns, remaining);

              if (count == 1) {
                if (columns == 1) {
                  rows.add(buildItem(first));
                } else {
                  rows.add(
                    Row(
                      children: [
                        Spacer(flex: columns - 1),
                        Expanded(flex: 2, child: buildItem(first)),
                        Spacer(flex: columns - 1),
                      ],
                    ),
                  );
                }
                continue;
              }

              if (columns == 3 && count == 2) {
                rows.add(
                  Row(
                    children: [
                      const Spacer(flex: 1),
                      Expanded(flex: 2, child: buildItem(first)),
                      SizedBox(width: horizontalSpacing),
                      Expanded(flex: 2, child: buildItem(first + 1)),
                      const Spacer(flex: 1),
                    ],
                  ),
                );
                continue;
              }

              rows.add(
                Row(
                  children: [
                    for (var offset = 0; offset < count; offset++) ...[
                      if (offset > 0) SizedBox(width: horizontalSpacing),
                      Expanded(child: buildItem(first + offset)),
                    ],
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rows,
            );
          },
        ),
      ),
    );
  }
}
