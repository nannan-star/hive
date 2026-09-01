import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'databaseProvider must be overridden in main with a real AppDatabase',
  );
});
