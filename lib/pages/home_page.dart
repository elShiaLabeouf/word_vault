import 'package:word_vault/models/label.dart';
import 'package:word_vault/pages/phrase_reader_page.dart';
import 'package:word_vault/widgets/home/first_run_dialog.dart';
import 'package:word_vault/widgets/home/labels_drawer.dart';
import 'package:word_vault/widgets/home/main_header.dart';
import 'package:word_vault/widgets/phrase_card_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:word_vault/helpers/database/phrases_repo.dart';
import 'package:word_vault/helpers/database/labels_repo.dart';
import 'package:word_vault/models/phrase.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_vault/helpers/globals.dart' as globals;

import 'package:word_vault/widgets/phrases/show_options_modal.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key})
      : super(key: key);

  static final GlobalKey<_HomePageState> staticGlobalKey =
      GlobalKey<_HomePageState>();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late SharedPreferences sharedPreferences;
  late ScrollController _scrollController;
  String? currentVocabulary;
  List<Phrase> phrasesListAll = [];
  List<Phrase> phrasesList = [];
  List<Label> labelsList = [];
  bool isLoading = false;

  bool labelChecked = false;
  bool _searchOpened = false;
  bool _headerMinimized = false;
  bool ratingOpened = false;
  String avgRating = '0';
  String currentLabel = '';
  Offset _tapPosition = Offset.zero;
  final phrasesRepo = PhrasesRepo();
  final labelsRepo = LabelsRepo();
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
    await phrasesRepo
        .getPhrasesAll(filter: searchText, labelFilter: labelFilter)
        .then((value) {
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

  loadAvgRating() async {
    await phrasesRepo.getAverageRating().then((value) => setState(() {
          avgRating = value.toStringAsPrecision(2);
        }));
  }

  @override
  void initState() {
    getPref();
    loadPhrases();
    loadLabels();
    loadAvgRating();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_searchOpened && _headerMinimized != _isSliverAppBarExpanded) {
          setState(() {
            _headerMinimized = _isSliverAppBarExpanded;
          });
        }
        
      });
    super.initState();
  }

  bool get _isSliverAppBarExpanded {
    return _scrollController.hasClients && _scrollController.offset > 40;
  }

  void openFirstRunDialog(BuildContext context, Function callback) async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      FirstRunDialog(
              context: context,
              reloadPhrasesCallback: loadPhrases,
              setVocabCallback: callback)
          .render();
    });
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = (globals.themeMode == ThemeMode.dark ||
        (brightness == Brightness.dark &&
            globals.themeMode == ThemeMode.system));

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: MainHeader(
                darkModeOn: darkModeOn,
                searchController: _searchController,
                searchFocus: _searchFocus,
                searchOpened: _searchOpened,
                headerMinimized: _headerMinimized,
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
                ratingOpened: ratingOpened,
                avgRating: avgRating,
                onRatingBtnPressed: () {
                  setState(() {
                    ratingOpened = !ratingOpened;
                  });
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
                                    ratingOpened: ratingOpened,
                                    searchText: _searchController.text,
                                    index: index,
                                    darkModeOn: darkModeOn,
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
                                if (currentVocabulary != null)
                                  Container(
                                      padding: const EdgeInsets.only(
                                        top: 100,
                                        bottom: 20,
                                        right: 40,
                                        left: 90,
                                      ),
                                      child: Image.asset(
                                          'assets/gifs/confused_travolta.gif')),
                                if (currentVocabulary == null)
                                  const SizedBox(
                                    height: 300,
                                  ),
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
      endDrawer: LabelsDrawer(
          labelsList, currentLabel, loadLabels, loadPhrases, setCurrentLabel),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 60),
        child: FloatingActionButton(
          // elevation: 0,
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
                context, Phrase(0, '', '', true, dateTime, dateTime, 0, 0));
          },
          child: const Icon(Boxicons.bx_plus),
        ),
      ),
    );
  }

  void setCurrentLabel(String label) {
    setState(() {
      currentLabel = label;
    });
  }

  void _showOptionsSheet(
      BuildContext context, Offset tapPosition, Phrase _phrase) {
    ShowOptionsModal().render(
        context, tapPosition, _phrase, loadPhrases, updatePhrase, removePhrase);
  }

  void _showPhraseReader(BuildContext context, Phrase _phrase) async {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = (globals.themeMode == ThemeMode.dark ||
        (brightness == Brightness.dark &&
            globals.themeMode == ThemeMode.system));

    bool res = await Navigator.of(context).push(CupertinoPageRoute(
        builder: (BuildContext context) => PhraseReaderPage(
              darkModeOn: darkModeOn,
              phrase: _phrase,
            )));
    if (res) loadPhrases();
  }
}
