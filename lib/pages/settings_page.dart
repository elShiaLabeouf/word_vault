import 'dart:convert';
import 'dart:typed_data';

import 'package:bootcamp/common/constants.dart';
import 'package:bootcamp/helpers/export_xls.dart';
import 'package:bootcamp/helpers/import_xls.dart';
import 'package:bootcamp/helpers/utility.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:bootcamp/helpers/globals.dart' as globals;
import 'package:google_fonts/google_fonts.dart';
import 'labels_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SharedPreferences sharedPreferences;
  late String username;
  late String useremail;
  Uint8List? avatarData;

  getPref() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      username = sharedPreferences.getString('nc_userdisplayname') ?? '';
      useremail = sharedPreferences.getString('nc_useremail') ?? '';
      avatarData = base64Decode(sharedPreferences.getString('nc_avatar') ?? '');
    });
  }

  @override
  void initState() {
    getPref();
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
                  'Settings',
                  style: kHeaderFont,
                ),
                titlePadding: EdgeInsets.only(left: 30, bottom: 15),
              ),
            ),
          ];
        },
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
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
                              'Export dictionary',
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
                              'Import dictionary',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text('of .xlsx format'),
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
