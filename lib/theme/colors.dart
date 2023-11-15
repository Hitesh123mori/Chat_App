import 'package:flutter/material.dart';

hexStringToColors(String hexColor){
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }

  return Color(int.parse(hexColor, radix: 16));
}


class AppColors {
  static Map theme = themes["theme1"];

  static Map themes = {
    "theme1": {
      "backgroundColor": hexStringToColors("101D25"),
      "appbarColor" : hexStringToColors("075e54"),
       "iconColor" : hexStringToColors("FFFFFF"),
      "primaryTextColor": hexStringToColors("FFFFFF"),
      "secondaryTextColor": hexStringToColors("B3B3B3"),
      "messageColor": hexStringToColors("2f4233"),
      "cardColor": hexStringToColors("101D25"),
    },

  };


}