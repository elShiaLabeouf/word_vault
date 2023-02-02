import 'dart:async';
import 'package:bootcamp/common/constants.dart';
import 'package:flutter/material.dart';
import 'package:bootcamp/models/phrase.dart';
import 'package:bootcamp/helpers/database/phrases_repo.dart';
import 'package:bootcamp/pages/tests/guess_it_test_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:iconsax/iconsax.dart';
class TestingPage extends StatefulWidget {
  TestingPage({Key? key})
      : super(key: key);

  @override
  _TestingPageState createState() => _TestingPageState();
}

class _TestingPageState extends State<TestingPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final phrasesRepo = PhrasesRepo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            const SliverAppBar(
              expandedHeight: 100.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Choose test:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
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
                          onTap: () {
                            Navigator.of(context).push(CupertinoPageRoute(
                                builder: (context) => DefineItTestPage()
                                ));
                          },
                          child: const ListTile(
                            leading: CircleAvatar(
                              child: Icon(Iconsax.activity),
                            ),
                            title: Text(
                              'Explain it',
                              style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            subtitle: Text('Write the definition to a given phrase',),
                          )
                        ),
                      ),
                      Padding(
                        padding: kGlobalCardPadding,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10.0),
                          onTap: () {
                            Navigator.of(context).push(CupertinoPageRoute(
                                builder: (context) => GuessItTestPage()
                                ));
                          },
                          child: const ListTile(
                            leading: CircleAvatar(
                              child: Icon(Iconsax.activity),
                            ),
                            title: Text(
                              'Guess the word',
                              style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            subtitle: Text('Write the word by its definition',),
                          )
                        ),
                      )
                    ]),
                  )
              ],
            )
          )
        )
      )
    );
  }
}
