import 'package:flutter/material.dart';
import 'package:word_vault/common/constants.dart';
import 'package:word_vault/helpers/database/phrases_repo.dart';

class ConfirmDeleteModal {
  final phrasesRepo = PhrasesRepo();

  void render(
      BuildContext context, int currentEditingPhraseId, Function callback) {
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        constraints: const BoxConstraints(),
        builder: (context) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            child: Padding(
              padding: kGlobalOuterPadding,
              child: SizedBox(
                height: 160,
                child: Padding(
                  padding: kGlobalOuterPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: kGlobalCardPadding,
                        child: Text(
                          'Confirm',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const Padding(
                        padding: kGlobalCardPadding,
                        child: Text(
                            'Are you sure you want to delete this phrase?'),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: kGlobalCardPadding,
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('No'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: kGlobalCardPadding,
                              child: ElevatedButton(
                                onPressed: () {
                                  _deletePhrase(
                                      currentEditingPhraseId, callback);
                                  Navigator.pop(context, true);
                                },
                                child: const Text('Yes'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  void _deletePhrase(currentEditingPhraseId, callback) async {
    await phrasesRepo.deletePhrase(currentEditingPhraseId).then((value) {
      callback.call(currentEditingPhraseId);
    });
  }
}
