import 'package:word_vault/common/constants.dart';
import 'package:word_vault/pages/app.dart';
import 'package:word_vault/common/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/globals.dart' as globals;

late SharedPreferences prefs;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.system;

  @override
  void initState() {
    getprefs();
    super.initState();
  }

  getprefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getInt('themeMode') != null) {
        switch (prefs.getInt('themeMode')) {
          case 0:
            themeMode = ThemeMode.light;
            break;
          case 1:
            themeMode = ThemeMode.dark;
            break;
          case 2:
            themeMode = ThemeMode.system;
            break;
          default:
            themeMode = ThemeMode.system;
            break;
        }
      } else {
        themeMode = ThemeMode.system;
        prefs.setInt('themeMode', 2);
      }
      globals.themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: theme(),
      darkTheme: themeDark(),
      home: StartPage(onThemeChanged: (ThemeMode newThemeMode) {
        setState(() {
          themeMode = newThemeMode;
        });
      }),
    );
  }
}

class StartPage extends StatefulWidget {
  final Function onThemeChanged;
  const StartPage({required this.onThemeChanged, Key? key}) : super(key: key);

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  getPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  WordVaultApp(onThemeChanged: widget.onThemeChanged)),
          (Route<dynamic> route) => false);
    });
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
