import 'dart:convert';

import 'package:bootcamp/common/constants.dart';
import 'package:bootcamp/helpers/database/phrases_repo.dart';
import 'package:bootcamp/helpers/utility.dart';
import 'package:bootcamp/models/phrase.dart';
import 'package:bootcamp/pages/edit_phrase_page.dart';
import 'package:bootcamp/pages/labels_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:bootcamp/helpers/globals.dart' as globals;
import 'package:flutter_boxicons/flutter_boxicons.dart';

class PhraseReaderPage extends StatefulWidget {
  final Phrase phrase;
  const PhraseReaderPage({Key? key, required this.phrase}) : super(key: key);

  @override
  _PhraseReaderPageState createState() => _PhraseReaderPageState();
}

class _PhraseReaderPageState extends State<PhraseReaderPage> {
  late Phrase phrase;
  final phrasesRepo = PhrasesRepo();
  ScrollController scrollController = new ScrollController();
  late int currentEditingPhraseId;

  int selectedPageColor = 0;

  void _deletePhrase() async {
    await phrasesRepo.deletePhrase(currentEditingPhraseId).then((value) {
      _onBackPressed();
    });
  }

  void _setPhraseActive({bool active = true}) async {
    await phrasesRepo
        .archivePhrase(currentEditingPhraseId, active)
        .then((value) {
      setState(() {
        phrase.active = active;
      });
    });
  }

  @override
  void initState() {
    phrase = widget.phrase;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = (globals.themeMode == ThemeMode.dark ||
        (brightness == Brightness.dark &&
            globals.themeMode == ThemeMode.system));
    print(phrase.toJson());
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: darkModeOn ? kBlack : Colors.white,
        appBar: AppBar(
          elevation: 0.2,
          backgroundColor:
              (darkModeOn ? kBlack : Colors.white).withOpacity(0.6),
          leading: Container(
            margin: const EdgeInsets.all(8.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                Navigator.pop(context, true);
              },
              child: const Icon(
                Iconsax.arrow_left_2,
                size: 15,
                color: kBlack,
              ),
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Edit',
              onPressed: () {
                _showEdit(context, phrase);
              },
              color: kBlack,
              icon: const Icon(Boxicons.bxs_edit),
            ),
            IconButton(
              tooltip: 'Manage labels',
              onPressed: () {
                _assignLabel(phrase);
              },
              color: kBlack,
              icon: const Icon(Boxicons.bx_purchase_tag_alt),
            ),
            // Archive
            Visibility(
              visible: phrase.active,
              child: IconButton(
                tooltip: 'Archive',
                onPressed: () {
                  setState(() {
                    currentEditingPhraseId = phrase.id;
                  });
                  _setPhraseActive(active: false);
                },
                color: kBlack,
                icon: const Icon(Boxicons.bx_archive_in),
              ),
            ),
            Visibility(
              visible: !phrase.active,
              child: IconButton(
                tooltip: 'Unarchive',
                onPressed: () {
                  setState(() {
                    currentEditingPhraseId = phrase.id;
                  });
                  _setPhraseActive();
                },
                color: kBlack,
                icon: const Icon(Boxicons.bx_archive_out),
              ),
            ),
            IconButton(
              tooltip: 'Delete',
              onPressed: () {
                setState(() {
                  currentEditingPhraseId = phrase.id;
                });
                _confirmDelete();
              },
              color: kBlack,
              icon: const Icon(Boxicons.bxs_trash),
            )
          ],
        ),
        body: SingleChildScrollView(
          controller: scrollController,
          child: Container(
            child: Column(
              children: [
                const SizedBox(
                  height: 10.0,
                ),
                Visibility(
                  visible: phrase.phrase.isNotEmpty,
                  child: Container(
                    padding: kGlobalOuterPadding,
                    margin: const EdgeInsets.only(left: 8),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      phrase.phrase,
                      style: const TextStyle(
                          color: kBlack,
                          fontSize: 30,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                Visibility(
                  visible: phrase.definition.isNotEmpty,
                  child: Container(
                    padding: kGlobalOuterPadding,
                    margin: const EdgeInsets.only(left: 8),
                    alignment: Alignment.centerLeft,
                    child: MarkdownBody(
                      styleSheet: MarkdownStyleSheet(
                        a: const TextStyle(
                            color: Colors.purple,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600),
                        p: const TextStyle(
                          color: kBlack,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      selectable: true,
                      shrinkWrap: true,
                      data: phrase.definition,
                      softLineBreak: true,
                      fitContent: true,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    phrase.labels ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: kBlack,
                    ),
                  ),
                ),
                Text(
                    "Created on ${DateFormat('MMM dd, yyyy, h:mm a').format(phrase.createdAt)}",
                    style: const TextStyle(
                      color: kBlack,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _savePhrase() async {
    Phrase _phrase = Phrase(phrase.id, phrase.phrase, phrase.definition,
        phrase.active, phrase.createdAt, DateTime.now());
    await phrasesRepo.updatePhrase(_phrase).then((value) {});
  }

  void _showEdit(BuildContext context, Phrase _phrase) async {
    final res = await Navigator.of(context).push(CupertinoPageRoute(
        builder: (BuildContext context) => EditPhrasePage(
              phrase: _phrase,
            )));
    setState(() {
      phrase = res;
    });
  }

  void _confirmDelete() async {
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        constraints: const BoxConstraints(),
        builder: (context) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            child: Padding(
              padding: kGlobalOuterPadding,
              child: Container(
                height: 160,
                child: Padding(
                  padding: kGlobalOuterPadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: kGlobalCardPadding,
                        child: Text(
                          'Confirm',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const Padding(
                        padding: kGlobalCardPadding,
                        child: Text(
                            'Are you sure you want to delete this phrase?'),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: kGlobalCardPadding,
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('No'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: kGlobalCardPadding,
                              child: ElevatedButton(
                                onPressed: () {
                                  _deletePhrase();
                                  Navigator.pop(context, true);
                                },
                                child: const Text('Yes'),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  void _assignLabel(Phrase _phrase) async {
    var res = await Navigator.of(context).push(CupertinoPageRoute(
        builder: (BuildContext context) => LabelsPage(phrase: _phrase)));
    if (res != null) {
      print(res);
      setState(() {
        phrase.labels = res;
      });
    }
  }

  Future<bool> _onBackPressed() async {
    Navigator.pop(context, true);
    return false;
  }
}
