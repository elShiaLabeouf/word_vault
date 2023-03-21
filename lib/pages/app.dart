import 'dart:ui';

import 'package:word_vault/common/constants.dart';
import 'package:word_vault/pages/quizzes_page.dart';
import 'package:word_vault/pages/home_page.dart';
import 'package:word_vault/pages/archived_page.dart';
import 'package:word_vault/pages/settings_page.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:word_vault/helpers/globals.dart' as globals;
import 'package:icofont_flutter/icofont_flutter.dart';
import 'package:flutter/cupertino.dart';

class WordVaultApp extends StatefulWidget {
  Function onThemeChanged;
  WordVaultApp({required this.onThemeChanged, Key? key}) : super(key: key);

  @override
  _WordVaultAppState createState() => _WordVaultAppState();
}

class _WordVaultAppState extends State<WordVaultApp> {
  late PageController _pageController;
  int _page = 0;

  late List<Widget> _pageList;

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    FocusScope.of(context).unfocus();
    _pageController.animateToPage(page,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  @override
  void initState() {
    super.initState();
    _pageList = <Widget>[
      const HomePage(),
      const QuizzesPage(),
      const ArchivedPage(),
      SettingsPage(onThemeChanged: widget.onThemeChanged),
    ];
    _pageController = PageController();
  }

  Future<bool> onWillPop() async {
    if (_pageController.page!.round() == _pageController.initialPage) {
      return true;
    } else {
      _pageController.jumpToPage(_pageController.initialPage);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = (globals.themeMode == ThemeMode.dark ||
        (brightness == Brightness.dark &&
            globals.themeMode == ThemeMode.system));
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: darkModeOn ? Colors.transparent : Colors.transparent,
      ),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: FlexColorScheme.themedSystemNavigationBar(
        context,
        systemNavBarStyle: FlexSystemNavBarStyle.background,
        useDivider: false,
        opacity: 0,
      ),
      child: WillPopScope(
        onWillPop: () => Future.sync(onWillPop),
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            double velocity = details.primaryVelocity ?? 0;
            if (velocity < 0 && _page < _pageList.length - 1) {
              navigationTapped(_page + 1);
            } else if (velocity > 0 && _page > 0) {
              navigationTapped(_page - 1);
            }
          },
          child: Scaffold(
            extendBodyBehindAppBar: true,
            body: PageView(
              physics: const NeverScrollableScrollPhysics(),
              children: _pageList,
              onPageChanged: onPageChanged,
              controller: _pageController,
            ),
            extendBody: true,
            bottomNavigationBar: ClipRRect(
              child: SizedBox(
                  height: 63,
                  child: Wrap(children: [
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                      child: BottomNavigationBar(
                        iconSize: 6,
                        selectedFontSize: 2,
                        elevation: 2,
                        backgroundColor: Colors.transparent,
                        selectedIconTheme: IconThemeData(
                            color: darkModeOn ? kWhiteCream : kBlack,
                            opacity: 1.0,
                            size: 30),
                        unselectedIconTheme: IconThemeData(
                            color: darkModeOn ? kWhiteCream : kBlack,
                            opacity: 0.5,
                            size: 20),
                        items: <BottomNavigationBarItem>[
                          BottomNavigationBarItem(
                            icon: Icon(
                              Iconsax.book,
                              shadows: <Shadow>[
                                Shadow(
                                    color: darkModeOn
                                        ? Colors.black
                                        : Colors.white,
                                    blurRadius: 15.0)
                              ],
                            ),
                            label: 'Vault',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(
                              IcoFontIcons.brainAlt,
                              shadows: <Shadow>[
                                Shadow(
                                    color: darkModeOn
                                        ? Colors.black
                                        : Colors.white,
                                    blurRadius: 15.0)
                              ],
                            ),
                            label: 'Quizzes',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(
                              CupertinoIcons.archivebox,
                              shadows: <Shadow>[
                                Shadow(
                                    color: darkModeOn
                                        ? Colors.black
                                        : Colors.white,
                                    blurRadius: 15.0)
                              ],
                            ),
                            label: 'Archive',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(
                              Icons.settings,
                              shadows: <Shadow>[
                                Shadow(
                                    color: darkModeOn
                                        ? Colors.black
                                        : Colors.white,
                                    blurRadius: 15.0)
                              ],
                            ),
                            label: 'Settings',
                          ),
                        ],
                        currentIndex: _page,
                        type: BottomNavigationBarType.fixed,
                        showSelectedLabels: false,
                        showUnselectedLabels: false,
                        onTap: navigationTapped,
                      ),
                    ),
                  ])),
            ),
          ),
        ),
      ),
    );
  }
}
