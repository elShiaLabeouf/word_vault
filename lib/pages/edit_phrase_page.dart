import 'package:bootcamp/common/constants.dart';
import 'package:bootcamp/helpers/database/phrases_repo.dart';
import 'package:bootcamp/helpers/database_helper.dart';
import 'package:bootcamp/models/phrase.dart';
import 'package:bootcamp/widgets/small_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:bootcamp/helpers/globals.dart' as globals;

class EditPhrasePage extends StatefulWidget {
  final Phrase phrase;

  const EditPhrasePage({Key? key, required this.phrase}) : super(key: key);

  @override
  _EditPhrasePageState createState() => _EditPhrasePageState();
}

class _EditPhrasePageState extends State<EditPhrasePage> {
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode contentFocusNode = FocusNode();
  TextEditingController _phraseController = new TextEditingController();
  TextEditingController _definitionController = new TextEditingController();
  int currentEditingPhraseId = 0;
  final phrasesRepo = PhrasesRepo();
  var uuid = const Uuid();
  late Phrase phrase;

  void _savePhrase() async {
    if (currentEditingPhraseId == 0) {
      setState(() {
        phrase = Phrase(
            0,
            _phraseController.text,
            _definitionController.text,
            true,
            DateTime.now(),
            DateTime.now());
      });
      await phrasesRepo.insertPhrase(phrase).then((value) {
        // loadNotes();
      });
    } else {
      setState(() {
        phrase = Phrase(
            currentEditingPhraseId,
            _phraseController.text,
            _definitionController.text,
            true,
            DateTime.now(),
            DateTime.now());
      });
      await phrasesRepo.updatePhrase(phrase).then((value) {
        // loadNotes();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      phrase = widget.phrase;
      _phraseController.text = phrase.phrase;
      _definitionController.text = phrase.definition;
      currentEditingPhraseId = phrase.id;
    });
    titleFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = (globals.themeMode == ThemeMode.dark ||
        (brightness == Brightness.dark &&
            globals.themeMode == ThemeMode.system));
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Builder(builder: (context) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: SAppBar(
              title: '',
              onTap: _onBackPressed,
            ),
          ),
          body: GestureDetector(
            onTap: () {
              contentFocusNode.requestFocus();
            },
            child: Padding(
              padding: kGlobalOuterPadding,
              child: ListView(
                children: [
                  // Padding(
                  //   padding: kGlobalOuterPadding,
                  //   child: Container(
                  //     child: NoteEditTextField(
                  //       controller: _noteTitleController,
                  //       hint: 'Title',
                  //       focusNode: titleFocusNode,
                  //       onSubmitFocusNode: contentFocusNode,
                  //     ),
                  //   ),
                  // ),
                  TextField(
                    controller: _phraseController,
                    focusNode: titleFocusNode,
                    onSubmitted: (value) {
                      contentFocusNode.requestFocus();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Phrase',
                      // label: Text('Title'),
                      // isCollapsed: true,
                      fillColor: Colors.transparent,
                      enabledBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  const Divider(
                    thickness: 1.2,
                    endIndent: 10,
                    indent: 10,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  TextField(
                    controller: _definitionController,
                    focusNode: contentFocusNode,
                    maxLines: null,
                    onSubmitted: (value) {
                      contentFocusNode.requestFocus();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Definition',
                      fillColor: Colors.transparent,
                      enabledBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder:
                          OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<bool> _onBackPressed() async {
    if (_phraseController.text.isNotEmpty) {
      _savePhrase();
      Navigator.pop(context, phrase);
    } else {
      Navigator.pop(context, false);
    }
    return false;
  }
}
