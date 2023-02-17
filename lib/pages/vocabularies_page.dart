import 'dart:async';

import 'package:bootcamp/helpers/database/labels_repo.dart';
import 'package:bootcamp/helpers/database/phrase_labels_repo.dart';
import 'package:bootcamp/models/label.dart';
import 'package:bootcamp/models/phrase.dart';
import 'package:bootcamp/widgets/small_appbar.dart';
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
import 'package:bootcamp/helpers/utility.dart';
import 'package:bootcamp/common/constants.dart';

class VocabulariesPage extends StatefulWidget {
  // final Phrase phrase;
  final Function callback;
  const VocabulariesPage(this.callback, {Key? key}) : super(key: key);
  @override
  _VocabulariesPageState createState() => _VocabulariesPageState();
}

class _VocabulariesPageState extends State<VocabulariesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    getPrefs();
  }

  void getPrefs() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  void getAvailableVocabularies() async {}

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
        searchInputDecoration: InputDecoration(hintText: 'Search...'),
        isSearchable: true,
        languagesList: languagesList,
        title: Text('Select vocabulary profile'),
        onValuePicked: (Language language) {
            sharedPreferences.setString("current_vocabulary", language.isoCode);
            widget.callback.call(language.isoCode);
        },
        itemBuilder: _buildDialogItem);
  }

  Widget _buildDialogItem(Language language) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          CountryPickerUtils.getDefaultFlagImage(
              CountryPickerUtils.getCountryByIsoCode(
                  localeToCountryIso[language.isoCode.split('_')[0]] ?? '')),
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
          Text(
            "321 phrases",
            style: TextStyle(color: kGrey),
          ),
        ],
      );

  Future<bool> _onBackPressed() async {
    Navigator.pop(context, null);
    return true;
  }
}
