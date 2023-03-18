import 'dart:io';

import 'package:word_vault/helpers/database/labels_repo.dart';
import 'package:word_vault/helpers/database/phrase_labels_repo.dart';
import 'package:word_vault/helpers/database/phrases_repo.dart';
import 'package:word_vault/helpers/database/vocabularies_repo.dart';
import 'package:word_vault/helpers/utility.dart';
import 'package:word_vault/models/phrase.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class ImportXls {
  Future<String> callUsingExcelLibrary() async {
    VocabulariesRepo vocabulariesRepo = VocabulariesRepo();
    PhrasesRepo phrasesRepo = PhrasesRepo();
    LabelsRepo labelsRepo = LabelsRepo();
    PhraseLabelsRepo phraseLabelsRepo = PhraseLabelsRepo();
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    int successCounter = 0;
    int totalPhraseCounter = 0;
    if (result != null) {
      var bytes = File(result.files.single.path as String).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      for (String locale in excel.tables.keys) {
        String localeName = locale.split('_')[1];
        if (localeToCountryIso[localeName] == null) continue;
        int vocabularyId =
            await vocabulariesRepo.findOrCreateVocabulary(localeName);
        for (int phraseI = 1;
            phraseI < excel.tables[locale]!.rows.length;
            phraseI++) {
          List<Data?> phraseEntry = excel.tables[locale]!.rows[phraseI];
          String phrase = phraseEntry[0]?.value.toString() ?? '';
          String definition = phraseEntry[1]?.value.toString() ?? '';
          String labels = phraseEntry[2]?.value.toString() ?? '';
          bool archived =
              phraseEntry[3]?.value.toString().toLowerCase() == 'yes';
          Phrase phraseRecord = Phrase(0, phrase, definition, !archived,
              DateTime.now(), DateTime.now(), vocabularyId, 0);
          int newPhraseId = await phrasesRepo.insertPhrase(phraseRecord);
          if (newPhraseId != 0 && labels != '') {
            labels.split(',').forEach((label) async {
              int labelId = await labelsRepo.findOrCreateLabel(label.trim());
              phraseLabelsRepo.insertPhraseLabel(newPhraseId, labelId);
            });
            successCounter++;
          }
          totalPhraseCounter++;
        }
      }
    } else {
      // User canceled the picker
    }

    return "Successfully imported $successCounter / $totalPhraseCounter phrases";
  }
}
