import 'dart:ui';

import 'package:word_vault/common/constants.dart';
import 'package:word_vault/helpers/utility.dart';
import 'package:word_vault/models/label.dart';
import 'package:word_vault/pages/phrase_reader_page.dart';
import 'package:word_vault/widgets/home/labels_drawer.dart';
import 'package:word_vault/widgets/phrase_card_list.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:word_vault/helpers/database/phrases_repo.dart';
import 'package:word_vault/helpers/database/labels_repo.dart';
import 'package:word_vault/models/phrase.dart';
import 'package:word_vault/pages/labels_page.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:word_vault/helpers/globals.dart' as globals;

import '../widgets/phrases/show_options_modal.dart';

class ArchivedPage extends StatefulWidget {
  ArchivedPage({Key? key}) : super(key: ArchivedPage.staticGlobalKey);

  static final GlobalKey<_ArchivedPageState> staticGlobalKey =
      new GlobalKey<_ArchivedPageState>();

  @override
  _ArchivedPageState createState() => _ArchivedPageState();
}

class _ArchivedPageState extends State<ArchivedPage> {
  late SharedPreferences sharedPreferences;
  String currentLabel = "";
  ScrollController scrollController = new ScrollController();
  List<Phrase> phrasesListAll = [];
  List<Phrase> phrasesList = [];
  List<Label> labelsList = [];
  bool isLoading = false;
  bool hasData = false;
  Offset _tapPosition = Offset.zero;

  bool isAndroid = UniversalPlatform.isAndroid;
  bool isIOS = UniversalPlatform.isIOS;
  bool labelChecked = false;

  final phrasesRepo = PhrasesRepo();
  final labelsRepo = LabelsRepo();
  var uuid = const Uuid();
  final TextEditingController _phraseController = TextEditingController();
  final TextEditingController _definitionController = TextEditingController();
  late int currentEditingPhraseId;

  int selectedPageColor = 1;

  loadPhrases({String? labelFilter}) async {
    setState(() {
      isLoading = true;
    });

    await phrasesRepo.getPhrasesAll(
        labelFilter: labelFilter, active: [0]).then((value) {
      setState(() {
        isLoading = false;
        hasData = value.isNotEmpty;
        phrasesList = value;
        phrasesListAll = value;
      });
    });
  }

  loadLabels() async {
    await labelsRepo.getLabelsAll().then((value) => setState(() {
          labelsList = value;
        }));
  }

  void _activatePhrase() async {
    await phrasesRepo.archivePhrase(currentEditingPhraseId, true).then((value) {
      loadPhrases();
    });
  }

  void _deactivatePhrase() async {
    await phrasesRepo
        .archivePhrase(currentEditingPhraseId, false)
        .then((value) {
      loadPhrases();
    });
  }

  void _deletePhrase() async {
    await phrasesRepo.deletePhrase(currentEditingPhraseId).then((value) {
      loadPhrases();
    });
  }

  void _filterPhrases() async {
    await phrasesRepo
        .getPhrasesAll(labelFilter: currentLabel, active: [0]).then((value) {
      setState(() {
        phrasesList = value;
      });
    });
  }

  void _clearFilterPhrases() {
    setState(() {
      phrasesList = phrasesListAll;
    });
  }

  @override
  void initState() {
    loadPhrases();
    loadLabels();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 100.0,
              backgroundColor: Colors.amber.withOpacity(0.9),
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Archive',
                  style: kHeaderFont,
                ),
                titlePadding: EdgeInsets.only(left: 30, bottom: 15),
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    icon: const Icon(Iconsax.filter))
              ],
            ),
          ];
        },
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : (phrasesList.isNotEmpty
                        ? (GestureDetector(
                            child: Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.all(0),
                              child: ListView.builder(
                                itemCount: phrasesList.length,
                                physics: const BouncingScrollPhysics(
                                    parent: AlwaysScrollableScrollPhysics()),
                                itemBuilder: (context, index) {
                                  var phrase = phrasesList[index];
                                  return PhraseCardList(
                                    phrase: phrase,
                                    ratingOpened: false,
                                    index: index,
                                    onTap: () {
                                      _showPhraseReader(context, phrase);
                                    },
                                    onLongPress: () {
                                      _showOptionsSheet(
                                          context, _tapPosition, phrase);
                                    },
                                  );
                                },
                              ),
                            ),
                            onTapDown: (TapDownDetails tap) {
                              final RenderBox referenceBox =
                                  context.findRenderObject() as RenderBox;
                              setState(() {
                                _tapPosition = referenceBox
                                    .globalToLocal(tap.globalPosition);
                              });
                            },
                          ))
                        : Container(
                            alignment: Alignment.topCenter,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                SizedBox(
                                  height: 150,
                                ),
                                Icon(
                                  Iconsax.note_1,
                                  size: 120,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  'No archived phrases yet',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 22),
                                ),
                              ],
                            ),
                          )),
              ),
            ],
          ),
        ),
      ),
      endDrawer: LabelsDrawer(labelsList, currentLabel, loadLabels, loadPhrases, setCurrentLabel),
    );
  }

  void setCurrentLabel(String label) {
    setState(() {
      currentLabel = label;
    });
  }

  void openLabelEditor() async {
    var res = await Navigator.of(context).push(CupertinoPageRoute(
        builder: (BuildContext context) => LabelsPage(
            phrase: Phrase(
                0, '', '', true, DateTime.now(), DateTime.now(), 0, 0))));
    loadLabels();
    if (res) loadPhrases();
  }

  openDialog(Widget page) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = (globals.themeMode == ThemeMode.dark ||
        (brightness == Brightness.dark &&
            globals.themeMode == ThemeMode.system));
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: darkModeOn ? kBlack : Colors.white,
            shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: darkModeOn ? Colors.white24 : kBlack,
                ),
                borderRadius: BorderRadius.circular(10)),
            child: Container(
                decoration: BoxDecoration(
                  color: darkModeOn ? kBlack : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                    maxWidth: 600,
                    minWidth: 400,
                    minHeight: 600,
                    maxHeight: 600),
                padding: const EdgeInsets.all(8),
                child: page),
          );
        });
  }

  updatePhrase(phrase) {
    setState(() {
      final index =
          phrasesList.indexWhere((element) => element.id == phrase.id);
      phrasesList[index] = phrase;
    });
  }

  removePhrase(phraseId) {
    setState(() {
      phrasesList.removeWhere((element) => element.id == phraseId);
    });
  }


  void _showOptionsSheet(
      BuildContext context, Offset tapPosition, Phrase _phrase) {
    ShowOptionsModal().render(
        context, tapPosition, _phrase, loadPhrases, updatePhrase, removePhrase);
  }

  void _showPhraseReader(BuildContext context, Phrase _phrase) async {
    bool res = await Navigator.of(context).push(CupertinoPageRoute(
        builder: (BuildContext context) => PhraseReaderPage(
              phrase: _phrase,
            )));
    if (res) loadPhrases();
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
                        child: Text('Are you sure you want to delete?'),
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  void _assignLabel(Phrase phrase) async {
    var res = await Navigator.of(context).push(CupertinoPageRoute(
        builder: (BuildContext context) => LabelsPage(
              phrase: phrase,
            )));
    if (res) loadPhrases();
  }

  void _showEdit(BuildContext context, Phrase phrase) async {
    final res = await Navigator.of(context).push(CupertinoPageRoute(
        builder: (BuildContext context) => PhraseReaderPage(
              phrase: phrase,
              isEditing: true,
            )));

    if (res is Phrase) loadPhrases();
  }
}
