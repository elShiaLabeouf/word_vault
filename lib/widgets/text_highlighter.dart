import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class TextHighlighter extends StatelessWidget {
  const TextHighlighter(
      this.text, this.query, this.mainBgColor, this.textColor, this.maxLines,
      [this.textStyle]);
  final String text;
  final String? query;
  final Color mainBgColor;
  final Color textColor;
  final TextStyle? textStyle;
  final int maxLines;
  List<TextSpan> highlightOccurrences(String source, String? query,
      Color mainBgColor, Color textColor, TextStyle textStyle) {
    if (query == null ||
        query.isEmpty ||
        !source.toLowerCase().contains(query.toLowerCase())) {
      return [
        TextSpan(
            text: source,
            style: GoogleFonts.lato(textStyle: textStyle, color: textColor))
      ];
    }
    final matches = query.toLowerCase().allMatches(source.toLowerCase());

    int lastMatchEnd = 0;
    double luminanceTreshhold =
        0.179; // https://stackoverflow.com/questions/3942878/how-to-decide-font-color-in-white-or-black-depending-on-background-color/3943023#3943023
    final List<TextSpan> children = [];
    for (var i = 0; i < matches.length; i++) {
      final match = matches.elementAt(i);

      if (match.start != lastMatchEnd) {
        children.add(TextSpan(
            text: source.substring(lastMatchEnd, match.start),
            style: GoogleFonts.lato(textStyle: textStyle, color: textColor)));
      }

      children.add(TextSpan(
          text: source.substring(match.start, match.end),
          style: GoogleFonts.lato(
              textStyle: textStyle,
              color: textColor,
              backgroundColor:
                  mainBgColor.computeLuminance() > luminanceTreshhold
                      ? mainBgColor.darken(10)
                      : mainBgColor.lighten(10))));

      if (i == matches.length - 1 && match.end != source.length) {
        children.add(TextSpan(
            text: source.substring(match.end, source.length),
            style: GoogleFonts.lato(textStyle: textStyle, color: textColor)));
      }

      lastMatchEnd = match.end;
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: highlightOccurrences(text, query, mainBgColor, textColor,
            textStyle ?? TextStyle(color: textColor)),
        style: TextStyle(color: Colors.grey),
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
