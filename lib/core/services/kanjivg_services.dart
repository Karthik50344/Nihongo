import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:path_parsing/path_parsing.dart';

/// Clean KanjiVG service using proper path parsing
class KanjiVGService {
  static final KanjiVGService _instance = KanjiVGService._internal();
  factory KanjiVGService() => _instance;
  KanjiVGService._internal();

  /// Load stroke paths from KanjiVG SVG file
  Future<List<Path>> loadStrokePaths(String character, String path) async {
    try {
      // Get Unicode hex
      final unicode = character.codeUnitAt(0).toRadixString(16).padLeft(5, '0');
      final assetPath = 'assets/kanjivg/$path/$unicode.svg';

      debugPrint('Loading KanjiVG: $assetPath for character: $character');

      // Load SVG file
      final svgString = await rootBundle.loadString(assetPath);

      // Parse XML
      final document = XmlDocument.parse(svgString);

      // Find all path elements with stroke IDs
      final paths = <Path>[];
      final pathElements = document.findAllElements('path');

      for (final pathElement in pathElements) {
        final id = pathElement.getAttribute('id') ?? '';
        final d = pathElement.getAttribute('d') ?? '';

        // Only get stroke paths (contains '-s' in ID)
        if (id.contains('-s') && d.isNotEmpty) {
          try {
            // Parse SVG path to Flutter Path
            final path = _parseSvgPath(d);
            if (path != null) {
              paths.add(path);
              debugPrint('Loaded stroke ${paths.length}: ID=$id');
            }
          } catch (e) {
            debugPrint('Error parsing path $id: $e');
          }
        }
      }

      debugPrint('Total strokes loaded: ${paths.length}');
      return paths;

    } catch (e) {
      debugPrint('Error loading KanjiVG for $character: $e');
      return [];
    }
  }

  /// Parse SVG path string to Flutter Path using path_parsing
  Path? _parseSvgPath(String svgPathData) {
    try {
      final path = Path();

      // Use writeSvgPathDataToPath to convert SVG to Flutter Path
      writeSvgPathDataToPath(svgPathData, FlutterPathProxy(path));

      return path;
    } catch (e) {
      debugPrint('Error parsing SVG path: $e');
      return null;
    }
  }

  /// Get bounding box for proper scaling
  Rect getPathBounds(List<Path> paths) {
    if (paths.isEmpty) return Rect.zero;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final path in paths) {
      final bounds = path.getBounds();
      if (bounds.left < minX) minX = bounds.left;
      if (bounds.top < minY) minY = bounds.top;
      if (bounds.right > maxX) maxX = bounds.right;
      if (bounds.bottom > maxY) maxY = bounds.bottom;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}

/// Path proxy to convert SVG commands to Flutter Path
class FlutterPathProxy extends PathProxy {
  final Path path;

  FlutterPathProxy(this.path);

  @override
  void close() {
    path.close();
  }

  @override
  void cubicTo(
      double x1, double y1,
      double x2, double y2,
      double x3, double y3,
      ) {
    path.cubicTo(x1, y1, x2, y2, x3, y3);
  }

  @override
  void lineTo(double x, double y) {
    path.lineTo(x, y);
  }

  @override
  void moveTo(double x, double y) {
    path.moveTo(x, y);
  }
}