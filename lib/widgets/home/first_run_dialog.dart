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

class FirstRunDialog {
  late BuildContext context;
  Function? callback;
  FirstRunDialog({required this.context, this.callback});

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
      body: FirstRunDialogDuck(callback: callback),
    ).show();
  }
}

class FirstRunDialogDuck extends StatefulWidget {
  Function? callback;
  FirstRunDialogDuck({Key? key, Function? callback}) : super(key: key);
  @override
  State<StatefulWidget> createState() => FirstRunDialogDuckState();
}

class FirstRunDialogDuckState extends State<FirstRunDialogDuck> {
  String currentVocabulary = '';
  List bodyText = [
    const Text('Hello!',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
        )),
    const Text(
        'This app is to help you to memorize new phrases you come across',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
        )),
    RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        children: <TextSpan>[
          TextSpan(
              text: "First, select a language you're eager to master.\n",
              style: TextStyle(
                fontSize: 20,
                color: kBlack,
              )),
          TextSpan(
              text: '(you can change it later any time)',
              style: TextStyle(fontSize: 14, color: kBlack)),
        ],
      ),
    ),
    'SELECT_LANG_SCREEN',
    const Text(
        'Fill the vault with\nnew phrases you hear from people,\nTV shows, books, etc.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 17,
        ))
  ];
  late int currentIndex;
  SMITrigger? _bump;

  void _onRiveInit(Artboard artboard) {
    final controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1');
    artboard.addController(controller!);
    _bump = controller.findInput<bool>('Pressed') as SMITrigger;
  }

  void _hitBump() {
    if (currentIndex < bodyText.length - 1) {
      setState(() => currentIndex++);
      _bump?.fire();
    } else {
      Navigator.pop(context);
    }
  }

  void _hitDuck() {
    _bump?.fire();
  }

  @override
  void initState() {
    currentIndex = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 285,
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
                  Align(
                    alignment: Alignment.center,
                    child: bodyText[currentIndex] == 'SELECT_LANG_SCREEN'
                        ? openVocabulariesPanel(context)
                        : bodyText[currentIndex],
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 15, left: 15, right: 15),
                      child: AnimatedButton(
                        isFixedHeight: false,
                        pressEvent: _hitBump,
                        text: currentIndex == bodyText.length - 1
                            ? 'Finish'
                            : 'Next',
                        color: const Color(0xFF00CA71),
                      ),
                    ),
                  )
                ]))),
        Positioned.fill(
          top: 0,
          child: Align(
              alignment: Alignment.topCenter,
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 75.0,
                child: Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _hitDuck,
                    child: RiveAnimation.asset(
                      'assets/animations/duck5.riv',
                      fit: BoxFit.contain,
                      onInit: _onRiveInit,
                    ),
                  ),
                ),
              )),
        ),
      ]),
    );
  }

  CircularProgressIndicator openVocabulariesPanel(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      showGeneralDialog(
        context: context,
        transitionBuilder: (context, a1, a2, _widget) {
          final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
          return Transform(
            transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
            child: Opacity(
              opacity: a1.value,
              child: VocabulariesPage((String newValue) {
                setState(() {
                  currentIndex++;
                  widget.callback?.call(newValue);
                });
              }),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation1, animation2) {
          return const Scaffold();
        },
      );

      // showDialog(
      //     context: context,
      //     builder: (context) => Theme(
      //         data: Theme.of(context),
      //         child: VocabulariesPage(),
      //     barrierDismissible: false);
    });
    return const CircularProgressIndicator();
  }
}
