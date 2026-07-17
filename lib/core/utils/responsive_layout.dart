import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static const double mobileBreakPoint = 600;
  static const double desktopBreakPoint = 950;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakPoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakPoint &&
      MediaQuery.of(context).size.width < desktopBreakPoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakPoint;

  static int getGridCrossAxisCount(
    BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
  }) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakPoint) return desktop;
    if (width >= mobileBreakPoint) return tablet;
    return mobile;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= desktopBreakPoint) {
          return desktop ?? tablet ?? mobile;
        }
        if (constraints.maxWidth >= mobileBreakPoint) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}
