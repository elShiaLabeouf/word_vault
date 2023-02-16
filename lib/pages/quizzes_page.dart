import 'dart:async';
import 'package:bootcamp/common/constants.dart';
import 'package:flutter/material.dart';
import 'package:bootcamp/models/phrase.dart';
import 'package:bootcamp/helpers/database/phrases_repo.dart';
import 'package:bootcamp/pages/quizzes/guess_it_quiz_page.dart';
import 'package:bootcamp/pages/quizzes/name_it_quiz_page.dart';
import 'package:bootcamp/widgets/small_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizzesPage extends StatefulWidget {
  QuizzesPage({Key? key}) : super(key: key);

  @override
  _QuizzesPageState createState() => _QuizzesPageState();
}

class _QuizzesPageState extends State<QuizzesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final phrasesRepo = PhrasesRepo();
  List<Phrase> _phrasesList = [];

  @override
  void initState() {
    loadPhrases();
    super.initState();
  }

  void loadPhrases() async {
    await phrasesRepo.getPhrasesForQuiz().then((value) {
      _phrasesList = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 100,
          titleSpacing: 30,
          backgroundColor: Colors.amber,
          title: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Text(
                'Quizzes',
                style: kHeaderFont.copyWith(fontSize: 30),
                textAlign: TextAlign.end,
              ))),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
          Widget>[
        Padding(
          padding: kGlobalCardPadding,
          child: InkWell(
              borderRadius: BorderRadius.circular(10.0),
              onTap: () {
                // Navigator.of(context).push(CupertinoPageRoute(
                //     builder: (context) => DefineItTestPage()
                //   ));
              },
              child: const ListTile(
                leading: CircleAvatar(
                  child: Icon(Iconsax.keyboard),
                ),
                title: Text(
                  'Explain it',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Write the definition to a given phrase',
                ),
              )),
        ),
        Padding(
          padding: kGlobalCardPadding,
          child: InkWell(
              borderRadius: BorderRadius.circular(10.0),
              onTap: () {
                if (_phrasesList.length < 5) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        'Please, increase your vocab size to at least 5 phrases'),
                  ));
                  return;
                }
                Navigator.of(context).push(CupertinoPageRoute(
                    builder: (context) => GuessItQuizPage()));
              },
              child: const ListTile(
                leading: CircleAvatar(
                  child: Icon(CupertinoIcons.rectangle_grid_2x2),
                ),
                title: Text(
                  'Tap the word',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('Pick the correct phrase from a few choices'),
              )),
        ),
        Padding(
          padding: kGlobalCardPadding,
          child: InkWell(
              borderRadius: BorderRadius.circular(10.0),
              onTap: () {
                Navigator.of(context).push(
                    CupertinoPageRoute(builder: (context) => NameItQuizPage()));
              },
              child: const ListTile(
                leading: CircleAvatar(
                  child: Icon(CupertinoIcons.pencil_ellipsis_rectangle),
                ),
                title: Text(
                  'Write the word',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Write the word by its definition',
                ),
              )),
        )
      ]),
    );
  }
}
