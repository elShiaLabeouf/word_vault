import 'package:word_vault/common/constants.dart';
import 'package:word_vault/models/phrase.dart';
import 'package:word_vault/widgets/text_highlighter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:word_vault/helpers/globals.dart' as globals;

class PhraseCardList extends StatefulWidget {
  final Phrase? phrase;
  final int index;
  final Function onTap;
  final Function? onLongPress;
  final String? searchText;
  final bool ratingOpened;
  final bool darkModeOn;
  const PhraseCardList(
      {Key? key,
      this.phrase,
      this.index = 0,
      required this.onTap,
      this.onLongPress,
      this.searchText,
      this.darkModeOn = false,
      required this.ratingOpened})
      : super(key: key);

  @override
  _PhraseCardListState createState() => _PhraseCardListState();
}

class _PhraseCardListState extends State<PhraseCardList> {

  @override
  Widget build(BuildContext context) {
    Color cardBGColor = widget.darkModeOn 
      ? warmNCoolPattern[widget.index % warmNCoolPattern.length] 
      : defaultPattern[widget.index % defaultPattern.length];
    Color cardTextColor =
        cardBGColor.computeLuminance() > luminanceTreshhold ? kBlack : kWhite;
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, top: 5),
                        child: widget.searchText == null ||
                                widget.searchText!.isEmpty
                            ? Text(widget.phrase!.phrase,
                                style: GoogleFonts.lato(
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                  color: cardTextColor,
                                ))
                            : TextHighlighter(
                                widget.phrase!.phrase,
                                widget.searchText,
                                cardBGColor,
                                cardTextColor,
                                1,
                                Theme.of(context).textTheme.headlineMedium),
                      ),
                    ),
                    if (widget.ratingOpened)
                      Padding(
                          padding: const EdgeInsets.only(top: 5, right: 5),
                          child: Text(
                            "Rating: ${phraseRatingEnum[widget.phrase!.rating]}",
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: cardTextColor,
                              fontSize: 12.0,
                            ),
                          )),
                  ],
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
