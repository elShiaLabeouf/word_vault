import 'package:flutter/material.dart';
import 'package:word_vault/common/constants.dart';

class QuizAnswerBlock extends StatelessWidget {
  final String answerText;
  final Color answerColor;
  final answerTap;

  QuizAnswerBlock(
      {required this.answerText, required this.answerColor, this.answerTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: kDarkBlue.withOpacity(0.1),
      splashColor: kLightBlue.withOpacity(0.3),
      onTap: answerTap,
      child: Container(
        padding: const EdgeInsets.all(15.0),
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
        width: double.infinity,
        height: MediaQuery.of(context).size.height / 15,
        decoration: BoxDecoration(
          color: answerColor,
          // border: Border.all(color: kBlack, width: 1, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.16),
              blurRadius: 4,
              offset: Offset(0, 1),
            )
          ],
        ),
        child: Text(
          answerText,
          style: const TextStyle(
            fontSize: 15.0,
            color: kBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
