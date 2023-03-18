import 'dart:async';

import 'package:word_vault/helpers/database/labels_repo.dart';
import 'package:word_vault/helpers/database/phrase_labels_repo.dart';
import 'package:word_vault/models/label.dart';
import 'package:word_vault/models/phrase.dart';
import 'package:word_vault/widgets/small_appbar.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class LabelsPage extends StatefulWidget {
  final Phrase phrase;

  const LabelsPage({Key? key, required this.phrase}) : super(key: key);
  @override
  _LabelsPageState createState() => _LabelsPageState();
}

class _LabelsPageState extends State<LabelsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final labelsRepo = LabelsRepo();
  final phraseLabelRepo = PhraseLabelsRepo();
  late StreamController<List<Label>> _labelsController;
  final TextEditingController _newLabelController = TextEditingController();
  var uuid = const Uuid();
  List _selectedLabels = [];
  bool reloadPhrases = false;
  loadLabels() async {
    final allRows = await labelsRepo.getLabelsAll();
    _labelsController.add(allRows);
  }

  void _saveLabel() async {
    if (_newLabelController.text.isNotEmpty) {
      await labelsRepo.insertLabel(_newLabelController.text).then((value) {
        setState(() {
          _newLabelController.text = "";
        });
        loadLabels();
      });
    }
  }

  void _deleteLabel(int labelId) async {
    await labelsRepo.deleteLabel(labelId).then((value) {
      loadLabels();
      setState(() {
        reloadPhrases = true;
      });
    });
  }

  void _assignLabel(labelId) async {
    await phraseLabelRepo.insertPhraseLabel(widget.phrase.id, labelId);
  }

  void _deassignLabel(labelId) async {
    await phraseLabelRepo.removePhraseLabel(widget.phrase.id, labelId);
  }

  Future showTip() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text('Tap on the Label to Assign to a Phrase'),
      duration: Duration(seconds: 5),
    ));
  }

  void _onLabelSelected(bool selected, int labelId, String labelName) {
    if (selected) {
      setState(() {
        _selectedLabels.add(labelName);
        _assignLabel(labelId);
        widget.phrase.labels = [widget.phrase.labels, labelName]
            .whereType<String>()
            .toList()
            .join(',');
      });
    } else {
      setState(() {
        _selectedLabels.remove(labelName);
        _deassignLabel(labelId);
        widget.phrase.labels = widget.phrase.labels?.replaceAll(labelName, "");
      });
    }
  }

  @override
  void initState() {
    _labelsController = StreamController<List<Label>>();
    loadLabels();
    super.initState();
    if (widget.phrase.labels != null) {
      _selectedLabels = widget.phrase.labels?.split(',') ?? [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: SAppBar(
            title: 'Labels',
            action: [
              Visibility(
                visible: !widget.phrase.isNewRecord(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton(
                    child: const Text('Done'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newLabelController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration:
                            const InputDecoration(hintText: 'Add Label'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      // color: kPrimaryColor,
                      onPressed: () => _saveLabel(),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: StreamBuilder<List<Label>>(
                    stream: _labelsController.stream,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Label>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return Text(snapshot.error.toString());
                      }
                      if (snapshot.hasData) {
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var label = snapshot.data![index];
                            return Dismissible(
                              background: Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        padding:
                                            const EdgeInsets.only(left: 15.0),
                                        decoration: const BoxDecoration(
                                          color: FlexColor.redDarkPrimary,
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(10),
                                              topLeft: Radius.circular(10)),
                                        ),
                                        child: const Icon(
                                            Icons.delete_outline_rounded),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.centerRight,
                                        padding:
                                            const EdgeInsets.only(right: 15.0),
                                        decoration: const BoxDecoration(
                                          color: FlexColor.redDarkPrimary,
                                          borderRadius: BorderRadius.only(
                                              bottomRight: Radius.circular(10),
                                              topRight: Radius.circular(10)),
                                        ),
                                        child: const Icon(
                                            Icons.delete_outline_rounded),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              key: Key(label.id.toString()),
                              onDismissed: (direction) {
                                setState(() {
                                  _deleteLabel(label.id);
                                  snapshot.data!.removeAt(index);
                                });
                              },
                              child: widget.phrase.id != 0
                                  ? CheckboxListTile(
                                      value:
                                          _selectedLabels.contains(label.name),
                                      title: Text(label.name),
                                      onChanged: (value) {
                                        _onLabelSelected(
                                            value!, label.id, label.name);
                                      },
                                    )
                                  : ListTile(
                                      title: Text(label.name),
                                      trailing: InkWell(
                                          onTap: () {
                                            _deleteLabel(label.id);
                                          },
                                          child: const Icon(
                                            Icons.delete,
                                            size: 24,
                                            color:
                                                Color.fromRGBO(227, 44, 70, 1),
                                          ))),
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: Text('No phrases yet!'),
                        );
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    Navigator.pop(context, null);
    return reloadPhrases;
  }
}
