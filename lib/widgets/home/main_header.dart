import 'package:word_vault/common/constants.dart';
import 'package:word_vault/helpers/utility.dart';
import 'package:word_vault/widgets/home/first_time_rating_opened_dialog.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:word_vault/pages/vocabularies_page.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainHeader {
  FocusNode searchFocus = FocusNode();
  TextEditingController searchController = TextEditingController();
  final Function onSearchFieldChanged;
  final Function onSearchClose;
  final Function onSearchIconPressed;
  final Function onLocaleChange;
  final Function onRatingBtnPressed;
  bool searchOpened;
  bool ratingOpened;
  String? currentLocaleIso;
  bool headerMinimized = false;
  String avgRating;
  final bool darkModeOn;
  late Widget _currentFlag;

  MainHeader(
      {required this.onSearchIconPressed,
      required this.searchController,
      required this.searchFocus,
      required this.searchOpened,
      required this.onSearchFieldChanged,
      required this.onSearchClose,
      required this.onRatingBtnPressed,
      required this.ratingOpened,
      required this.avgRating,
      required this.onLocaleChange,
      required this.currentLocaleIso,
      required this.headerMinimized,
      required this.darkModeOn});

  firstTimeOpenedRating() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('rating_mode_popup_dismissed') == null) {
      prefs.setBool('rating_mode_popup_dismissed', false);
      return true;
    }
    return false;
  }

  void openFirstTimeOpenedRatingDialog(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('rating_mode_popup_dismissed') ?? false) return;
    FirstTimeRatingOpenedDialog(context: context).render();
  }

  List<Widget> headerSliverBuilder(
      BuildContext context, bool innerBoxIsScrolled) {
    if (currentLocaleIso != null) {
      _currentFlag = CountryPickerUtils.getDefaultFlagImage(
          CountryPickerUtils.getCountryByIsoCode(
              localeToCountryIso[currentLocaleIso?.split('_')[0]] ?? ''));
    }

    return <Widget>[
      SliverAppBar(
        expandedHeight: 100,
        backgroundColor: darkModeOn
            ?  kBlack.withOpacity(0.9)
            : Colors.amber.withOpacity(0.9),
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          title: Stack(children: [
            AnimatedOpacity(
                opacity: searchOpened ? 0 : 1,
                duration: const Duration(milliseconds: 100),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    ratingOpened ? 'My rating: $avgRating' : 'My Vault',
                    style: darkModeOn ? kHeaderFontDark : kHeaderFont,
                  ),
                )),
            AnimatedPositioned(
              curve: Curves.easeOut,
              left: 0,
              bottom: 0,
              width: searchOpened
                  ? headerMinimized
                      ? (MediaQuery.of(context).size.width - 170 - 45)
                      : MediaQuery.of(context).size.width - 170
                  : 50,
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
                      prefix: Padding(
                        padding: const EdgeInsets.fromLTRB(6, 2, 0, 0),
                        child: Icon(
                          size: 14,
                          Icons.search,
                          color: darkModeOn ? Colors.white : kBlack,
                        ),
                      ),
                      focusNode: searchFocus,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: darkModeOn ? kBlack : Colors.white,
                      ),
                      style: TextStyle(fontSize: 12, color: darkModeOn ? kWhite : kBlack),
                      suffix: GestureDetector(
                        onTap: () {
                          searchController.clear();
                          unfocusKeyboard(context);

                          onSearchClose.call();
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 2, 6, 2),
                          child: Icon(
                            Boxicons.bx_x,
                            size: 16.0,
                            color: darkModeOn ? Colors.white : kBlack,
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
          titlePadding: const EdgeInsets.only(left: 25, bottom: 15, right: 25),
        ),
        actions: [
          IconButton(
              onPressed: () {
                openFirstTimeOpenedRatingDialog(context);
                onRatingBtnPressed.call();
              },
              icon: Icon(Boxicons.bxs_graduation, color: darkModeOn ? kWhiteCream : kBlack,)),
          IconButton(
              onPressed: () {
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
              icon: Icon(Boxicons.bx_search_alt, color: darkModeOn ? kWhiteCream : kBlack)),
          IconButton(
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: Icon(Boxicons.bx_filter_alt, color: darkModeOn ? kWhiteCream : kBlack)),
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
                              offset: const Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: _currentFlag,
                      )
                    ]),
                  ),
                  onTap: () {
                    openVocabulariesPanel(context, (String? newValue) {
                      onLocaleChange.call(newValue);

                      _currentFlag = CountryPickerUtils.getDefaultFlagImage(
                          CountryPickerUtils.getCountryByIsoCode(
                              localeToCountryIso[newValue?.split('_')[0]] ??
                                  ''));
                    });
                  })
              : IconButton(
                  onPressed: () {
                    openVocabulariesPanel(context, (String newValue) {
                      onLocaleChange.call(newValue);
                    });
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
    showGeneralDialog(
      context: context,
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: VocabulariesPage(callback),
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 200),
      pageBuilder: (context, animation1, animation2) {
        return VocabulariesPage(callback);
      },
    );
  }
}
