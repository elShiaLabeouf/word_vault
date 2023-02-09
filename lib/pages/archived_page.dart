import 'dart:ui';

import 'package:bootcamp/common/constants.dart';
import 'package:bootcamp/helpers/utility.dart';
import 'package:bootcamp/models/label.dart';
import 'package:bootcamp/pages/edit_phrase_page.dart';
import 'package:bootcamp/pages/phrase_reader_page.dart';
import 'package:bootcamp/widgets/phrase_card_list.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bootcamp/helpers/database/phrases_repo.dart';
import 'package:bootcamp/helpers/database/labels_repo.dart';
import 'package:bootcamp/models/phrase.dart';
import 'package:bootcamp/pages/labels_page.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:bootcamp/helpers/globals.dart' as globals;

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

  bool isAndroid = UniversalPlatform.isAndroid;
  bool isIOS = UniversalPlatform.isIOS;
  bool labelChecked = false;

  final phrasesRepo = PhrasesRepo();
  final labelsRepo = LabelsRepo();
  var uuid = const Uuid();
  TextEditingController _phraseController = TextEditingController();
  TextEditingController _definitionController = TextEditingController();
  late int currentEditingPhraseId;
  TextEditingController _searchController = TextEditingController();

  int selectedPageColor = 1;

  loadPhrases() async {
    setState(() {
      isLoading = true;
    });

    await phrasesRepo.getPhrasesArchived(_searchController.text).then((value) {
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
    await phrasesRepo.getPhrasesByLabel(currentLabel).then((value) {
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
                  style: GoogleFonts.macondo(
                      color: kBlack, fontWeight: FontWeight.normal),
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
                    : (hasData
                        ? (Container(
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
                                  index: index,
                                  onTap: () {
                                    _showPhraseReader(context, phrase);
                                  },
                                  onLongPress: () {
                                    _showOptionsSheet(context, phrase);
                                  },
                                );
                              },
                            ),
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
                                  'empty!',
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
      endDrawer: Drawer(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: FlexColor.jungleDarkPrimary.lighten(5).withOpacity(0.5),
              ),
              padding: const EdgeInsets.only(left: 15, top: 56, bottom: 20),
              alignment: Alignment.center,
              child: Row(
                children: const [
                  Icon(Iconsax.filter),
                  SizedBox(
                    width: 32,
                  ),
                  Text(
                    'Filter Labels',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            if (labelsList.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Iconsax.tag,
                        size: 80,
                        color: FlexColor.amberDarkPrimaryVariant,
                      ),
                      const SizedBox(height: 20),
                      const Text('No labels created'),
                      TextButton(
                          onPressed: () {
                            openLabelEditor();
                          },
                          child: const Text('Create label')),
                    ],
                  ),
                ),
              ),
            if (labelsList.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    Label label = labelsList[index];
                    return ListTile(
                      onTap: (() {
                        setState(() {
                          currentLabel = label.name;
                          _filterPhrases();
                        });
                      }),
                      leading: const Icon(Iconsax.tag),
                      trailing:
                          (currentLabel.isEmpty || currentLabel != label.name)
                              ? const Icon(
                                  Icons.clear,
                                  color: Colors.transparent,
                                )
                              : const Icon(
                                  Icons.check_outlined,
                                  color: FlexColor.jungleDarkPrimary,
                                ),
                      title: Text(label.name),
                    );
                  },
                  itemCount: labelsList.length,
                ),
              ),
            if (labelsList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  tileColor: FlexColor.jungleDarkSecondary
                      .lighten(30)
                      .withOpacity(0.5),
                  trailing: const Icon(Iconsax.close_square),
                  title: const Text('Clear Filter'),
                  onTap: () {
                    setState(() {
                      currentLabel = "";
                      _filterPhrases();
                    });
                    Navigator.pop(context);
                  },
                  dense: true,
                ),
              ),
            if (labelsList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  tileColor:
                      FlexColor.amberDarkSecondary.lighten(10).withOpacity(0.5),
                  trailing: const Icon(Iconsax.tag),
                  title: const Text('Manage Labels'),
                  onTap: () {
                    Navigator.pop(context);
                    openLabelEditor();
                  },
                  dense: true,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void openLabelEditor() async {
    var res = await Navigator.of(context).push(CupertinoPageRoute(
        builder: (BuildContext context) => LabelsPage(
            phrase: Phrase(0, '', '', true, DateTime.now(), DateTime.now()))));
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

  void _showOptionsSheet(BuildContext context, Phrase _phrase) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = brightness == Brightness.dark;
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        constraints: const BoxConstraints(),
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                height: 480,
                child: Container(
                  child: Padding(
                    padding: kGlobalOuterPadding,
                    child: Column(
                      // mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            Navigator.of(context).pop();
                            setState(() {
                              _definitionController.text = _phrase.definition;
                              _phraseController.text = _phrase.phrase;
                              currentEditingPhraseId = _phrase.id;
                            });
                            _showEdit(context, _phrase);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: const <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Iconsax.edit_2),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Edit'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(15),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: const <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Iconsax.color_swatch),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Color Palette'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            Navigator.pop(context);
                            _assignLabel(_phrase);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: const <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Iconsax.tag),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Assign Labels'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _phrase.active,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              Navigator.of(context).pop();
                              setState(() {
                                currentEditingPhraseId = _phrase.id;
                              });
                              _deactivatePhrase();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: const <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Iconsax.archive_add),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Archive'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: !_phrase.active,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () {
                              Navigator.of(context).pop();
                              setState(() {
                                currentEditingPhraseId = _phrase.id;
                              });
                              _activatePhrase();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: const <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(Iconsax.archive_minus),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Unarchive'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            Navigator.of(context).pop();
                            setState(() {
                              currentEditingPhraseId = _phrase.id;
                            });
                            _confirmDelete();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: const <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Iconsax.note_remove),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: const <Widget>[
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(Iconsax.close_circle),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Cancel'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
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

  void _showEdit(BuildContext context, Phrase _phrase) async {
    final res = await Navigator.of(context).push(CupertinoPageRoute(
        builder: (BuildContext context) => EditPhrasePage(
              phrase: _phrase,
            )));

    if (res is Phrase) loadPhrases();
  }
}
