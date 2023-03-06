import 'dart:convert';

import 'package:word_vault/models/internet_phrase.dart';
import 'package:word_vault/providers/status_provider.dart';
import 'package:http/http.dart' as http;

class UrbandictionaryService {
  static const baseURL = "https://api.urbandictionary.com/v0/define?term=";

  Future<List<InternetPhrase>> get(query) async {
    http.Response response;
    final url = Uri.parse("$baseURL$query");
    StatusProvider status = StatusProvider();
    try {
      response = await http.get(url);
      status.listenToStatus(response.statusCode);
      
      if (response.statusCode == 200) {
        List<InternetPhrase> iPhrases = [];
        json.decode(response.body)['list'].forEach((word) {
          iPhrases.add(InternetPhrase(
              word['word'],
              "URBAN ${word['definition'].replaceAll(RegExp(r'[\[\]]'), '')}",
              [word['example'].replaceAll(RegExp(r'[\[\]]'), '')]
                  .whereType<String>()
                  .toList(),
              word['permalink']));
        });
        print("iPhrases URBAN: ${iPhrases}");
        
        return iPhrases;
      } else {
        return [];
      }
    } on Exception catch (e) {
      print("object");
      print(e.toString());
      throw e;
    }
  }
}
