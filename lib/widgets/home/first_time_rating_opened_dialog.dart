import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_vault/common/constants.dart';
import 'package:word_vault/helpers/simple_state_machine.dart';
import 'package:word_vault/pages/vocabularies_page.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
// ignore: implementation_imports
import 'package:awesome_dialog/src/anims/rive_anim.dart';

import 'package:word_vault/helpers/play_one_shot_animation.dart';
import 'package:rive/rive.dart';

class FirstTimeRatingOpenedDialog {
  late BuildContext context;
  FirstTimeRatingOpenedDialog({required this.context});

  void render() {
    AwesomeDialog(
      alignment: const Alignment(0, -0.5),
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
      dialogBackgroundColor: Colors.transparent,
      dialogElevation: 0,
      context: context,
      barrierColor: Colors.black87.withOpacity(0.6),
      dialogType: DialogType.noHeader,
      animType: AnimType.rightSlide,
      btnCancelOnPress: null,
      btnOkOnPress: null,
      body: FirstTimeRatingOpenedDialogBody(),
    ).show();
  }
}

class FirstTimeRatingOpenedDialogBody extends StatefulWidget {
    @override
  _FirstTimeRatingOpenedDialogBodyState createState() => _FirstTimeRatingOpenedDialogBodyState();

}

class _FirstTimeRatingOpenedDialogBodyState extends State<FirstTimeRatingOpenedDialogBody> {
  bool dialogDismissed = false;
  void setRatingOpenedDialogDismissed(bool value) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool("rating_mode_popup_dismissed", value);
    setState(() {
      dialogDismissed = value;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      child: Stack(clipBehavior: Clip.none, children: <Widget>[
        Positioned(
            top: 65,
            left: 0,
            bottom: 0,
            right: 0,
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.16),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                  color: Colors.amber,
                ),
                width: 150,
                height: 150,
                child: Stack(clipBehavior: Clip.none, children: <Widget>[
                  Column(children: [
 const Padding(
                    padding: EdgeInsets.only(top: 15, left: 15, right: 15),
                    child: Text(
                      'This toggles rating visibility for phrases.',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 20, color: kBlack
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Text(
                      'Each phrase has a rating from 0 to 100.',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 20, color: kBlack
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10, left: 15, right: 15),
                    child: Text(
                      'You can increase rating by successfuly taking quizzes.',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 20, color: kBlack
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text("Don't show this again"),
                    value: dialogDismissed,
                    onChanged: (bool? newValue) { setRatingOpenedDialogDismissed(newValue ?? false); },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  ],),
                  

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 15, left: 15, right: 15),
                      child: AnimatedButton(
                        isFixedHeight: false,
                        pressEvent: () { Navigator.pop(context); },
                        text: 'Got it',
                        color: const Color(0xFF00CA71),
                      ),
                    ),
                  )
                ]))),
      ]),
    );
  }

}
