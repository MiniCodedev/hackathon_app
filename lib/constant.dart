import 'package:flutter/material.dart';

Color primaryColor = Colors.cyan;

final border = OutlineInputBorder(
  borderRadius: const BorderRadius.all(Radius.circular(10)),
  borderSide: BorderSide(
    width: 1,
    color: primaryColor,
  ),
);

final focusborder = OutlineInputBorder(
  borderRadius: const BorderRadius.all(Radius.circular(10)),
  borderSide: BorderSide(
    width: 1,
    color: primaryColor,
  ),
);

const errorBroder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(50)),
    borderSide:
        BorderSide(width: 2, color: Color.fromARGB(255, 238, 146, 139)));

final mirror = BoxDecoration(
    borderRadius: const BorderRadius.all(
      Radius.circular(20),
    ),
    border: Border.all(color: Colors.white.withOpacity(0.13)),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.15),
        Colors.white.withOpacity(0.05),
      ],
    ));
