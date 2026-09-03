import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/daos/dream_dao.dart';
import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../services/dream_service.dart';

final dreamDaoProvider = Provider<DreamDao>((ref) {
  return ref.watch(databaseProvider).dreamDao;
});

final dreamServiceProvider = Provider(
  (ref) => DreamService(ref.watch(databaseProvider)),
);

final freeKindFilterProvider = StateProvider<String>((_) => 'goal');

final includeCompletedDreamsProvider = StateProvider<bool>((ref) => false);

final dreamJarsProvider = StreamProvider<List<DreamJar>>((ref) {
  final kind = ref.watch(freeKindFilterProvider);
  final include = ref.watch(includeCompletedDreamsProvider);
  return ref.watch(databaseProvider).dreamDao.watchJarsByKind(
        kind: kind,
        includeCompleted: kind == 'goal' ? include : true,
      );
});

final dreamDepositsProvider =
    StreamProvider.family<List<DreamDeposit>, String>((ref, jarId) {
  return ref.watch(dreamDaoProvider).watchDeposits(jarId);
});
