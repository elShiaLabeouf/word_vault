import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:word_vault/common/constants.dart';
import 'package:word_vault/helpers/database/phrases_repo.dart';
import 'package:word_vault/models/phrase.dart';
import 'package:word_vault/pages/labels_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';
import 'package:intl/intl.dart';
import 'package:word_vault/helpers/globals.dart' as globals;
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:word_vault/widgets/phrases/internet_phrases_list.dart';

class PhraseReaderPage extends StatefulWidget {
  final Phrase phrase;
  final bool isEditing;
  final bool darkModeOn;
  const PhraseReaderPage(
      {Key? key, required this.phrase, this.isEditing = false, required this.darkModeOn})
      : super(key: key);

  @override
  _PhraseReaderPageState createState() => _PhraseReaderPageState();
}

class _PhraseReaderPageState extends State<PhraseReaderPage> {
  late Phrase phrase;
  final phrasesRepo = PhrasesRepo();
  ScrollController scrollController = ScrollController();
  final TextEditingController _phraseController = TextEditingController();
  final TextEditingController _definitionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _phraseFieldKey = GlobalKey<FormFieldState>();
  final _definitionFieldKey = GlobalKey<FormFieldState>();
  final _chosenInternetPhraseKey = GlobalKey<InternetPhrasesListState>();
  String phraseLabels = '';

  int selectedInternetPhraseIndex = -1;
  Color? _searchInternetIconColor;
  late int currentEditingPhraseId;
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

  void _savePhrase() async {
    setState(() {
      phrase = Phrase(
          currentEditingPhraseId,
          _phraseController.text,
          _definitionController.text,
          true,
          DateTime.now(),
          DateTime.now(),
          0,
          0);
    });
    late int id;
    if (_formKey.currentState!.validate()) {
      id = currentEditingPhraseId == 0
          ? await phrasesRepo.insertPhrase(phrase)
          : await phrasesRepo.updatePhrase(phrase);
    }
    if (id == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Failed to save. Perhaps you have the same phrase and definition pair already?'),
        duration: Duration(seconds: 5),
      ));
    }
    setState(() {
      phrase.id = id;
      currentEditingPhraseId = id;
    });
  }

  @override
  void initState() {
    phrase = widget.phrase;
    _phraseController.text = phrase.phrase;
    _definitionController.text = phrase.definition;
    currentEditingPhraseId = phrase.id;
    phraseLabels = phrase.labels ?? '';
    _searchInternetIconColor = widget.darkModeOn ? kGrey : kLightGrey;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = (globals.themeMode == ThemeMode.dark ||
        (brightness == Brightness.dark &&
            globals.themeMode == ThemeMode.system));
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: darkModeOn ? kBlack : Colors.white,
        appBar: AppBar(
          elevation: 0.2,
          backgroundColor: darkModeOn ? kBlack.withOpacity(0.9) : Colors.amber,
          leading: Container(
            margin: const EdgeInsets.all(8.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                Navigator.pop(context, true);
              },
              child: Icon(
                Iconsax.arrow_left_2,
                size: 15,
                color: darkModeOn ? kWhiteCream : kBlack,
              ),
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Save phrase',
              onPressed: () {
                _savePhrase();
              },
              color: darkModeOn ? kWhiteCream : kBlack,
              icon: const Icon(LineIcons.save),
            ),
            IconButton(
              tooltip: 'Manage labels',
              onPressed: phrase.isNewRecord()
                  ? null
                  : () {
                      _assignLabel(phrase);
                    },
              color: darkModeOn ? kWhiteCream : kBlack,
              icon: const Icon(Boxicons.bx_purchase_tag_alt),
            ),
            // Archive
            Visibility(
              visible: phrase.active,
              child: IconButton(
                tooltip: 'Archive',
                onPressed: phrase.id == 0
                    ? null
                    : () {
                        _setPhraseActive(active: false);
                      },
                color: darkModeOn ? kWhiteCream : kBlack,
                icon: const Icon(Boxicons.bx_archive_in),
              ),
            ),
            Visibility(
              visible: !phrase.active,
              child: IconButton(
                tooltip: 'Unarchive',
                onPressed: _setPhraseActive,
                color: darkModeOn ? kWhiteCream : kBlack,
                icon: const Icon(Boxicons.bx_archive_out),
              ),
            ),
            IconButton(
              tooltip: 'Delete',
              onPressed: phrase.isNewRecord() ? null : _confirmDelete,
              color: darkModeOn ? kWhiteCream : kBlack,
              icon: const Icon(Boxicons.bxs_trash),
            )
          ],
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(
                height: 10.0,
              ),
              Container(
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.centerLeft,
                child: TextFormField(
                  key: _phraseFieldKey,
                  autofocus: widget.isEditing,
                  controller: _phraseController,
                  minLines: 1,
                  maxLines: 3,
                  style: TextStyle(
                      color: darkModeOn ? kWhiteCream : kBlack,
                      fontSize: 30,
                      fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Phrase',
                    hintStyle: TextStyle(
                        color: darkModeOn ? kGrey2 : kLightGrey2,
                        fontSize: 30,
                        fontWeight: FontWeight.w700),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    filled: true,
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                    suffixIcon: InkWell(
                        child: Icon(MdiIcons.cloudSearch,
                            color: _searchInternetIconColor),
                        onTap: () {
                          if (_phraseController.text.isEmpty) return;

                          AwesomeDialog(
                            context: context,
                            dialogBackgroundColor: darkModeOn
                                ? kBlack.withOpacity(0.9)
                                : Colors.white,
                            dialogType: DialogType.noHeader,
                            animType: AnimType.bottomSlide,
                            body: InternetPhrasesList(
                              key: _chosenInternetPhraseKey,
                              query: _phraseController.text,
                              onTapCallback: (int selectedIndex) => setState(
                                  () => selectedInternetPhraseIndex =
                                      selectedIndex),
                            ),
                            btnOkText: "Copy&Paste",
                            btnOkOnPress: () {
                              _definitionController.text =
                                  _chosenInternetPhraseKey.currentState
                                          ?.selectedInternetPhrase ??
                                      '';
                            },
                            btnCancelOnPress: () {},
                          ).show();
                        }),
                  ),
                  onEditingComplete: _savePhrase,
                  onChanged: (_) {
                    _phraseFieldKey.currentState!.validate();
                    setState(
                      () => _searchInternetIconColor =
                          _phraseController.text.isEmpty
                              ? kLightGrey
                              : darkModeOn
                                  ? kWhiteCream
                                  : kBlack,
                    );
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Phrase can't be blank";
                    }
                    if (value.length > 50) {
                      return 'Phrase is too long';
                    }
                    return null;
                  },
                ),
              ),
              const Divider(
                thickness: 1.5,
                endIndent: 20,
                indent: 20,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.zero,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.centerLeft,
                  child: TextFormField(
                      key: _definitionFieldKey,
                      expands: true,
                      maxLines: null,
                      controller: _definitionController,
                      style: TextStyle(
                          color: darkModeOn ? kWhiteCream : kBlack,
                          fontSize: 20,
                          fontWeight: FontWeight.w400),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Definition',
                          hintStyle: TextStyle(
                              color: darkModeOn ? kGrey2 : kLightGrey2,
                              fontSize: 20,
                              fontWeight: FontWeight.w400),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          fillColor: Colors.transparent),
                      onEditingComplete: _savePhrase,
                      onChanged: (_) =>
                          _definitionFieldKey.currentState!.validate(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Definition can't be blank";
                        }
                        if (value.length > 200) {
                          return 'Definition is too long (${value.length}/200)';
                        }
                        return null;
                      }),
                ),
              ),
            ],
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
                    phraseLabels,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: darkModeOn ? kWhiteCream : kBlack,
                    ),
                  ),
                ),
                if (!phrase.isNewRecord())
                  Text(
                      "Created on ${DateFormat('MMM dd, yyyy, h:mm a').format(phrase.createdAt)}",
                      style: TextStyle(
                        color: darkModeOn ? kWhiteCream : kBlack,
                      )),
              ],
            ),
          ),
        ),
      ),
    );
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
              child: SizedBox(
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
      setState(() {
        phrase.labels = res;
        phraseLabels = res;
      });
    }
  }

  Future<bool> _onBackPressed() async {
    Navigator.pop(context, true);
    return false;
  }
}
