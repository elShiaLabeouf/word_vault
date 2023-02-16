import 'package:bootcamp/common/constants.dart';
import 'package:bootcamp/models/label.dart';
import 'package:bootcamp/pages/edit_phrase_page.dart';
import 'package:bootcamp/pages/phrase_reader_page.dart';
import 'package:bootcamp/widgets/home/labels_drawer.dart';
import 'package:bootcamp/widgets/phrase_card_list.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bootcamp/helpers/database/phrases_repo.dart';
import 'package:bootcamp/helpers/database/labels_repo.dart';
import 'package:bootcamp/models/phrase.dart';
import 'package:bootcamp/pages/labels_page.dart';
import 'package:bootcamp/pages/vocabularies_page.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:bootcamp/helpers/globals.dart' as globals;

import 'package:bootcamp/widgets/phrases/show_options_modal.dart';

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
  String currentVocabulary = "";
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
  int selectedPageColor = 1;
  final FocusNode _searchFocus = FocusNode();

  getPref() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      currentVocabulary =
          sharedPreferences.getString("current_vocabulary") ?? 'en';
    });
  }

  loadPhrases() async {
    setState(() {
      isLoading = true;
    });

    await phrasesRepo.getPhrasesAll(_searchController.text).then((value) {
      setState(() {
        isLoading = false;
        phrasesList = value;
        if (_searchController.text.isEmpty) phrasesListAll = value;
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

  removePhrase(phrase) {
    setState(() {
      phrasesList.removeWhere((element) => element.id == phrase.id);
    });
  }

  loadLabels() async {
    await labelsRepo.getLabelsAll().then((value) => setState(() {
          labelsList = value;
          print(labelsList.length);
        }));
  }

  @override
  void initState() {
    getPref();
    loadPhrases();
    loadLabels();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = (globals.themeMode == ThemeMode.dark ||
        (brightness == Brightness.dark &&
            globals.themeMode == ThemeMode.system));
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 100,
              backgroundColor: Colors.amber.withOpacity(0.9),
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Stack(children: [
                  AnimatedOpacity(
                    opacity: _searchOpened ? 0 : 1,
                    duration: Duration(milliseconds: 200),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        'My Dictionary',
                        style: kHeaderFont,
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    curve: Curves.easeOut,
                    left: 0,
                    bottom: 0,
                    width: _searchOpened
                        ? MediaQuery.of(context).size.width - 170
                        : 0,
                    duration: Duration(milliseconds: 300),
                    child: AnimatedOpacity(
                        opacity: _searchOpened ? 1 : 0,
                        duration: Duration(milliseconds: 200),
                        child: Container(
                          padding: const EdgeInsets.only(top: 5),
                          constraints: const BoxConstraints(
                              minHeight: 30, maxHeight: 30),
                          // width: 400,
                          child: CupertinoTextField(
                              controller: _searchController,
                              keyboardType: TextInputType.text,
                              placeholder: "Search...",
                              placeholderStyle: const TextStyle(
                                color: Color(0xffC4C6CC),
                                fontSize: 12.0,
                              ),
                              prefix: const Padding(
                                padding: EdgeInsets.fromLTRB(6, 2, 0, 0),
                                child: Icon(
                                  size: 14,
                                  Icons.search,
                                ),
                              ),
                              focusNode: _searchFocus,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: Colors.white,
                              ),
                              style: TextStyle(fontSize: 12),
                              suffix: GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  unfocusKeyboard();

                                  setState(() {
                                    _searchOpened = false;
                                    _searchController.clear();
                                    phrasesList = phrasesListAll;
                                  });
                                },

                                ///suffixIcon is of type Icon
                                child: const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 2, 6, 2),
                                  child: Icon(
                                    Boxicons.bx_x,
                                    size: 16.0,
                                    color: kBlack,
                                  ),
                                ),
                              ),
                              onChanged: (String value) {
                                setState(() {
                                  _searchController.text = value;
                                });
                                loadPhrases();
                              }),
                        )),
                  ),
                ]),
                titlePadding:
                    const EdgeInsets.only(left: 25, right: 25, bottom: 15),
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        _searchOpened = !_searchOpened;
                      });
                      if (!_searchOpened) {
                        _searchController.clear();
                        unfocusKeyboard();
                        phrasesList = phrasesListAll;
                      } else {
                        _searchFocus.requestFocus();
                      }
                    },
                    icon: const Icon(Boxicons.bx_search_alt)),
                IconButton(
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    icon: const Icon(Boxicons.bx_filter_alt)),
                IconButton(
                    onPressed: () {
                      openVocabulariesPanel();
                    },
                    icon: const Icon(Boxicons.bx_category_alt)),
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
                                const Text(
                                  'No phrases in this dictionary yet',
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
          _showEdit(context, Phrase(0, '', '', true, dateTime, dateTime));
        },
        child: const Icon(Iconsax.add),
      ),
    );
  }

  void openVocabulariesPanel() async {
    showDialog(
        context: context,
        builder: (context) => Theme(
            data: Theme.of(context).copyWith(primaryColor: Colors.pink),
            child: const VocabulariesPage()));
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

  unfocusKeyboard() {
    final FocusScopeNode currentScope = FocusScope.of(context);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  void _showEdit(BuildContext context, Phrase _phrase) async {
    await Navigator.of(context).push(CupertinoPageRoute(
        builder: (BuildContext context) => EditPhrasePage(
              phrase: _phrase,
            )));
    // if (res is Phrase) loadPhrases();
  }
}
