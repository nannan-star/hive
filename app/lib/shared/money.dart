import 'package:intl/intl.dart';

/// Amount helpers: store cents in DB, show yuan in UI.
int yuanToCents(num yuan) => (yuan * 100).round();

double centsToYuan(int cents) => cents / 100.0;

final _yuanInt = NumberFormat('#,##0');
final _yuanDec = NumberFormat('#,##0.00');

String formatYuan(int cents) {
  final yuan = centsToYuan(cents);
  if (yuan == yuan.roundToDouble()) {
    return '¥${_yuanInt.format(yuan.round())}';
  }
  return '¥${_yuanDec.format(yuan)}';
}
