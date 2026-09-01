import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/daos/categories_dao.dart';
import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';

final categoriesDaoProvider = Provider<CategoriesDao>((ref) {
  return ref.watch(databaseProvider).categoriesDao;
});

final showDisabledCategoriesProvider = StateProvider<bool>((ref) => false);

final categoriesListProvider = StreamProvider<List<Category>>((ref) {
  final dao = ref.watch(categoriesDaoProvider);
  final showDisabled = ref.watch(showDisabledCategoriesProvider);
  return showDisabled ? dao.watchAll() : dao.watchEnabled();
});

final pendingEntriesProvider =
    StreamProvider.family<List<SpendEntry>, (int, int)>((ref, ym) {
  final db = ref.watch(databaseProvider);
  return db.spendEntriesDao.watchPendingForMonth(ym.$1, ym.$2);
});
