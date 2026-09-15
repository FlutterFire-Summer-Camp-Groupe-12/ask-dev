import 'package:flutter/material.dart';

/// Logo « ASK DEV » détouré, à utiliser partout dans l'app.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.height = 32});

  static const String asset = 'assets/images/askdev_wordmark.png';

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'AskDev',
    );
  }
}
