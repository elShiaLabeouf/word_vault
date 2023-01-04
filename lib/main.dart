import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_data/flutter_data.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:bootcamp/main.data.dart';
import 'package:bootcamp/phrase.dart';

void main(List<String> args) {
  runApp(
    ProviderScope(
      child: MyWidget(),
      overrides: [configureRepositoryLocalStorage(clear: true)],
    ),
  );

  // runApp(MyWidget());
}

class MyWidget extends StatelessWidget {
  const MyWidget({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', '')
      ],
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text("Bootcamp"),
        ),
        body: const WordDefinitionField(),
        ),
      );
  }
}

class WordDefinitionField extends StatefulWidget {
  const WordDefinitionField({Key? key}) : super(key: key);

  @override
  WordDefinitionFieldState createState() => WordDefinitionFieldState();
}

class WordData {
  String? word = '';
  String? definition = '';
}

class WordDefinitionFieldState extends State<WordDefinitionField>
    with RestorationMixin {
  WordData word = WordData();

  late FocusNode _wordNode, _definitionNode;

  @override
  void initState() {
    super.initState();
    _wordNode = FocusNode();
    _definitionNode = FocusNode();
  }

  @override
  void dispose() {
    _wordNode.dispose();
    _definitionNode.dispose();
    super.dispose();
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  @override
  String get restorationId => 'text_field_demo';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_autoValidateModeIndex, 'autovalidate_mode');
  }

  final RestorableInt _autoValidateModeIndex =
      RestorableInt(AutovalidateMode.disabled.index);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _handleSubmitted() {
    final form = _formKey.currentState!;
    print("===================");
    if (!form.validate()) {
      _autoValidateModeIndex.value =
          AutovalidateMode.always.index; // Start validating on every change.
      showInSnackBar(
        AppLocalizations.of(context)!.demoTextFieldFormErrors,
      );
    } else {
      print("_________________");
      print(form.phrase);
      final phrase = Phrase(phrase: 'Frank', definition: 'Frank');

      form.save();
    }
  }

  String? _validateString(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.fieldRequired;
    }
    final nameExp = RegExp(r'^[0-9A-Za-z ]+$');
    if (!nameExp.hasMatch(value)) {
      return AppLocalizations.of(context)!
          .nonAlphaNumberic;
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    const sizedBoxSpace = SizedBox(height: 24);
    final localizations = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.values[_autoValidateModeIndex.value],
      child: Scrollbar(
        child: SingleChildScrollView(
          restorationId: 'text_field_demo_scroll_view',
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              sizedBoxSpace,
              TextFormField(
                restorationId: 'word_field',
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  filled: true,
                  labelText: localizations.wordFieldLabel,
                ),
                onSaved: (value) {
                  word.word = value;
                  _definitionNode.requestFocus();
                },
                validator: _validateString,
              ),
              sizedBoxSpace,
              TextFormField(
                restorationId: 'defintion_field',
                focusNode: _definitionNode,
                decoration: InputDecoration(
                  filled: true,
                  border: const OutlineInputBorder(),
                  labelText: localizations.definitionFieldLabel,
                ),
                validator: _validateString,
                maxLines: 3,
              ),
              sizedBoxSpace,
              Center(
                child: ElevatedButton(
                  onPressed: _handleSubmitted,
                  child: const Text("Save"),
                ),
              ),
              sizedBoxSpace,
            ],
          ),
        ),
      ),
    );
  }
}
