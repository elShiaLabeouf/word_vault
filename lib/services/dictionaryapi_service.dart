import 'dart:convert';

import 'package:word_vault/models/internet_phrase.dart';
import 'package:word_vault/providers/status_provider.dart';
import 'package:http/http.dart' as http;

class DictionaryapiService {
  static const baseURL = "https://api.dictionaryapi.dev/api/v2/entries/en/";

  Future<List<InternetPhrase>> get(query) async {
    http.Response response;
    final url = Uri.parse("$baseURL$query");
    StatusProvider status = StatusProvider();
    try {
      response = await http.get(url);
      status.listenToStatus(response.statusCode);
      if (response.statusCode == 200) {
        List<InternetPhrase> iPhrases = [];
        json.decode(response.body).forEach((word) {
          word['meanings'].forEach((meaning) {
            meaning['definitions'].forEach((definition) {
              iPhrases.add(InternetPhrase(
                  word['word'],
                  definition['definition'],
                  [definition['example']].whereType<String>().toList(),
                  word['sourceUrls'][0]));
            });
          });
        });
        return iPhrases;
      } else {
        return [];
      }
    } on Exception catch (e) {
      // print("object");
      // print(e.toString());
      throw e;
    }
  }
}
