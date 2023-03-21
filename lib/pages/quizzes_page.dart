import 'package:word_vault/common/constants.dart';
import 'package:flutter/material.dart';
import 'package:word_vault/models/phrase.dart';
import 'package:word_vault/helpers/database/phrases_repo.dart';
import 'package:word_vault/pages/quizzes/guess_it_quiz_page.dart';
import 'package:word_vault/pages/quizzes/name_it_quiz_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:word_vault/helpers/globals.dart' as globals;

class QuizzesPage extends StatefulWidget {
  const QuizzesPage({Key? key}) : super(key: key);

  @override
  _QuizzesPageState createState() => _QuizzesPageState();
}

class _QuizzesPageState extends State<QuizzesPage> {
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
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = (globals.themeMode == ThemeMode.dark ||
        (brightness == Brightness.dark &&
            globals.themeMode == ThemeMode.system));

    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 100,
          titleSpacing: 30,
          backgroundColor: darkModeOn ? kBlack.withOpacity(0.9) : Colors.amber,
          title: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Text(
                'Quizzes',
                // style: kHeaderFont.copyWith(fontSize: 30),
                textAlign: TextAlign.end,
                style: (darkModeOn ? kHeaderFontDark : kHeaderFont)
                    .copyWith(fontSize: 30),
              ))),
      body: Padding(padding: const EdgeInsets.only(bottom: 60), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
          Widget>[
        // Padding(
        //   padding: kGlobalCardPadding,
        //   child: InkWell(
        //       borderRadius: BorderRadius.circular(10.0),
        //       onTap: () {
        //         // Navigator.of(context).push(CupertinoPageRoute(
        //         //     builder: (context) => DefineItTestPage()
        //         //   ));
        //       },
        //       child: const ListTile(
        //         leading: CircleAvatar(
        //           child: Icon(Iconsax.keyboard),
        //         ),
        //         title: Text(
        //           'Explain it',
        //           style: TextStyle(fontWeight: FontWeight.w600),
        //         ),
        //         subtitle: Text(
        //           'Write the definition to a given phrase',
        //         ),
        //       )),
        // ),
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
                    builder: (context) => const GuessItQuizPage()));
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
                    CupertinoPageRoute(builder: (context) => const NameItQuizPage()));
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
    ));
  }
}
