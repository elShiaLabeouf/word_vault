import 'dart:convert';
import 'dart:typed_data';

import 'package:bootcamp/common/constants.dart';
import 'package:bootcamp/helpers/utility.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Settings',
                  style: GoogleFonts.macondo(
                      color: kBlack, fontWeight: FontWeight.normal),
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
                            // final res = await Navigator.of(context).push(
                            //     CupertinoPageRoute(
                            //         builder: (context) => BackupRestorePage()));
                            // if (res == "yes") {
                            //   // loadNotes();
                            // }
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              // backgroundColor: Colors.teal[100],
                              // foregroundColor: Colors.teal,
                              child: Icon(Iconsax.document_download),
                            ),
                            title: Text(
                              'Export dictionary',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(''),
                          ),
                        ),
                      ),
                      Padding(
                        padding: kGlobalCardPadding,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10.0),
                          onTap: () async {
                            // final res = await Navigator.of(context).push(
                            //     CupertinoPageRoute(
                            //         builder: (context) => BackupRestorePage()));
                            // if (res == "yes") {
                            //   // loadNotes();
                            // }
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              // backgroundColor: Colors.teal[100],
                              // foregroundColor: Colors.teal,
                              child: Icon(Iconsax.document_download),
                            ),
                            title: Text(
                              'Import dictionary',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(''),
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
