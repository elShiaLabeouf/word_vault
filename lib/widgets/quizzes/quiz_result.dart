import 'package:flutter/material.dart';
import 'package:bootcamp/common/constants.dart';

class QuizResult extends StatelessWidget {
  const QuizResult({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      // backgroundColor: Colors.limeAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      child: Container(
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "You've scored _totalScore/{_phrasesList.length}, here's a cake for you:",
              style: TextStyle(fontSize: 20),
            ),
            const FlutterLogo(
              size: 150,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Awesome!"))
          ],
        ),
      ),
    );
  }
}
