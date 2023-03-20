import 'dart:async';

import 'package:word_vault/common/constants.dart';
import 'package:word_vault/helpers/database/phrases_repo.dart';
import 'package:word_vault/helpers/database/phrase_labels_repo.dart';
import 'package:word_vault/models/phrase.dart';
import 'package:word_vault/pages/quizzes/guess_it_quiz_result_dialog.dart';
import 'package:word_vault/widgets/quiz_answer_block.dart';
import 'package:flutter/material.dart';
import 'package:word_vault/helpers/globals.dart' as globals;

class GuessItQuizPage extends StatefulWidget {
  const GuessItQuizPage({super.key});

  @override
  _GuessItQuizPageState createState() => _GuessItQuizPageState();
}

class _GuessItQuizPageState extends State<GuessItQuizPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final phrasesRepo = PhrasesRepo();
  final phraseLabelRepo = PhraseLabelsRepo();

  List<Phrase> _phrasesList = [];
  List<Phrase> _answerPool = [];
  final Map<int, bool> _quizAnswers = {};

  String _phraseSelected = '';
  int _questionIndex = 0;
  int _totalScore = 0;
  bool answerWasSelected = false;
  bool endOfQuiz = false;
  bool correctAnswerSelected = false;

  void _questionAnswered(bool answerScore) {
    setState(() {
      // answer was selected
      answerWasSelected = true;
      // check if answer was correct
      if (answerScore) {
        _totalScore++;
        correctAnswerSelected = true;
      }
      _quizAnswers[_questionIndex] = answerScore;

      //when the quiz ends
      if (_questionIndex + 1 == _phrasesList.length) {
        endOfQuiz = true;
      }
    });
  }

  void updatePhraseRatings() {
    _quizAnswers.forEach((index, score) {
      var phrase = _phrasesList[index];
      phrasesRepo.updatePhraseRating(phrase, score ? 1 : -1);
    });
  }

  void _nextQuestion() {
    if (!endOfQuiz) {
      setState(() {
        _questionIndex++;
        answerWasSelected = false;
        correctAnswerSelected = false;
      });
    } else {
      updatePhraseRatings();
      GuessItQuizResultDialog(
              context: context,
              totalScore: _totalScore,
              maxScore: _phrasesList.length,
              toHome: () {
                NavigatorState nav = Navigator.of(context);
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
    });
  }

  late Future<List<Phrase>> _data;
  @override
  void initState() {
    // loadPhrasesForQuiz();
    super.initState();
    _data = phrasesRepo.getPhrasesForQuiz();
  }

  // void loadPhrasesForQuiz() async {
  //   await phrasesRepo.getPhrasesForQuiz().then((value) {
  //     setState(() {
  //       _phrasesList = value;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = (globals.themeMode == ThemeMode.dark ||
        (brightness == Brightness.dark &&
            globals.themeMode == ThemeMode.system));

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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50.0, vertical: 20.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              Color(0xFFb92b27),
                              Color(0xFF1565C0),
                            ],
                          ),
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Center(
                          child: Text(
                            _phrasesList[_questionIndex].definition,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 17.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...generateVariants(_questionIndex).map(
                              (answer) => QuizAnswerBlock(
                                answerText: answer.phrase,
                                answerColor: answerWasSelected
                                    ? _phrasesList[_questionIndex].phrase ==
                                            answer.phrase
                                        ? kGreenSuccess
                                        : _phraseSelected == answer.phrase
                                            ? darkModeOn ? kGrey : kLightGrey
                                            : darkModeOn ? kBlack : kWhite
                                    : darkModeOn ? kBlack : kWhite,
                                answerTap: () {
                                  // if answer was already selected then nothing happens onTap
                                  if (answerWasSelected) {
                                    return;
                                  }
                                  _phraseSelected = answer.phrase;
                                  //answer is being selected
                                  _questionAnswered(
                                      _phrasesList[_questionIndex].phrase ==
                                          answer.phrase);
                                },
                              ),
                            ),
                          ]),
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(40.00),
                              // backgroundColor: Colors.red,
                              // disabledForegroundColor: kWhite,
                              // disabledBackgroundColor: Colors.red.shade300,
                              shadowColor: Colors.red),
                          onPressed: !answerWasSelected ? null : _nextQuestion,
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

  List<Phrase> generateVariants(questionIndex) {
    if (answerWasSelected) {
      return _answerPool;
    }
    _answerPool = [..._phrasesList];
    _answerPool.removeAt(_questionIndex);
    _answerPool.shuffle();
    _answerPool = _answerPool.sublist(0, 3);
    _answerPool.add(_phrasesList[_questionIndex]);
    _answerPool.shuffle();
    return _answerPool;
  }
}
