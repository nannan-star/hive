import '../../../data/db/app_database.dart';

class DreamService {
  DreamService(this.db);

  final AppDatabase db;

  Future<int> savedCents(String jarId) => db.dreamDao.sumDeposits(jarId);

  Future<void> complete(String jarId) => db.dreamDao.markCompleted(jarId);
}
