import 'dart:async';

import 'package:bootcamp/common/constants.dart';
import 'package:bootcamp/helpers/database/phrases_repo.dart';
import 'package:bootcamp/helpers/database/phrase_labels_repo.dart';
import 'package:bootcamp/models/phrase.dart';
import 'package:bootcamp/pages/quizzes/guess_it_quiz_result_dialog.dart';
import 'package:bootcamp/widgets/quiz_answer_block.dart';
import 'package:flutter/material.dart';
import 'package:bootcamp/common/theme.dart';
import 'package:animate_gradient/animate_gradient.dart';

class NameItQuizPage extends StatefulWidget {
  const NameItQuizPage({super.key});

  @override
  _NameItQuizPageState createState() => _NameItQuizPageState();
}

class _NameItQuizPageState extends State<NameItQuizPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode answerFocusNode = FocusNode();
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _correctAnswerController =
      TextEditingController();
  final phrasesRepo = PhrasesRepo();
  final phraseLabelRepo = PhraseLabelsRepo();

  List<Phrase> _phrasesList = [];

  int _questionIndex = 0;
  int _totalScore = 0;
  bool answerWasSelected = false;
  bool endOfQuiz = false;
  bool correctAnswerSelected = false;
  bool _showAnswer = false;

  void _questionAnswered(bool answerScore) {
    setState(() {
      // answer was selected
      answerWasSelected = true;
      // check if answer was correct
      _correctAnswerController.text = _phrasesList[_questionIndex].phrase;
      _showAnswer = !answerScore;
      if (answerScore) {
        _totalScore++;
        correctAnswerSelected = true;
      }

      //when the quiz ends
      if (_questionIndex + 1 == _phrasesList.length) {
        endOfQuiz = true;
      }
    });
  }

  void _nextQuestion() {
    if (!endOfQuiz) {
      setState(() {
        _showAnswer = false;
        _questionIndex++;
        answerWasSelected = false;
        correctAnswerSelected = false;
        _answerController.text = '';
        answerFocusNode.requestFocus();
      });
    } else {
      GuessItQuizResultDialog(
              context: context,
              totalScore: _totalScore,
              maxScore: _phrasesList.length,
              toHome: () {
                NavigatorState nav = Navigator.of(context);
                nav.pop();
                nav.pop();
              },
              toReset: _resetQuiz)
          .render();
    }
  }

  void _resetQuiz() {
    setState(() {
      _questionIndex = 0;
      _totalScore = 0;
      endOfQuiz = false;
      answerWasSelected = false;
      correctAnswerSelected = false;
      _answerController.text = '';
    });
  }

  late Future<List<Phrase>> _data;
  @override
  void initState() {
    super.initState();
    _data = phrasesRepo.getPhrasesForQuiz();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Phrase>>(
        future: _data,
        builder: (context, AsyncSnapshot<List<Phrase>> snapshot) {
          if (snapshot.hasData) {
            _phrasesList = snapshot.data!;
            return WillPopScope(
              onWillPop: _onBackPressed,
              child: Scaffold(
                key: _scaffoldKey,
                appBar: AppBar(
                  toolbarHeight: 75,
                  title: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      '${_questionIndex + 1}/${_phrasesList.length}',
                      style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFe3e3e3)),
                    ),
                  ),
                ),
                body: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Spacer(),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 130),
                        margin: const EdgeInsets.only(
                            bottom: 10.0, left: 30.0, right: 30.0),
                        decoration: BoxDecoration(
                          // gradient: const LinearGradient(
                          //   begin: Alignment.centerRight,
                          //   end: Alignment.centerLeft,
                          //   colors: [
                          //     Color(0xFFb92b27),
                          //     Color(0xFF1565C0),
                          //   ],
                          // ),
                          // color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.transparent, spreadRadius: 3)
                          ],
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: AnimateGradient(
                          primaryBegin: Alignment.topLeft,
                          primaryEnd: Alignment.topRight,
                          secondaryBegin: Alignment.bottomRight,
                          secondaryEnd: Alignment.bottomLeft,
                          duration: Duration(seconds: 3),
                          primaryColors: const [
                            Color(0xFFb92b27),
                            Color(0xFF1565C0),
                          ],
                          secondaryColors: const [
                            Color(0xFF1565C0),
                            Color(0xFFb92b27),
                          ],
                          child: Center(
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50.0, vertical: 20.0),
                                child: Text(
                                  _phrasesList[_questionIndex].definition,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 17.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: TextField(
                            minLines: 1,
                            maxLines: 3,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.done,
                            onEditingComplete: () {
                              _questionAnswered(
                                  _phrasesList[_questionIndex].phrase ==
                                      _answerController.text);
                            },
                            readOnly: answerWasSelected,
                            controller: _answerController,
                            focusNode: answerFocusNode,
                            autofocus: true,
                            onSubmitted: (value) {
                              answerFocusNode.unfocus();
                            },
                            decoration: const InputDecoration(
                              hintText: 'Your guess...',
                            ).applyDefaults(inputDecorationTheme()).copyWith(
                                filled: true,
                                fillColor: answerWasSelected
                                    ? correctAnswerSelected
                                        ? kGreenSuccess
                                        : kLightGrey
                                    : kWhite),
                          )),
                      Visibility(
                          visible: _showAnswer,
                          child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 30.0, right: 30.0, top: 15.0),
                              child: TextField(
                                readOnly: true,
                                controller: _correctAnswerController,
                                decoration: (const InputDecoration())
                                    .applyDefaults(inputDecorationTheme())
                                    .copyWith(
                                      filled: true,
                                      fillColor: kGreenSuccess,
                                    ),
                              ))),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 30.0, right: 30.0, top: 25.0, bottom: 25.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(40.00),
                              backgroundColor: Colors.red,
                              shadowColor: Colors.red,
                              disabledForegroundColor: kWhite,
                              disabledBackgroundColor: Colors.red.shade300),
                          onPressed: _answerController.text.isEmpty
                              ? null
                              : _nextQuestion,
                          child: Text(
                              endOfQuiz ? 'See the results' : 'Next Question'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }

  Future<bool> _onBackPressed() async {
    Navigator.pop(context, null);
    return true;
  }
}
