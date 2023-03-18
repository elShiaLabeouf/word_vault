import 'package:word_vault/common/constants.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
// ignore: implementation_imports
import 'package:awesome_dialog/src/anims/rive_anim.dart';

class GuessItQuizResultDialog {
  final void Function()? toHome;
  final void Function()? toReset;

  final int totalScore;
  final int maxScore;
  late BuildContext context;
  GuessItQuizResultDialog(
      {required this.context,
      required this.totalScore,
      required this.maxScore,
      required this.toHome,
      required this.toReset});

  void render() {
    if (totalScore / maxScore > 0.5) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.infoReverse,
        animType: AnimType.rightSlide,
        title: 'Congrats!',
        desc: "You've scored $totalScore/$maxScore, here's a cake for you 😉",
        btnCancel: OutlinedButton(
            onPressed: toReset,
            style: OutlinedButton.styleFrom(
                shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(100),
              ),
            )),
            child: const Text('Try again')),
        btnOkText: 'Awesome!',
        btnOkOnPress: toHome,
        customHeader: const RiveAssetAnimation(
            assetPath: 'assets/animations/cute_cake_v4.riv', animName: 'Idle'),
      ).show();
    } else {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.noHeader,
        animType: AnimType.rightSlide,
        btnCancel: OutlinedButton(
          onPressed: () {
            NavigatorState nav = Navigator.of(context);
            nav.pop();
            nav.pop();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: kLightGrey,
            shadowColor: kLightGrey2,
          ),
          child: const FittedBox(
              child: Text('Gimme a break',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: kGrey2,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ))),
        ),
        btnOkText: "I'll try again",
        buttonsBorderRadius: BorderRadius.circular(10.0),
        btnOkOnPress: toReset,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'You can do better!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(
              height: 10.0,
            ),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                    "You only scored $totalScore/$maxScore, push it to the limit!",
                    textAlign: TextAlign.center),
              ),
            ),
            Container(
                padding: const EdgeInsets.only(
                  top: 5,
                  bottom: 20,
                  right: 20,
                  left: 20,
                ),
                child: Image.asset('assets/gifs/better_luck_next_time.gif'))
          ],
        ),
      ).show();
    }
  }
}
