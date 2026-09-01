import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/daos/dream_dao.dart';
import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';

final dreamDaoProvider = Provider<DreamDao>((ref) {
  return ref.watch(databaseProvider).dreamDao;
});

final includeCompletedDreamsProvider = StateProvider<bool>((ref) => false);

final dreamJarsProvider = StreamProvider<List<DreamJar>>((ref) {
  final include = ref.watch(includeCompletedDreamsProvider);
  return ref.watch(dreamDaoProvider).watchJars(includeCompleted: include);
});

final dreamDepositsProvider =
    StreamProvider.family<List<DreamDeposit>, String>((ref, jarId) {
  return ref.watch(dreamDaoProvider).watchDeposits(jarId);
});
