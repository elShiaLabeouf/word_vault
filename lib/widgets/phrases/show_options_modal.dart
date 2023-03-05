import 'package:word_vault/pages/labels_page.dart';
import 'package:word_vault/pages/phrase_reader_page.dart';
import 'package:word_vault/widgets/phrases/confirm_delete_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:word_vault/common/constants.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:iconsax/iconsax.dart';
import 'package:word_vault/helpers/database/phrases_repo.dart';
import 'package:word_vault/models/phrase.dart';

class ShowOptionsModal {
  final phrasesRepo = PhrasesRepo();

  void render(
      BuildContext context,
      Offset tapPosition,
      Phrase phrase,
      Function callback,
      Function updatePhraseCallback,
      Function removePhraseCallback) async {
    final RenderObject? overlay =
        Overlay.of(context)?.context.findRenderObject();
    await showMenu(
        context: context,

        // Show the context menu at the tap location
        position: RelativeRect.fromRect(
            Rect.fromLTWH(tapPosition.dx, tapPosition.dy, 30, 30),
            Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width,
                overlay.paintBounds.size.height)),

        // set a list of choices for the context menu
        items: [
          PopupMenuItem(
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
                _showEdit(context, phrase, callback);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: const <Widget>[
                    Icon(Boxicons.bxs_edit),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('Edit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          PopupMenuItem(
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                _assignLabel(context, phrase, updatePhraseCallback);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: const <Widget>[
                    Icon(Boxicons.bx_purchase_tag_alt),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('Assign Labels'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (phrase.active)
            PopupMenuItem(
                child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
                _deactivatePhrase(phrase.id, callback);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: const <Widget>[
                    Icon(Boxicons.bx_archive_in),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('Archive'),
                    ),
                  ],
                ),
              ),
            )),
          if (!phrase.active)
            PopupMenuItem(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  _activatePhrase(phrase.id, callback);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: const <Widget>[
                      Icon(Boxicons.bx_archive_out),
                      Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Text('Unarchive'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          PopupMenuItem(
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
                _confirmDelete(context, phrase.id, removePhraseCallback);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: const <Widget>[
                    Icon(Boxicons.bxs_trash),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          PopupMenuItem(
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: const <Widget>[
                    Icon(Boxicons.bx_arrow_back),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]);
  }

  void _showEdit(BuildContext context, Phrase phrase, Function callback) async {
    bool res = await Navigator.of(context).push(CupertinoPageRoute(
        builder: (BuildContext context) => PhraseReaderPage(
              phrase: phrase,
              isEditing: true,
            )));

    if (res is Phrase) callback.call();
  }

  void _activatePhrase(int currentEditingPhraseId, Function callback) async {
    await phrasesRepo.archivePhrase(currentEditingPhraseId, true).then((value) {
      callback.call();
    });
  }

  void _deactivatePhrase(int currentEditingPhraseId, Function callback) async {
    await phrasesRepo
        .archivePhrase(currentEditingPhraseId, false)
        .then((value) {
      callback.call();
    });
  }

  void _confirmDelete(BuildContext context, int currentEditingPhraseId,
      Function callback) async {
    ConfirmDeleteModal().render(context, currentEditingPhraseId, callback);
  }

  void _assignLabel(
      BuildContext context, Phrase phrase, Function callback) async {
    await Navigator.of(context).push(CupertinoPageRoute(
        builder: (BuildContext context) => LabelsPage(
              phrase: phrase,
            )));
    callback.call(phrase);
  }
}
