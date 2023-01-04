// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phrase.dart';

// **************************************************************************
// RepositoryGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, duplicate_ignore

mixin $PhraseLocalAdapter on LocalAdapter<Phrase> {
  static final Map<String, RelationshipMeta> _kPhraseRelationshipMetas = {};

  @override
  Map<String, RelationshipMeta> get relationshipMetas =>
      _kPhraseRelationshipMetas;

  @override
  Phrase deserialize(map) {
    map = transformDeserialize(map);
    return _$PhraseFromJson(map);
  }

  @override
  Map<String, dynamic> serialize(model, {bool withRelationships = true}) {
    final map = _$PhraseToJson(model);
    return transformSerialize(map, withRelationships: withRelationships);
  }
}

final _phrasesFinders = <String, dynamic>{};

// ignore: must_be_immutable
class $PhraseHiveLocalAdapter = HiveLocalAdapter<Phrase>
    with $PhraseLocalAdapter;

class $PhraseRemoteAdapter = RemoteAdapter<Phrase> with NothingMixin;

final internalPhrasesRemoteAdapterProvider = Provider<RemoteAdapter<Phrase>>(
    (ref) => $PhraseRemoteAdapter(
        $PhraseHiveLocalAdapter(ref.read, typeId: null),
        InternalHolder(_phrasesFinders)));

final phrasesRepositoryProvider =
    Provider<Repository<Phrase>>((ref) => Repository<Phrase>(ref.read));

extension PhraseDataRepositoryX on Repository<Phrase> {}

extension PhraseRelationshipGraphNodeX on RelationshipGraphNode<Phrase> {}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Phrase _$PhraseFromJson(Map<String, dynamic> json) => Phrase(
      id: json['id'] as int?,
      phrase: json['phrase'] as String,
      definition: json['definition'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      active: json['active'] as bool? ?? true,
    );

Map<String, dynamic> _$PhraseToJson(Phrase instance) => <String, dynamic>{
      'id': instance.id,
      'phrase': instance.phrase,
      'definition': instance.definition,
      'active': instance.active,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
