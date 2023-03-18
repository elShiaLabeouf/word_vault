import 'package:word_vault/models/label.dart';
import 'package:word_vault/models/phrase.dart';
import 'package:word_vault/pages/labels_page.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:word_vault/helpers/globals.dart' as globals;
import 'package:word_vault/helpers/database/phrases_repo.dart';
import 'package:iconsax/iconsax.dart';

class LabelsDrawer extends StatefulWidget {
  final String labelSelected;
  final Function loadLabelsCallback;
  final Function loadPhrasesCallback;
  final Function setCurrentLabelCallback;
  List<Label> labelsList;
  LabelsDrawer(
      this.labelsList, this.labelSelected , this.loadLabelsCallback, this.loadPhrasesCallback, this.setCurrentLabelCallback,
      {super.key});
  @override
  State<StatefulWidget> createState() => LabelsDrawerState();
}

class LabelsDrawerState extends State<LabelsDrawer> {
  final phrasesRepo = PhrasesRepo();
  String currentLabel = '';

  @override
  void initState() {
    currentLabel = widget.labelSelected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;

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
          if (widget.labelsList.isEmpty)
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
                          openLabelEditor(context, widget.loadLabelsCallback,
                              widget.loadPhrasesCallback);
                        },
                        child: const Text('Create label')),
                  ],
                ),
              ),
            ),
          if (widget.labelsList.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  Label label = widget.labelsList[index];
                  return ListTile(
                    onTap: (() {
                      setState(() {
                        currentLabel = label.name;
                      });
                      widget.setCurrentLabelCallback.call(currentLabel);
                      widget.loadPhrasesCallback(labelFilter: currentLabel);
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
                itemCount: widget.labelsList.length,
              ),
            ),
          if (widget.labelsList.isNotEmpty)
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
                  widget.loadPhrasesCallback.call();
                  widget.setCurrentLabelCallback.call('');

                  Navigator.pop(context, currentLabel);
                },
                dense: true,
              ),
            ),
          if (widget.labelsList.isNotEmpty)
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
                  openLabelEditor(context, widget.loadLabelsCallback,
                      widget.loadPhrasesCallback);
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
            phrase: Phrase(
                0, '', '', true, DateTime.now(), DateTime.now(), 0, 0))));
    loadLabelsCallback();
    if (res) loadPhrasesCallback();
  }

  void _filterPhrases(currentLabel, phrasesList) async {
    await phrasesRepo.getPhrasesAll(labelFilter: currentLabel).then((value) {
      phrasesList = value;
    });
  }
}
