import '../constants/breakpoints.dart';

enum DeviceType {
  mobile,
  tablet,
  desktop,
  other,
}

abstract final class Responsive {
  static DeviceType getDeviceType(double width) {
    if (width < AppBreakpoints.mobile) {
      return DeviceType.mobile;
    } else if (width < AppBreakpoints.tablet) {
      return DeviceType.tablet;
    } else if (width < AppBreakpoints.desktop) {
      return DeviceType.desktop;
    } else {
      return DeviceType.other;
    }
  }

  static int columnsForWidth(double width) {
    switch (getDeviceType(width)) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
      case DeviceType.other:
        return 4;
    }
  }
  
  static double getHorizontalMargin(double width) {
    switch (getDeviceType(width)) {
      case DeviceType.mobile:
        return 8.0;
      case DeviceType.tablet:
        return 16.0;
      case DeviceType.desktop:
        return 24.0;
      case DeviceType.other:
        return 32.0;
    }  
  }
  static double getVerticalMargin(double width) {
    switch (getDeviceType(width)) {
      case DeviceType.mobile:
        return 8.0;
      case DeviceType.tablet:
        return 16.0;
      case DeviceType.desktop:
        return 24.0;
      case DeviceType.other:
        return 32.0;
    }  
  }

  static double getGridSpacing(double width) {
    return getHorizontalMargin(width);
  }
}
