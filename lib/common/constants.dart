import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kPrimaryColor = Color(0xFF5EAAA8);
// linear-gradient(230deg, #a24bcf, #4b79cf, #4bc5cf)
const kBlack = Color(0xFF291F1F);
// const kWhite = Color(0xFFF5F5FA);
const kWhite = Color(0xFFFFFFFF);
const kGrey = Color(0xFF807F91);
const kGrey2 = Color(0xFF727272);
const kLightGrey = Color(0xFFe5e5e5);
const kLightGrey2 = Color(0xFFcbcbcb);
const kGreenSuccess = Color(0xFF4BB543);
const kGreenSuccess0 = Color(0xFF5eb543);
const kGreenSuccess2 = Color(0xFF43b558);

const kDarkGray = Color(0xFF727272);
const kYellow = Color(0xFFffdc58);
const kYellowDark = Color(0xFFFCD364);
const kYellowLight = Color(0xFFFFEBBD);
const kRed = Color(0xFFfa6911);
const kOrange = Color(0xFFF47A62);
const kLightBlue = Color(0xFFA8D8FF);
const kDarkBlue = Color(0xFF6699CC);
const kWhiteCream = Color(0xFFFFFADA);
const kTextColor = Color(0xFF757575);
const kBorderColor = Color(0xFF757575);
const kGlobalOuterPadding = EdgeInsets.all(10.0);
const kGlobalCardPadding = EdgeInsets.all(5.0);
const kGlobalTextPadding =
    EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0);

const kAppName = 'WordVault';

const kVSpace = SizedBox(
  height: 15.0,
);
const kHSpace = SizedBox(
  width: 10.0,
);

const phraseRatingEnum = [0, 50, 75, 87, 93, 97, 99, 100];

final kHeaderFont =
    GoogleFonts.quicksand(color: kBlack, fontWeight: FontWeight.w600);

const luminanceTreshhold =
    0.179; // https://stackoverflow.com/questions/3942878/how-to-decide-font-color-in-white-or-black-depending-on-background-color/3943023#3943023

const kCardColor1 = Color.fromARGB(255, 240, 202, 164);
const kCardColor2 = Color.fromARGB(255, 237, 135, 114);
const kCardColor3 = Color.fromARGB(255, 238, 236, 221);
const kCardColor4 = Color.fromARGB(255, 135, 188, 199);
const kCardColor5 = Color.fromARGB(255, 35, 89, 109);
const defaultPattern = [
  kCardColor1,
  kCardColor2,
  kCardColor3,
  kCardColor4,
  kCardColor5,
  kCardColor4,
  kCardColor3,
  kCardColor2
];

const kCardColor7 = Color(0xFF444C5C);
const kCardColor8 = Color(0xFFCE5A57);
const kCardColor9 = Color(0xFF78A5A3);
const kCardColor10 = Color(0xFFE1B16A);
const warmNCoolPattern = [
  kCardColor7,
  kCardColor8,
  kCardColor9,
  kCardColor10,
];

const kCardColor11 = Color(0xFFA49592);
const kCardColor12 = Color(0xFF727077);
const kCardColor13 = Color(0xFFEEd8C9);
const kCardColor14 = Color(0xFFE99787);
const smokyPurplePattern = [
  kCardColor11,
  kCardColor12,
  kCardColor13,
  kCardColor14,
];

const kCardColor15 = Color(0xFFB1D7D2);
const kCardColor16 = Color(0xFFE5E2CA);
const kCardColor17 = Color(0xFF432E33);
const kCardColor18 = Color(0xFFE7472E);
const distinctivePattern = [
  kCardColor15,
  kCardColor16,
  kCardColor17,
  kCardColor18,
];

const kCardColor19 = Color(0xFF2C4A52);
const kCardColor20 = Color(0xFF537072);
const kCardColor21 = Color(0xFF8E9B97);
const kCardColor22 = Color(0xFFF4EBDB);
const hazyGraysPattern = [
  kCardColor19,
  kCardColor20,
  kCardColor21,
  kCardColor22,
];

const kCardColor23 = Color(0xFF335252);
const kCardColor24 = Color(0xFFD4DDE1);
const kCardColor25 = Color(0xFFAA4B41);
const kCardColor26 = Color(0xFF2D3033);
const understatedPattern = [
  kCardColor23,
  kCardColor24,
  kCardColor25,
  kCardColor26,
];

const kCardColor27 = Color(0xFFA4CABC);
const kCardColor28 = Color(0xFFEAB364);
const kCardColor29 = Color(0xFFB2473E);
const kCardColor30 = Color(0xFFACBD78);
const mutedAntiquePattern = [
  kCardColor27,
  kCardColor28,
  kCardColor29,
  kCardColor30,
];
