import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

/// Tolérance pour les captures golden, en fraction de pixels (0.01 = 1 %).
/// L'anti-aliasing des polices varie d'une machine à l'autre ; au-delà, on
/// retombe sur le comportement par défaut (échec + fichiers de comparaison).
const double _toleranceFraction = 0.01;

class _TolerantFileComparator extends LocalFileComparator {
  _TolerantFileComparator(super.testFile);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final goldenBytes = await getGoldenBytes(golden);
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      goldenBytes,
    );
    if (result.diffPercent <= _toleranceFraction) {
      return true;
    }
    return super.compare(imageBytes, golden);
  }
}

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final testFile = Uri.file(
    '${Directory.current.path}/test/golden/ui_catalog_golden_test.dart',
  );
  goldenFileComparator = _TolerantFileComparator(testFile);
  await testMain();
}