import 'package:flutter/material.dart';

class YearSwitcher extends StatelessWidget {
  const YearSwitcher({
    super.key,
    required this.year,
    required this.onChanged,
  });

  final int year;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => onChanged(year - 1),
          icon: const Icon(Icons.chevron_left),
        ),
        Text('$year', style: Theme.of(context).textTheme.titleMedium),
        IconButton(
          onPressed: () => onChanged(year + 1),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
