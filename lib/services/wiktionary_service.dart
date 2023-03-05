import 'dart:convert';

import 'package:word_vault/models/internet_phrase.dart';
import 'package:word_vault/providers/status_provider.dart';
import 'package:http/http.dart' as http;

class WiktionaryService {
  static const searchBaseURL =
      "https://en.wiktionary.org/w/api.php?action=query&list=search&format=json&srlimit=1&srsearch=";
  static const sourceBaseURL = "https://en.wiktionary.org/wiki/";
  static const contentBaseURL =
      "https://en.wiktionary.org/w/api.php?action=parse&prop=wikitext&formatversion=2&format=json&page=";
  Future<List<InternetPhrase>> get(query) async {
    http.Response response;
    final searchUrl = Uri.parse("$searchBaseURL$query");

    StatusProvider status = StatusProvider();
    try {
      response = await http.get(searchUrl);
      status.listenToStatus(response.statusCode);
      if (response.statusCode == 200) {
        List<InternetPhrase> iPhrases = [];
        String? title =
            json.decode(response.body)["query"]["search"][0]?["title"];
        if (title != null && title.toLowerCase().contains(query.toLowerCase())) {
          final contentUrl = Uri.parse("$contentBaseURL$title");
          response = await http.get(contentUrl);
          status.listenToStatus(response.statusCode);
          if (response.statusCode == 200) {
            Map parsedJson = json.decode(response.body)["parse"];
            String wikitext = parsedJson["wikitext"];
            // print("wikitext $wikitext");
            List<Map<String, dynamic>> definitions = parseDefinitions(wikitext);
            definitions.forEach((definition) {
              iPhrases.add(InternetPhrase(
                  parsedJson["title"],
                  definition['definition'],
                  definition['examples'],
                  "$sourceBaseURL${parsedJson["title"]}"));
            });
          }
        }

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

  List<Map<String, dynamic>> parseDefinitions(str) {
    final engSectionRegex = RegExp(r'English([\S\s]+?)Category:en');
    var match = engSectionRegex.firstMatch(str);
    String engSection = match!.group(1)!;
    
    // find definitions or examples or quotations
    final regex = RegExp(
        r"# {?{?(.+?)}?}?\n|#: {{ux\|en\|(.+?)\n|#\*.+?passage=(.+?)\n");

    List<Map<String, dynamic>> definitions = [];
    print("engSection $engSection");
    regex.allMatches(engSection).forEach((_match) {
      if (_match.group(0)!.contains("n-g")) return;
      // if it's a definition
      if (_match.group(1) != null) {
        
        definitions.add({
          'definition': stripWikitext(_match.group(1)),
          'examples': <String>[]
        });
      }

      // if it's an example
      if (_match.group(2) != null) {
        definitions[definitions.length - 1]["examples"]
            .add(stripWikitext(_match.group(2)));
      }

      // if it's a quotation
      if (_match.group(3) != null) {
        definitions[definitions.length - 1]["examples"]
            .add(stripWikitext(_match.group(3)));
      }
    });
    print(definitions);
    return definitions;
  }

  String stripWikitext(string) {
    String result = string.replaceAll(RegExp(r'\|nodot=.'), '');
    result = result.replaceAll(RegExp(r'\|_\|'), ' ');
    result = result.replaceAllMapped(RegExp(r'{?{?(?:label|lb)\|en\|([\s\S\|]+?)}}'), (match) {
      return '(${match.group(1)})';
    });
    // result = result.replaceAll(RegExp(r'\|'), ', ');
    result = result.replaceAllMapped(RegExp(r'\[\[.+?\|(.+?)\]\]'), (match) {
      return '${match.group(1)}';
    });
    result = result.replaceAll(RegExp(r'\|[a-z]{2}\|'), ' ');

    result = result.replaceAll(RegExp(r"[\{\}\[\]]|'''"), '');
    return result;
  }
}
