/// Amount helpers: store cents in DB, show yuan in UI.
int yuanToCents(num yuan) => (yuan * 100).round();

double centsToYuan(int cents) => cents / 100.0;

String formatYuan(int cents) {
  final yuan = centsToYuan(cents);
  if (yuan == yuan.roundToDouble()) {
    return '¥${yuan.toStringAsFixed(0)}';
  }
  return '¥${yuan.toStringAsFixed(2)}';
}
