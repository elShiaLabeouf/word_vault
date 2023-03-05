import 'dart:async';

import 'package:word_vault/common/constants.dart';
import 'package:word_vault/helpers/simple_state_machine.dart';
import 'package:word_vault/pages/vocabularies_page.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
// ignore: implementation_imports
import 'package:awesome_dialog/src/anims/rive_anim.dart';

import 'package:word_vault/helpers/play_one_shot_animation.dart';
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
    print("InternetSearchErrorWidget $e");
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
