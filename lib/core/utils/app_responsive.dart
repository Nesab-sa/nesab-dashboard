import 'package:flutter/material.dart';

enum DeviceType {
  mobilePortrait,
  mobileLandscape,
  tabletPortrait,
  tabletLandscape,
  other,
}

class AppResponsive {
  const AppResponsive._();

  static DeviceType getDeviceType(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;
    final longestSide = size.longestSide;
    final orientation = MediaQuery.of(context).orientation;

    if (shortestSide < 600) {
      return orientation == Orientation.portrait
          ? DeviceType.mobilePortrait
          : DeviceType.mobileLandscape;
    } else if (shortestSide < 900) {
      return orientation == Orientation.portrait
          ? DeviceType.tabletPortrait
          : DeviceType.tabletLandscape;
    } else {
      return DeviceType.other;
    }
  }

  static bool isMobilePortrait(BuildContext context) =>
      getDeviceType(context) == DeviceType.mobilePortrait;

  static bool isMobileLandscape(BuildContext context) =>
      getDeviceType(context) == DeviceType.mobileLandscape;

  static bool isTabletPortrait(BuildContext context) =>
      getDeviceType(context) == DeviceType.tabletPortrait;

  static bool isTabletLandscape(BuildContext context) =>
      getDeviceType(context) == DeviceType.tabletLandscape;

  static bool isMobile(BuildContext context) {
    final type = getDeviceType(context);
    return type == DeviceType.mobilePortrait ||
        type == DeviceType.mobileLandscape;
  }

  static int numberOfGrid(BuildContext context) {
    if (isMobilePortrait(context)) {
      return 2;
    } else if (isMobileLandscape(context) || isTabletPortrait(context)) {
      return 3;
    } else {
      return 4;
    }
  }

  static bool isTablet(BuildContext context) {
    final type = getDeviceType(context);
    return type == DeviceType.tabletPortrait ||
        type == DeviceType.tabletLandscape;
  }

  static bool isLandscape(BuildContext context) {
    final type = getDeviceType(context);
    return type == DeviceType.mobileLandscape ||
        type == DeviceType.tabletLandscape;
  }

  static bool isPortrait(BuildContext context) {
    final type = getDeviceType(context);
    return type == DeviceType.mobilePortrait ||
        type == DeviceType.tabletPortrait;
  }

  static Size screenSize(BuildContext context) => MediaQuery.of(context).size;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double shortestSide(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide;

  static double longestSide(BuildContext context) =>
      MediaQuery.of(context).size.longestSide;

  static double fontSize(BuildContext context, double baseFontSize) {
    final type = getDeviceType(context);
    switch (type) {
      case DeviceType.mobilePortrait:
        return baseFontSize;
      case DeviceType.mobileLandscape:
        return baseFontSize * 0.9;
      case DeviceType.tabletPortrait:
        return baseFontSize * 1.2;
      case DeviceType.tabletLandscape:
        return baseFontSize * 1.15;
      case DeviceType.other:
        return baseFontSize * 1.3;
    }
  }

  static double fontSizeSmall(BuildContext context) => fontSize(context, 12);

  static double fontSizeBody(BuildContext context) => fontSize(context, 14);

  static double fontSizeMedium(BuildContext context) => fontSize(context, 16);

  static double fontSizeLarge(BuildContext context) => fontSize(context, 18);

  static double fontSizeXLarge(BuildContext context) => fontSize(context, 20);

  static double fontSizeXXLarge(BuildContext context) => fontSize(context, 24);

  static double fontSizeHeading(BuildContext context) => fontSize(context, 28);
}
