import 'package:flutter_data/flutter_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'phrase.g.dart';

@JsonSerializable()
@DataRepository([])
class Phrase extends DataModel<Phrase> {
  @override
  final int? id;
  final String phrase;
  final String definition;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  Phrase({this.id, required this.phrase, required this.definition, this.createdAt, this.updatedAt, this.active = true });
}