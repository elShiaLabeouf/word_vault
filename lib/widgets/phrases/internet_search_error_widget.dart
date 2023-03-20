import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
// ignore: implementation_imports
import 'package:awesome_dialog/src/anims/rive_anim.dart';
import 'package:rive/rive.dart';

class InternetSearchErrorWidget {
  late BuildContext context;
  InternetSearchErrorWidget({required this.context});

  void render(Exception e) {
    String errorText = 'Something went wrong :(';
    if (e.toString().contains("SocketException") ||
        e.toString().contains('Failed host lookup')) {
      errorText = "Internet connection is not available :(";
    }
    AwesomeDialog(
            context: context,
            dialogType: DialogType.noHeader,
            animType: AnimType.bottomSlide,
            body: ConstrainedBox(
              constraints: const BoxConstraints(
                  minHeight: 50, minWidth: double.infinity, maxHeight: 400),
              child: Text(
                errorText,
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ),
            btnOkText: "Okay",
            btnOkOnPress: () {},
            btnCancelOnPress: null)
        .show();
  }
}
