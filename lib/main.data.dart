

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: directives_ordering, top_level_function_literal_block

import 'package:flutter_data/flutter_data.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bootcamp/phrase.dart';

// ignore: prefer_function_declarations_over_variables
ConfigureRepositoryLocalStorage configureRepositoryLocalStorage = ({FutureFn<String>? baseDirFn, List<int>? encryptionKey, bool? clear}) {
  if (!kIsWeb) {
    
  } else {
    baseDirFn ??= () => '';
  }
  
  return hiveLocalStorageProvider
    .overrideWithProvider(Provider((ref) => HiveLocalStorage(
            hive: ref.read(hiveProvider),
            baseDirFn: baseDirFn,
            encryptionKey: encryptionKey,
            clear: clear,
          )));
};

final repositoryProviders = <String, Provider<Repository<DataModel>>>{
  'phrases': phrasesRepositoryProvider
};

final repositoryInitializerProvider =
  FutureProvider<RepositoryInitializer>((ref) async {
    DataHelpers.setInternalType<Phrase>('phrases');
    final adapters = <String, RemoteAdapter>{'phrases': ref.watch(internalPhrasesRemoteAdapterProvider)};
    final remotes = <String, bool>{'phrases': true};

    await ref.watch(graphNotifierProvider).initialize();

    // initialize and register
    for (final type in repositoryProviders.keys) {
      final repository = ref.read(repositoryProviders[type]!);
      repository.dispose();
      await repository.initialize(
        remote: remotes[type],
        adapters: adapters,
      );
      internalRepositories[type] = repository;
    }

    return RepositoryInitializer();
});
extension RepositoryWidgetRefX on WidgetRef {
  Repository<Phrase> get phrases => watch(phrasesRepositoryProvider)..remoteAdapter.internalWatch = watch;
}

extension RepositoryRefX on Ref {

  Repository<Phrase> get phrases => watch(phrasesRepositoryProvider)..remoteAdapter.internalWatch = watch as Watcher;
}