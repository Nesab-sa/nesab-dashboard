import 'dart:ui' show ImageByteFormat;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:nesab_dashboard/core/theme/app_colors.dart';

/// Export buttons matching HTML `.export-btns`.
/// Uses RepaintBoundary to capture the result widget as PNG.
class CalculatorExportButtons extends StatelessWidget {
  const CalculatorExportButtons({
    super.key,
    required this.repaintKey,
  });

  /// The GlobalKey attached to the RepaintBoundary wrapping the result area.
  final GlobalKey repaintKey;

  Future<void> _exportPng(BuildContext context) async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData == null) return;

      // On web, trigger download via blob URL
      // TODO: implement platform-specific save/share
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _exportPng(context),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red[600]!, Colors.red[700]!],
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Text(
                  'PDF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => _exportPng(context),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[600]!, Colors.blue[400]!],
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Text(
                  'صورة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
