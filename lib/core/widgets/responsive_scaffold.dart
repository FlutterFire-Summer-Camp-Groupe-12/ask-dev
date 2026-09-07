import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;
  final Widget other;

  const ResponsiveScaffold({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
    required this.other,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final deviceType = Responsive.getDeviceType(width);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
      case DeviceType.other:
        return other;

    }
  }
}

