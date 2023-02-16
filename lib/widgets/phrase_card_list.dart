import 'package:bootcamp/common/constants.dart';
import 'package:bootcamp/helpers/utility.dart';
import 'package:bootcamp/models/phrase.dart';
import 'package:bootcamp/models/label.dart';
import 'package:bootcamp/widgets/text_highlighter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bootcamp/helpers/globals.dart' as globals;

class PhraseCardList extends StatefulWidget {
  final Phrase? phrase;
  final int index;
  final Function onTap;
  final Function? onLongPress;
  final String? searchText;
  const PhraseCardList(
      {Key? key,
      this.phrase,
      this.index = 0,
      required this.onTap,
      this.onLongPress,
      this.searchText})
      : super(key: key);

  @override
  _PhraseCardListState createState() => _PhraseCardListState();
}

class _PhraseCardListState extends State<PhraseCardList> {
  Offset _tapPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool darkModeOn = (globals.themeMode == ThemeMode.dark ||
        (brightness == Brightness.dark &&
            globals.themeMode == ThemeMode.system));
    Color cardBGColor = kCardColors[widget.index % kCardColors.length][0];
    Color cardTextColor = kCardColors[widget.index % kCardColors.length][1];
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Card(
        color: cardBGColor,
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
                    child: widget.searchText == null ||
                            widget.searchText!.isEmpty
                        ? Text(widget.phrase!.phrase,
                            style: GoogleFonts.lato(
                                textStyle:
                                    Theme.of(context).textTheme.headlineMedium,
                                color: cardTextColor))
                        : TextHighlighter(
                            widget.phrase!.phrase,
                            widget.searchText,
                            cardBGColor,
                            cardTextColor,
                            1,
                            Theme.of(context).textTheme.headlineMedium),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: widget.searchText == null || widget.searchText!.isEmpty
                      ? Text(
                          widget.phrase!.definition,
                          style: TextStyle(
                            color: cardTextColor,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        )
                      : TextHighlighter(widget.phrase!.definition,
                          widget.searchText, cardBGColor, cardTextColor, 4),
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
                          style: TextStyle(
                            color: cardTextColor,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          DateFormat('MMM dd, yyyy')
                              .format(widget.phrase!.createdAt),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: cardTextColor,
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
