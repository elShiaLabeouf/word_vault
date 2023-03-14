import 'package:url_launcher/url_launcher_string.dart';
import 'package:word_vault/common/constants.dart';
import 'package:word_vault/helpers/utility.dart';
import 'package:word_vault/models/internet_phrase.dart';
import 'package:word_vault/models/phrase.dart';
import 'package:word_vault/models/label.dart';
import 'package:word_vault/services/lookup_internet_phrase.dart';
import 'package:word_vault/widgets/text_highlighter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:word_vault/helpers/globals.dart' as globals;

class InternetPhrasesList extends StatefulWidget {
  final Function onTapCallback;
  final String query;
  const InternetPhrasesList(
      {Key? key, required this.onTapCallback, required this.query})
      : super(key: key);

  @override
  InternetPhrasesListState createState() => InternetPhrasesListState();
}

class InternetPhrasesListState extends State<InternetPhrasesList> {
  int selectedInternetPhraseIndex = -1;
  String selectedInternetPhrase = '';
  List<InternetPhrase> phrasesList = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    searchInternet();
  }

  void searchInternet() async {
    await searchDictionaryApi();
    await searchWiktionary();
    await searchUrbandictionary();
  }

  searchDictionaryApi() async {
    var apiPhrasesList =
        await LookupInternetPhrase(source: "dictionaryapi").call(widget.query);
    setState(() => phrasesList.addAll(apiPhrasesList));
    isLoading = false;
  }

  searchWiktionary() async {
    var wiktionaryPhrasesList =
        await LookupInternetPhrase(source: "wiktionary").call(widget.query);
    setState(() => phrasesList.addAll(wiktionaryPhrasesList));
    isLoading = false;
  }

  searchUrbandictionary() async {
    var urbanPhrasesList = await LookupInternetPhrase(source: "urbandictionary")
        .call(widget.query);
    setState(() => phrasesList.addAll(urbanPhrasesList));
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 50, maxHeight: 400),
      child: isLoading
          ? const SizedBox(
              height: 50.0,
              width: 50.0,
              child: CircularProgressIndicator(),
            )
          : phrasesList.isEmpty
              ? const Text(
                  "Unfortunately,\nnothing found :(",
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: phrasesList.isEmpty ? 1 : phrasesList.length + 1,
                  separatorBuilder: (BuildContext context, int index) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        height: 0.5,
                        width: MediaQuery.of(context).size.width / 1.3,
                        child: Divider(),
                      ),
                    );
                  },
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const ListTile(
                          title: Text(
                        "Choose a definition you'd like to save:",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ));
                    }
                    index -= 1;
                    return ListTile(
                      tileColor: selectedInternetPhraseIndex == index
                          ? Colors.blue.shade50
                          : Colors.transparent,
                      title: Text(
                        phrasesList[index].definition,
                        style: const TextStyle(
                          fontSize: 16,
                          color: kBlack,
                        ),
                      ),
                      subtitle: Column(children: [
                        if (phrasesList[index].examples.isNotEmpty)
                          RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                  children: phrasesList[index]
                                      .examples
                                      .map(
                                        (example) => WidgetSpan(
                                            child: Container(
                                                alignment: Alignment.centerLeft,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4.0),
                                                child: Text(example,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: kBlack,
                                                        fontStyle: FontStyle
                                                            .italic)))),
                                      )
                                      .toList())),
                        if (phrasesList[index].source.isNotEmpty)
                          Align(
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                onTap: () async {
                                  String url = phrasesList[index].source;
                                  await launchUrlString(url,
                                      mode: LaunchMode.externalApplication);
                                },
                                focusColor: Colors.amber,
                                child: const Text('source',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 12,
                                    )),
                              ))
                      ]),
                      onTap: () {
                        setState(() {
                          selectedInternetPhraseIndex = index;
                          selectedInternetPhrase =
                              phrasesList[index].definition;
                        });
                        widget.onTapCallback.call(index);
                      },
                    );
                  },
                ),
    );
  }
}
