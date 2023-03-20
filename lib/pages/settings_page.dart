import 'package:day_night_switcher/day_night_switcher.dart';
import 'package:word_vault/common/constants.dart';
import 'package:word_vault/services/export_xls.dart';
import 'package:word_vault/services/import_xls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_vault/helpers/globals.dart' as globals;

class SettingsPage extends StatefulWidget {
  final Function onThemeChanged;

  const SettingsPage({required this.onThemeChanged, super.key});
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
              expandedHeight: 100.0,
              backgroundColor: darkModeOn
                  ? kBlack.withOpacity(0.9)
                  : Colors.amber.withOpacity(0.9),
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('Settings',
                    style: darkModeOn ? kHeaderFontDark : kHeaderFont),
                titlePadding: const EdgeInsets.only(left: 30, bottom: 15),
              ),
            ),
          ];
        },
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: kGlobalOuterPadding,
                  child: Column(
                    children: [
                      Padding(
                        padding: kGlobalCardPadding,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10.0),
                          onTap: () async {
                            await ExportXls().callUsingExcelLibrary();
                          },
                          child: const ListTile(
                            leading: CircleAvatar(
                              // backgroundColor: Colors.teal[100],
                              // foregroundColor: Colors.teal,
                              child: Icon(Boxicons.bx_export),
                            ),
                            title: Text(
                              'Export your vault',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text('as .xlsx document'),
                          ),
                        ),
                      ),
                      Padding(
                        padding: kGlobalCardPadding,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10.0),
                          onTap: () async {
                            await ImportXls()
                                .callUsingExcelLibrary()
                                .then((String stringResult) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                backgroundColor: kGreenSuccess,
                                behavior: SnackBarBehavior.floating,
                                content: Text(stringResult),
                                duration: const Duration(seconds: 5),
                              ));
                            });
                          },
                          child: const ListTile(
                            leading: CircleAvatar(
                              // backgroundColor: Colors.teal[100],
                              // foregroundColor: Colors.teal,
                              child: Icon(Boxicons.bx_import),
                            ),
                            title: Text(
                              'Import vault',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text('of .xlsx format'),
                          ),
                        ),
                      ),
                      Padding(
                        padding: kGlobalCardPadding,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10.0),
                          onTap: () async {
                            var isDarkModeEnabled = globals.themeMode == ThemeMode.dark;
                            setState(() {
                              globals.themeMode = isDarkModeEnabled
                                  ? ThemeMode.light
                                  : ThemeMode.dark;
                              SharedPreferences.getInstance().then(
                                  (prefs) => prefs.setInt('themeMode',
                                      isDarkModeEnabled ? 0 : 1));
                              widget.onThemeChanged.call(isDarkModeEnabled
                                  ? ThemeMode.light
                                  : ThemeMode.dark);
                            });
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              child: DayNightSwitcherIcon(
                                padding: const EdgeInsets.all(0),
                                isDarkModeEnabled: darkModeOn,
                                onStateChanged: (isDarkModeEnabled) {
                                  setState(() {
                                    globals.themeMode = isDarkModeEnabled
                                        ? ThemeMode.dark
                                        : ThemeMode.light;
                                    SharedPreferences.getInstance().then(
                                        (prefs) => prefs.setInt('themeMode',
                                            isDarkModeEnabled ? 1 : 0));
                                    widget.onThemeChanged.call(isDarkModeEnabled
                                        ? ThemeMode.dark
                                        : ThemeMode.light);
                                  });
                                },
                              ),
                            ),
                            title: const Text(
                              'Day/night mode',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
