import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

Color primaryColor = Colors.teal;

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

BoxDecoration mirrorWidget(Color color) {
  return BoxDecoration(
      borderRadius: const BorderRadius.all(
        Radius.circular(20),
      ),
      border: Border.all(color: Colors.white.withOpacity(0.13)),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(0.15),
          color.withOpacity(0.05),
        ],
      ));
}

final snackBarError = SnackBar(
  /// need to set following properties for best effect of awesome_snackbar_content
  elevation: 0,
  behavior: SnackBarBehavior.floating,
  backgroundColor: Colors.transparent,
  content: AwesomeSnackbarContent(
    title: 'Location Not Found',
    message:
        'Something went wrong, or the location name you entered is incorrect. Please double-check the location and try again.',

    /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
    contentType: ContentType.failure,
  ),
);
