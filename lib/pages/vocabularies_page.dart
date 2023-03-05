import 'dart:async';

import 'package:word_vault/helpers/database/labels_repo.dart';
import 'package:word_vault/helpers/database/phrase_labels_repo.dart';
import 'package:word_vault/helpers/database/vocabularies_repo.dart';
import 'package:word_vault/models/label.dart';
import 'package:word_vault/models/phrase.dart';
import 'package:word_vault/widgets/small_appbar.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:country_pickers/country_picker_dialog.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:language_picker/languages.dart';
import 'package:language_picker/language_picker.dart';
import 'package:country_pickers/country_picker_dialog.dart';
import 'package:word_vault/helpers/utility.dart';
import 'package:word_vault/common/constants.dart';

class VocabulariesPage extends StatefulWidget {
  // final Phrase phrase;
  final Function callback;
  const VocabulariesPage(this.callback, {Key? key}) : super(key: key);
  @override
  _VocabulariesPageState createState() => _VocabulariesPageState();
}

class _VocabulariesPageState extends State<VocabulariesPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late SharedPreferences sharedPreferences;
  List<Map<String, Object?>> entryCount = [];
  @override
  void initState() {
    super.initState();
    getPrefs();
    getEntryCount();
  }

  void getPrefs() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  void getEntryCount() async {
    VocabulariesRepo vocabulariesRepo = VocabulariesRepo();
    vocabulariesRepo.getWordsCount().then((value) {
      setState(() {
        entryCount = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> priorityList = [
      'en',
      'uk',
      'fr',
      'es',
      'pt',
      'de',
      'ja',
      'zh_Hans',
      'zh_Hant',
      'hi',
      'ar'
    ];
    List<Map<String, String>> languagesList =
        defaultLanguagesList.where((language) {
      try {
        String countryIso =
            localeToCountryIso[language['isoCode']!.split('_')[0]] ?? '';
        Country c = CountryPickerUtils.getCountryByIsoCode(countryIso);
        CountryPickerUtils.getDefaultFlagImage(c);
        return true;
      } catch (e) {
        return false;
      }
    }).toList();

    priorityList.forEach((String isoCode) {
      final toRemove = languagesList.firstWhere(
          (Map<String, String> country) => country['isoCode'] == isoCode);
      languagesList.remove(toRemove);
      languagesList.insert(priorityList.indexOf(isoCode), toRemove);
    });

    return LanguagePickerDialog(
        titlePadding: EdgeInsets.all(8.0),
        searchCursorColor: kBlack,
        searchInputDecoration: InputDecoration(
            hintText: 'Search...',
            contentPadding: EdgeInsets.symmetric(horizontal: 8.0)),
        isSearchable: true,
        languagesList: languagesList,
        title: Text('Select Vault profile'),
        onValuePicked: (Language language) {
          sharedPreferences.setString("current_vocabulary", language.isoCode);
          widget.callback.call(language.isoCode);
        },
        itemBuilder: _buildDialogItem);
  }

  Widget _buildDialogItem(Language language) {
    int count = entryCount.firstWhere(
        (element) => element['locale'] == language.isoCode,
        orElse: () => {'count': 0})['count'] as int;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.33),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: CountryPickerUtils.getDefaultFlagImage(
              CountryPickerUtils.getCountryByIsoCode(
                  localeToCountryIso[language.isoCode.split('_')[0]] ?? '')),
        ),
        SizedBox(
          width: 8,
        ),
        Expanded(
            child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(language.name, maxLines: 1)))),
        SizedBox(
          width: 8,
        ),
        if (count > 0)
          Text(
            "$count phrase${count > 1 ? 's' : ''}",
            style: TextStyle(color: kGrey),
          ),
      ],
    );
  }

  Future<bool> _onBackPressed() async {
    Navigator.pop(context, null);
    return true;
  }
}
