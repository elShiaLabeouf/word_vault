import 'package:word_vault/common/constants.dart';
import 'package:word_vault/helpers/play_one_shot_animation.dart';
import 'package:word_vault/helpers/simple_state_machine.dart';
import 'package:word_vault/models/label.dart';
import 'package:word_vault/pages/phrase_reader_page.dart';
import 'package:word_vault/widgets/home/first_run_dialog.dart';
import 'package:word_vault/widgets/home/labels_drawer.dart';
import 'package:word_vault/widgets/home/main_header.dart';
import 'package:word_vault/widgets/phrase_card_list.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:word_vault/helpers/database/phrases_repo.dart';
import 'package:word_vault/helpers/database/labels_repo.dart';
import 'package:word_vault/models/phrase.dart';
import 'package:word_vault/pages/labels_page.dart';
import 'package:word_vault/pages/vocabularies_page.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:word_vault/helpers/globals.dart' as globals;

import 'package:word_vault/widgets/phrases/show_options_modal.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title})
      : super(key: HomePage.staticGlobalKey);
  final String title;

  static final GlobalKey<_HomePageState> staticGlobalKey =
      GlobalKey<_HomePageState>();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late SharedPreferences sharedPreferences;
  String userFullname = "";
  String userId = "";
  String userEmail = "";
  String? currentVocabulary;
  List<Phrase> phrasesListAll = [];
  List<Phrase> phrasesList = [];
  List<Label> labelsList = [];
  bool isLoading = false;

  bool labelChecked = false;
  bool _searchOpened = false;
  Offset _tapPosition = Offset.zero;
  final phrasesRepo = PhrasesRepo();
  final labelsRepo = LabelsRepo();
  var uuid = const Uuid();
  final TextEditingController _phraseController = TextEditingController();
  final TextEditingController _definitionController = TextEditingController();
  late int currentEditingPhraseId;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  int selectedPageColor = 1;

  getPref() async {
    await SharedPreferences.getInstance().then((prefs) {
      setState(() {
        sharedPreferences = prefs;
        currentVocabulary = sharedPreferences.getString("current_vocabulary");
      });
      if (currentVocabulary == null) {
        openFirstRunDialog(context, (newVocabulary) {
          setState(() => {currentVocabulary = newVocabulary});
        });
      }
    });
  }

  loadPhrases({String? searchText, String? labelFilter}) async {
    setState(() {
      isLoading = true;
    });
    await phrasesRepo.getPhrasesAll(filter: searchText, labelFilter: labelFilter).then((value) {
      setState(() {
        isLoading = false;
        phrasesList = value;
        if (searchText == null) phrasesListAll = value;
      });
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

  loadLabels() async {
    await labelsRepo.getLabelsAll().then((value) => setState(() {
          labelsList = value;
        }));
  }

  @override
  void initState() {
    getPref();
    loadPhrases();
    loadLabels();
    super.initState();
  }

  void openFirstRunDialog(BuildContext context, Function callback) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      FirstRunDialog(context: context, reloadPhrasesCallback: loadPhrases, setVocabCallback: callback).render();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: MainHeader(
                searchController: _searchController,
                searchFocus: _searchFocus,
                searchOpened: _searchOpened,
                onSearchIconPressed: () {
                  setState(() {
                    _searchOpened = !_searchOpened;
                    if (!_searchOpened) {
                      _searchController.clear();
                      _searchOpened = false;
                      phrasesList = phrasesListAll;
                    } else {
                      _searchFocus.requestFocus();
                    }
                  });
                },
                onSearchClose: () {
                  setState(() {
                    _searchController.clear();
                    _searchOpened = false;
                    phrasesList = phrasesListAll;
                  });
                },
                onSearchFieldChanged: (String value) {
                  loadPhrases(searchText: value);
                },
                onLocaleChange: (String newValue) {
                  setState(() {
                    currentVocabulary = newValue;
                  });
                  loadPhrases();
                },
                currentLocaleIso: currentVocabulary)
            .headerSliverBuilder,
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
                                    searchText: _searchController.text,
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
                              children: [
                                Container(
                                    padding: const EdgeInsets.only(
                                      top: 100,
                                      bottom: 20,
                                      right: 40,
                                      left: 90,
                                    ),
                                    child: Image.asset(
                                        'assets/gifs/confused_travolta.gif')),
                                Text(
                                  _searchController.text.isEmpty
                                      ? 'No phrases in this dictionary yet'
                                      : 'No phrases found',
                                  style: const TextStyle(
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
      endDrawer: LabelsDrawer(labelsList, loadLabels, loadPhrases),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        onPressed: () {
          setState(() {
            _phraseController.text = '';
            _definitionController.text = '';
            currentEditingPhraseId = 0;
          });
          DateTime dateTime = DateTime.now();
          _showPhraseReader(
              context, Phrase(0, '', '', true, dateTime, dateTime, 0));
        },
        child: const Icon(Boxicons.bx_plus),
      ),
    );
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
}
