import 'package:bootcamp/common/constants.dart';
import 'package:bootcamp/helpers/utility.dart';
import 'package:bootcamp/models/phrase.dart';
import 'package:bootcamp/models/label.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bootcamp/helpers/globals.dart' as globals;
import "dart:math";

class PhraseCardList extends StatefulWidget {
  final Phrase? phrase;
  final int index;
  final Function onTap;
  final Function? onLongPress;
  const PhraseCardList(
      {Key? key, this.phrase, this.index = 0, required this.onTap, this.onLongPress})
      : super(key: key);

  @override
  _PhraseCardListState createState() => _PhraseCardListState();
}

class _PhraseCardListState extends State<PhraseCardList> {
  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = (globals.themeMode == ThemeMode.dark ||
        (brightness == Brightness.dark &&
            globals.themeMode == ThemeMode.system));
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Card(
        color: kCardColors[widget.index % kCardColors.length],
        child: InkWell(
          onTap: () => widget.onTap(),
          onLongPress: () => widget.onLongPress!(),
          child: Padding(
            padding: kGlobalCardPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: widget.phrase!.phrase.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      widget.phrase!.phrase,
                      style: GoogleFonts.lato(textStyle: Theme.of(context).textTheme.headlineMedium)
                      // style: TextStyle(
                      //   fontFamily: "Lato",
                      //   fontSize: 16.0,
                      //   color: Colors.black,
                      // ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    widget.phrase!.definition,
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),                
                Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.phrase!.labels ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          DateFormat('MMM dd, yyyy').format(widget.phrase!.createdAt),                          
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12.0,
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
