import 'dart:io';

import 'package:bootcamp/helpers/database/phrases_repo.dart';
import 'package:bootcamp/helpers/database/vocabularies_repo.dart';
import 'package:bootcamp/models/phrase.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class ExportXls {
  Future<void> callUsingExcelLibrary() async {
    VocabulariesRepo vocabulariesRepo = VocabulariesRepo();
    PhrasesRepo phrasesRepo = PhrasesRepo();

    Excel excel = Excel.createExcel();

    List<String> locales = await vocabulariesRepo.getAllVocabularies();
    final CellStyle headerStyle =
        CellStyle(backgroundColorHex: "#d3d3d3", fontSize: 14);
    final CellStyle mainStyle = CellStyle(fontSize: 12);

    for (int localeI = 0; localeI < locales.length; localeI++) {
      if (localeI == 0) {
        excel.rename('Sheet1', "LOCALE_${locales[localeI]}");
      }
      Sheet sheet = excel["LOCALE_${locales[localeI]}"];
      sheet.appendRow(['Phrase', 'Definition', 'Labels', 'Archived?']);
      sheet
          .selectRangeWithString('A1:D1')[0]
          ?.forEach((element) => element?.cellStyle = headerStyle);

      var phrases = await phrasesRepo.getPhrasesAll(locale: locales[localeI], active: [1, 0]);
      for (int phraseI = 0; phraseI < phrases.length; phraseI++) {
        Phrase phrase = phrases[phraseI];
        sheet.appendRow([
          phrase.phrase,
          phrase.definition,
          phrase.labels ?? '',
          phrase.active ? '' : 'Yes'
        ]);
        sheet
            .selectRangeWithString('A${phraseI + 2}:D${phraseI + 2}')[0]
            ?.forEach((element) => element?.cellStyle = mainStyle);
      }
      sheet.setColAutoFit(0);
      sheet.setColAutoFit(1);
      sheet.setColAutoFit(2);
    }

    excel.save();
    final List<int> fileBytes = excel.save() as List<int>;
    var directory = await getApplicationSupportDirectory();
    var path =
        "${directory.path}/vocabulary-backup-${DateTime.now().toIso8601String()}.xlsx";
    File file = File(path);
    await file.writeAsBytes(fileBytes, flush: true);
    Share.shareXFiles([XFile(path)], text: 'My Vocabulary backup');
  }
}
