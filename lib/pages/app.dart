import 'package:animations/animations.dart';
import 'package:word_vault/common/string_values.dart';
import 'package:word_vault/common/constants.dart';
import 'package:word_vault/pages/quizzes_page.dart';
import 'package:word_vault/pages/home_page.dart';
import 'package:word_vault/pages/archived_page.dart';
import 'package:word_vault/pages/settings_page.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:word_vault/helpers/globals.dart' as globals;
import 'package:icofont_flutter/icofont_flutter.dart';
import 'package:flutter/cupertino.dart';

enum ViewType { Tile, Grid }

class WordVaultApp extends StatefulWidget {
  const WordVaultApp({Key? key}) : super(key: key);

  @override
  _WordVaultAppState createState() => _WordVaultAppState();
}

class _WordVaultAppState extends State<WordVaultApp> {
  late SharedPreferences sharedPreferences;
  ViewType viewType = ViewType.Tile;
  bool isAppLogged = false;
  String appPin = "";
  bool openNav = false;

  late PageController _pageController;
  int _page = 0;

  final _pageList = <Widget>[
    HomePage(title: kAppName),
    QuizzesPage(),
    ArchivedPage(),
    SettingsPage(),
  ];

  String username = '';

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  getPref() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      username = sharedPreferences.getString('nc_userdisplayname') ?? '';
    });
  }

  void navigationTapped(int page) {
    _pageController.animateToPage(page,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  @override
  void initState() {
    super.initState();
    getPref();
    _pageController = PageController();
  }

  Future<bool> onWillPop() async {
    if (_pageController.page!.round() == _pageController.initialPage) {
      sharedPreferences.setBool("is_app_unlocked", false);
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
        child: Scaffold(
          extendBodyBehindAppBar: true,
          body: PageView(
            physics: const NeverScrollableScrollPhysics(),
            children: _pageList,
            onPageChanged: onPageChanged,
            controller: _pageController,
          ),
          bottomNavigationBar: BottomNavigationBar(
            selectedIconTheme:
                const IconThemeData(color: kBlack, opacity: 1.0, size: 30),
            unselectedIconTheme:
                const IconThemeData(color: kBlack, opacity: 0.5, size: 20),
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Iconsax.book),
                label: kLabelNotes,
              ),
              BottomNavigationBarItem(
                icon: Icon(IcoFontIcons.brainAlt),
                label: kLabelArchive,
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.archivebox),
                label: kLabelSearch,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: kLabelMore,
              ),
            ],
            currentIndex: _page,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            onTap: navigationTapped,
          ),
        ),
      ),
    );
  }
}
