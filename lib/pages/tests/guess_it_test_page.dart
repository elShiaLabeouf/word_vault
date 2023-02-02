import 'dart:async';

import 'package:bootcamp/helpers/database/phrases_repo.dart';
import 'package:bootcamp/helpers/database/phrase_labels_repo.dart';
import 'package:bootcamp/models/label.dart';
import 'package:bootcamp/models/phrase.dart';
import 'package:bootcamp/widgets/small_appbar.dart';
import 'package:bootcamp/widgets/testing_answer_block.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class GuessItTestPage extends StatefulWidget {
  @override
  _GuessItTestPageState createState() => _GuessItTestPageState();
}

class _GuessItTestPageState extends State<GuessItTestPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final phrasesRepo = PhrasesRepo();
  final phraseLabelRepo = PhraseLabelsRepo();
  final int currentPhrase = 0;

  List<Phrase> _phrasesList = [];

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

      //when the quiz ends
      if (_questionIndex + 1 == _phrasesList.length) {
        endOfQuiz = true;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _questionIndex++;
      answerWasSelected = false;
      correctAnswerSelected = false;
    });
    // what happens at the end of the quiz
    if (_questionIndex >= _phrasesList.length) {
      // TODO: finish screen
    }
  }


  @override
  void initState() {
    loadPhrasesForTesting();
    super.initState();
  }

  void loadPhrasesForTesting() async {
    await phrasesRepo.getPhrasesForTesting().then((value) {
      _phrasesList = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        key: _scaffoldKey,
        body: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: double.infinity,
                height: 130.0,
                margin: const EdgeInsets.only(bottom: 10.0, left: 30.0, right: 30.0),
                padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 20.0),
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: NetworkImage('https://wallpapers.moviemania.io/phone/tv/66732/0b2e03/stranger-things-phone-wallpaper.jpg?w=820&h=1459'),
                    fit: BoxFit.cover,
                    opacity: 10,
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
              ..._phrasesList.map(
                    (answer) => TestingAnswerBlock(
                      answerText: answer.phrase,
                      answerColor: answerWasSelected ? _phrasesList[_questionIndex].phrase == answer.phrase ? Colors.green : Colors.red : Colors.white70,
                      answerTap: () {
                        // if answer was already selected then nothing happens onTap
                        if (answerWasSelected) {
                          return;
                        }
                        //answer is being selected
                        _questionAnswered(_phrasesList[_questionIndex].phrase == answer.phrase);
                      },
                    ),
              ),
              ElevatedButton(
                style:
                ElevatedButton.styleFrom(
                  minimumSize: const Size(200.00, 40.0),backgroundColor:Colors.red,shadowColor: Colors.red,
                ),
                onPressed: () {
                  if (!answerWasSelected) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please select an answer before going to the next question'),
                    ));
                    return;
                  }
                  _nextQuestion();
                },
                child: Text(endOfQuiz ? 'Restart Quiz' : 'Next Question'),
              ),
                            Container(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  '${_totalScore.toString()}/${_phrasesList.length}',
                  style: const TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
                ),
              ),
              if (answerWasSelected && !endOfQuiz)
                Container(
                  height: 100,
                  width: double.infinity,
                  color: correctAnswerSelected ? Colors.green : Colors.redAccent,
                  child: Center(
                    child: Text(
                      correctAnswerSelected
                          ? 'Correct!'
                          : 'Incorrect :(',
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              if (endOfQuiz)
                Container(
                  height: 100,
                  width: double.infinity,
                  color: Colors.black,
                  child: Center(
                    child: Text(
                      _totalScore > 4
                          ? 'Congratulations! Your final score is: $_totalScore'
                          : 'Your final score is: $_totalScore. Better luck next time!',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: _totalScore > 4 ? Colors.green : Colors.redAccent,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    Navigator.pop(context, null);
    return true;
  }
}
