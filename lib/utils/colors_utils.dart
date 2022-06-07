import 'package:flutter/material.dart';

hexStringToColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  return Color(int.parse(hexColor, radix: 16));
}

List<Color> colors() => [
      hexStringToColor("996600"),
      hexStringToColor("DD3300"),
      hexStringToColor("440000"),
    ];
