import 'package:url_launcher/url_launcher_string.dart';
import 'package:word_vault/common/constants.dart';
import 'package:word_vault/helpers/utility.dart';
import 'package:word_vault/models/internet_phrase.dart';
import 'package:word_vault/models/phrase.dart';
import 'package:word_vault/models/label.dart';
import 'package:word_vault/widgets/text_highlighter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:word_vault/helpers/globals.dart' as globals;

class InternetPhrasesList extends StatefulWidget {
  final List<InternetPhrase> phrasesList;
  final Function onTapCallback;
  const InternetPhrasesList(
      {Key? key, required this.phrasesList, required this.onTapCallback})
      : super(key: key);

  @override
  _InternetPhrasesListState createState() => _InternetPhrasesListState();
}

class _InternetPhrasesListState extends State<InternetPhrasesList> {
  int selectedInternetPhraseIndex = -1;
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
          minHeight: 50, minWidth: double.infinity, maxHeight: 400),
      child: widget.phrasesList.isEmpty
          ? const Text(
              "Unfortunately,\nnothing found :(",
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            )
          : ListView.separated(
              shrinkWrap: true,
              itemCount: widget.phrasesList.isEmpty
                  ? 1
                  : widget.phrasesList.length + 1,
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
                    widget.phrasesList[index].definition,
                    style: const TextStyle(
                      fontSize: 16,
                      color: kBlack,
                    ),
                  ),
                  subtitle: Column(children: [
                    if (widget.phrasesList[index].examples.isNotEmpty)
                      RichText(
                            textAlign: TextAlign.left,
                            text: TextSpan(
                              children: widget.phrasesList[index].examples.map((example) => 
                                WidgetSpan(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.symmetric(vertical: 4.0),
                                    child:
                                Text(
                                  example,
                                  style: TextStyle(fontSize: 14, color: kBlack, fontStyle: FontStyle.italic)
                                ))),
                              ).toList())
                      ),
                    if (widget.phrasesList[index].source.isNotEmpty)
                      Align(
                          alignment: Alignment.centerLeft,
                          child: InkWell(
                            onTap: () async {
                              String url = widget.phrasesList[index].source;
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
                    setState(() => selectedInternetPhraseIndex = index);
                    widget.onTapCallback.call(index);
                  },
                );
              },
            ),
    );
  }
}
