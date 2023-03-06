import 'package:word_vault/models/internet_phrase.dart';
import 'package:word_vault/services/dictionaryapi_service.dart';
import 'package:word_vault/services/urbandictionary_service.dart';
import 'package:word_vault/services/wiktionary_service.dart';

class LookupInternetPhrase {
  Future<List<InternetPhrase>>call(query) async {
    List<InternetPhrase> iPhrases = [];
    try {
      iPhrases.addAll(await DictionaryapiService().get(query));
    }catch(e){
      print(e.toString());
    }
    try {
      iPhrases.addAll(await WiktionaryService().get(query));
    }catch(e){
      print(e.toString());
    }
    try {
      iPhrases.addAll(await UrbandictionaryService().get(query));
    }catch(e){
      print(e.toString());
    }
    return iPhrases;
  }
}