import 'package:flutter/material.dart';
import 'package:flutter_restaurant/common/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ColorResources {
  static Color getSearchBg(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? Colors.black
        : Colors.white;
  }

  static Color getBackgroundColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? Colors.black
        : Colors.white;
  }

  static Color getHintColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? Colors.black54
        : Colors.grey;
  }

  static Color getGreyBunkerColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? Colors.black87
        : Colors.grey.shade700;
  }

  static Color getCartTitleColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? const Color(0xFF61699b)
        : const Color.fromARGB(
            255, 126, 3, 3); // Deep Red color for light theme
  }

  static Color getProfileMenuHeaderColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? footerColor.withOpacity(0.5)
        : footerColor.withOpacity(0.8); // Adjust to your preference
  }

  static Color getFooterColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? const Color(0xFF494949)
        : const Color.fromARGB(
            255, 130, 4, 4); // Deep Red color for light theme
  }

  static Color getSecondaryColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? const Color(0xFFFFBA08)
        : const Color(0xFFFFBA08);
  }

  static Color getTertiaryColor(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme
        ? const Color(0xFF2B2727)
        : const Color(0xFFF3F8FF);
  }

  static const Color colorNero = Color(0xFF1F1F1F);
  static const Color searchBg = Colors.white;
  static const Color borderColor = Colors.grey;
  static const Color footerColor =
      Color.fromARGB(255, 126, 2, 2); // Deep Red color
  static const Color cardShadowColor = Colors.grey;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color onBoardingBgColor = Color(0xffFCE4E0);
  static const Color homePageSectionTitleColor = Color(0xff583A3A);
  static const Color splashBackgroundColor = Color(0xFFfebb19);

  static const Map<String, Color> buttonBackgroundColorMap = {
    'pending': Colors.black,
    'confirmed': Colors.white,
    'processing': Colors.black54,
    'cooking': Colors.black54,
    'out_for_delivery': Colors.grey,
    'delivered': Colors.white,
    'canceled': Colors.black,
    'returned': Colors.black,
    'failed': Colors.black,
    'completed': Colors.white,
  };

  static const Map<String, Color> buttonTextColorMap = {
    'pending': Color(0xff5686c6),
    'confirmed': Color(0xff72b89f),
    'processing': Color(0xff2b9ff4),
    'cooking': Color(0xff2b9ff4),
    'out_for_delivery': Color(0xffebb936),
    'delivered': Color(0xff72b89f),
    'canceled': Color(0xffff6060),
    'returned': Color(0xffff6060),
    'failed': Color(0xffff6060),
    'completed': Color(0xff72b89f),
  };
}
