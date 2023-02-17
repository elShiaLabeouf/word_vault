import 'package:bootcamp/common/constants.dart';
import 'package:bootcamp/helpers/utility.dart';
import 'package:bootcamp/models/label.dart';
import 'package:bootcamp/pages/edit_phrase_page.dart';
import 'package:bootcamp/pages/phrase_reader_page.dart';
import 'package:bootcamp/widgets/home/labels_drawer.dart';
import 'package:bootcamp/widgets/phrase_card_list.dart';
import 'package:country_pickers/utils/utils.dart';
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

class MainHeader {
  FocusNode searchFocus = FocusNode();
  TextEditingController searchController = TextEditingController();
  final Function onSearchFieldChanged;
  final Function onSearchClose;
  final Function onSearchIconPressed;
  bool searchOpened;
  String? currentLocaleIso;
  MainHeader(
      {required this.onSearchIconPressed,
      required this.searchController,
      required this.searchFocus,
      required this.searchOpened,
      required this.onSearchFieldChanged,
      required this.onSearchClose,
      required this.currentLocaleIso});
  List<Widget> headerSliverBuilder(
      BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
        expandedHeight: 100,
        backgroundColor: Colors.amber.withOpacity(0.9),
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          title: Stack(children: [
            AnimatedOpacity(
                opacity: searchOpened ? 0 : 1,
                duration: const Duration(milliseconds: 100),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    'My Dictionary',
                    style: kHeaderFont,
                  ),
                )),
            AnimatedPositioned(
              curve: Curves.easeOut,
              left: 0,
              bottom: 0,
              width:
                  searchOpened ? MediaQuery.of(context).size.width - 170 : 50,
              duration: const Duration(milliseconds: 300),
              child: AnimatedOpacity(
                opacity: searchOpened ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.only(top: 5),
                  constraints:
                      const BoxConstraints(minHeight: 30, maxHeight: 30),
                  // width: 400,
                  child: CupertinoTextField(
                      controller: searchController,
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
                      focusNode: searchFocus,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white,
                      ),
                      style: const TextStyle(fontSize: 12),
                      suffix: GestureDetector(
                        onTap: () {
                          searchController.clear();
                          unfocusKeyboard(context);

                          onSearchClose.call();
                        },
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
                        onSearchFieldChanged.call(value);
                      }),
                ),
              ),
            ),
          ]),
          titlePadding: const EdgeInsets.only(left: 25, right: 25, bottom: 15),
        ),
        actions: [
          IconButton(
              onPressed: () {
                print("searchController.text ${searchController.text}");
                onSearchIconPressed.call();
                searchOpened = !searchOpened;

                if (!searchOpened) {
                  searchController.clear();
                  unfocusKeyboard(context);
                  onSearchClose();
                } else {
                  searchFocus.requestFocus();
                }
              },
              icon: const Icon(Boxicons.bx_search_alt)),
          IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: const Icon(Boxicons.bx_filter_alt)),
          currentLocaleIso != null
              ? InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(children: <Widget>[
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
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: CountryPickerUtils.getDefaultFlagImage(
                              CountryPickerUtils.getCountryByIsoCode(
                                  localeToCountryIso[
                                          currentLocaleIso?.split('_')[0]] ??
                                      ''))),
                    ]),
                  ),
                  onTap: () {
                    openVocabulariesPanel(context, (String newValue) { currentLocaleIso = newValue; });
                  })
              : IconButton(
                  onPressed: () {
                    openVocabulariesPanel(context, (String newValue) { currentLocaleIso = newValue; });
                  },
                  icon: const Icon(Boxicons.bx_category_alt)),
        ],
      ),
    ];
  }

  unfocusKeyboard(BuildContext context) {
    final FocusScopeNode currentScope = FocusScope.of(context);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  void openVocabulariesPanel(BuildContext context, Function callback) async {
    showDialog(
        context: context,
        builder: (context) =>
            Theme(data: Theme.of(context), child: VocabulariesPage(callback)));
  }
}
