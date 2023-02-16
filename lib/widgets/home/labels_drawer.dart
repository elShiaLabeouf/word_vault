import 'package:bootcamp/models/label.dart';
import 'package:bootcamp/models/phrase.dart';
import 'package:bootcamp/pages/labels_page.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bootcamp/helpers/globals.dart' as globals;
import 'package:bootcamp/helpers/database/phrases_repo.dart';
import 'package:iconsax/iconsax.dart';

class LabelsDrawer extends StatelessWidget {
  final phrasesRepo = PhrasesRepo();
  Function loadLabelsCallback;
  Function loadPhrasesCallback;
  List<Label> labelsList;
  LabelsDrawer(
      this.labelsList, this.loadLabelsCallback, this.loadPhrasesCallback,
      {super.key});

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    String currentLabel = '';
    bool darkModeOn = (globals.themeMode == ThemeMode.dark ||
        (brightness == Brightness.dark &&
            globals.themeMode == ThemeMode.system));

    return Drawer(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: darkModeOn
                  ? FlexColor.amberDarkPrimary.withOpacity(0.5)
                  : FlexColor.amberDarkPrimaryVariant,
            ),
            padding: const EdgeInsets.only(left: 15, top: 56, bottom: 20),
            alignment: Alignment.center,
            child: Row(
              children: const [
                Icon(Iconsax.filter),
                SizedBox(
                  width: 32,
                ),
                Text(
                  'Filter Labels',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (labelsList.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Iconsax.tag,
                      size: 80,
                      color: FlexColor.amberDarkPrimaryVariant,
                    ),
                    const SizedBox(height: 20),
                    const Text('No labels created'),
                    TextButton(
                        onPressed: () {
                          openLabelEditor(
                              context, loadLabelsCallback, loadPhrasesCallback);
                        },
                        child: const Text('Create label')),
                  ],
                ),
              ),
            ),
          if (labelsList.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  Label label = labelsList[index];
                  return ListTile(
                    onTap: (() {
                      currentLabel = label.name;
                      _filterPhrases(currentLabel, labelsList);
                    }),
                    leading: const Icon(Iconsax.tag),
                    trailing:
                        (currentLabel.isEmpty || currentLabel != label.name)
                            ? const Icon(
                                Icons.clear,
                                color: Colors.transparent,
                              )
                            : const Icon(
                                Icons.check_outlined,
                                color: FlexColor.amberDarkPrimary,
                              ),
                    title: Text(label.name),
                  );
                },
                itemCount: labelsList.length,
              ),
            ),
          if (labelsList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                tileColor:
                    FlexColor.amberDarkSecondary.lighten(10).withOpacity(0.5),
                trailing: const Icon(Iconsax.close_square),
                title: const Text('Clear Filter'),
                onTap: () {
                  _filterPhrases(currentLabel, labelsList);
                  Navigator.pop(context);
                },
                dense: true,
              ),
            ),
          if (labelsList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                tileColor:
                    FlexColor.amberDarkTertiary.lighten(10).withOpacity(0.5),
                trailing: const Icon(Iconsax.tag),
                title: const Text('Manage Labels'),
                onTap: () {
                  Navigator.pop(context);
                  openLabelEditor(
                      context, loadLabelsCallback, loadPhrasesCallback);
                },
                dense: true,
              ),
            ),
        ],
      ),
    );
  }

  void openLabelEditor(BuildContext context, Function loadLabelsCallback,
      Function loadPhrasesCallback) async {
    var res = await Navigator.of(context).push(CupertinoPageRoute(
        builder: (BuildContext context) => LabelsPage(
            phrase: Phrase(0, '', '', true, DateTime.now(), DateTime.now()))));
    loadLabelsCallback();
    if (res) loadPhrasesCallback();
  }

  void _filterPhrases(currentLabel, phrasesList) async {
    await phrasesRepo.getPhrasesByLabel(currentLabel).then((value) {
      phrasesList = value;
    });
  }
}
