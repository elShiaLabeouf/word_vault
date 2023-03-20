import 'package:word_vault/models/internet_phrase.dart';
import 'package:word_vault/services/dictionaryapi_service.dart';
import 'package:word_vault/services/urbandictionary_service.dart';
import 'package:word_vault/services/wiktionary_service.dart';

class LookupInternetPhrase {
  final String source;

  LookupInternetPhrase({required this.source});
  Future<List<InternetPhrase>> call(query) async {
    List<InternetPhrase> iPhrases = [];
    switch (source) {
      case "wiktionary":
        try {
          iPhrases.addAll(await WiktionaryService().get(query));
        } catch (e) {
          // print(e.toString());
        }
        break;
      case "urbandictionary":
        try {
          iPhrases.addAll(await UrbandictionaryService().get(query));
        } catch (e) {
          // print(e.toString());
        }
        break;
      case "dictionaryapi":
        try {
          iPhrases.addAll(await DictionaryapiService().get(query));
        } catch (e) {
          // print(e.toString());
        }
        break;
    }

    return iPhrases;
  }
}
