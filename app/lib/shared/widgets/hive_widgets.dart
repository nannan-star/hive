import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../theme/hive_colors.dart';

const _pagePad = EdgeInsets.fromLTRB(20, 4, 20, 24);

class HiveBackHeader extends StatelessWidget {
  const HiveBackHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 16, 10),
      child: Row(
        children: [
          const HiveBackButton(),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: HiveColors.ink,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class HiveBackButton extends StatelessWidget {
  const HiveBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return HiveCircleButton(
      size: 36,
      radius: 18,
      onPressed: onPressed ?? () => context.pop(),
      child: const Text(
        '‹',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: HiveColors.ink,
          height: 1,
        ),
      ),
    );
  }
}

class HiveCircleButton extends StatelessWidget {
  const HiveCircleButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.size = 40,
    this.radius = 20,
  });

  final VoidCallback onPressed;
  final Widget child;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HiveColors.card,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class HiveBrandHeader extends StatelessWidget {
  const HiveBrandHeader({
    super.key,
    required this.subtitle,
    this.trailing,
  });

  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hive',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: HiveColors.ink,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: HiveColors.muted,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class HiveCard extends StatelessWidget {
  const HiveCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = 18,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: padding ?? EdgeInsets.zero,
      child: child,
    );
    return Material(
      color: HiveColors.card,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? body
          : InkWell(onTap: onTap, child: body),
    );
  }
}

class HiveHint extends StatelessWidget {
  const HiveHint(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: HiveColors.hint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          height: 1.5,
          color: HiveColors.muted,
        ),
      ),
    );
  }
}

class HiveChip extends StatelessWidget {
  const HiveChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? HiveColors.accentSoft : HiveColors.card,
          borderRadius: BorderRadius.circular(999),
          border: selected
              ? null
              : Border.all(color: HiveColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            color: selected ? HiveColors.accent : HiveColors.muted,
          ),
        ),
      ),
    );
  }
}

class HiveChipRow extends StatelessWidget {
  const HiveChipRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            children[i],
          ],
        ],
      ),
    );
  }
}

class HivePrimaryButton extends StatelessWidget {
  const HivePrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

class HiveTextAction extends StatelessWidget {
  const HiveTextAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.danger = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: danger ? HiveColors.danger : HiveColors.muted,
        ),
        child: Text(label),
      ),
    );
  }
}

class HiveProgressBar extends StatelessWidget {
  const HiveProgressBar({
    super.key,
    required this.value,
    this.height = 8,
  });

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: height,
        child: LinearProgressIndicator(
          value: value.clamp(0.0, 1.0),
          backgroundColor: HiveColors.track,
          color: HiveColors.accent,
          minHeight: height,
        ),
      ),
    );
  }
}

class HiveBadge extends StatelessWidget {
  const HiveBadge({
    super.key,
    required this.label,
    this.tone = HiveBadgeTone.muted,
  });

  final String label;
  final HiveBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      HiveBadgeTone.muted => (const Color(0xFFEDEDF0), HiveColors.muted),
      HiveBadgeTone.accent => (HiveColors.accentSoft, HiveColors.accent),
      HiveBadgeTone.pending => (HiveColors.pendingBg, HiveColors.pendingFg),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: tone == HiveBadgeTone.pending ? 11 : 11,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
    );
  }
}

enum HiveBadgeTone { muted, accent, pending }

class HiveFieldLabel extends StatelessWidget {
  const HiveFieldLabel(this.text, {super.key, this.small = false});

  final String text;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: small ? 12 : 13,
          color: HiveColors.dim,
        ),
      ),
    );
  }
}

class HiveYearSwitcher extends StatelessWidget {
  const HiveYearSwitcher({
    super.key,
    required this.year,
    required this.onChanged,
  });

  final int year;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HiveCircleButton(
          size: 32,
          radius: 16,
          onPressed: () => onChanged(year - 1),
          child: const Text(
            '‹',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: HiveColors.muted,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$year',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: HiveColors.ink,
          ),
        ),
        const SizedBox(width: 12),
        HiveCircleButton(
          size: 32,
          radius: 16,
          onPressed: () => onChanged(year + 1),
          child: const Text(
            '›',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: HiveColors.muted,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class HivePageBody extends StatelessWidget {
  const HivePageBody({
    super.key,
    required this.children,
    this.gap = 12,
  });

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: _pagePad,
      itemCount: children.length,
      separatorBuilder: (_, _) => SizedBox(height: gap),
      itemBuilder: (context, i) => children[i],
    );
  }
}

class HiveEmpty extends StatelessWidget {
  const HiveEmpty(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(color: HiveColors.muted, fontSize: 14),
      ),
    );
  }
}

class HiveTabBar extends StatelessWidget {
  const HiveTabBar({
    super.key,
    required this.index,
    required this.onSelect,
  });

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Material(
      color: HiveColors.card,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: HiveColors.border)),
        ),
        padding: EdgeInsets.only(top: 8, bottom: bottom > 0 ? bottom : 12),
        child: Row(
          children: [
            Expanded(
              child: _TabItem(
                selected: index == 0,
                label: '消费',
                icon: const HiveLedgerIcon(),
                onTap: () => onSelect(0),
              ),
            ),
            Expanded(
              child: _TabItem(
                selected: index == 1,
                label: '梦想',
                icon: const HiveJarIcon(),
                onTap: () => onSelect(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.selected,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? HiveColors.accent : HiveColors.dim;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 48,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              child: icon,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HiveLedgerIcon extends StatelessWidget {
  const HiveLedgerIcon({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _LedgerPainter(),
    );
  }
}

class _LedgerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    final fill = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.fill;

    final s = size.width / 24;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(4.5 * s, 3.5 * s, 15 * s, 17 * s),
      Radius.circular(3 * s),
    );
    canvas.drawRRect(rrect, stroke);

    void line(double top, double width) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(8 * s, top * s, width * s, 1.8 * s),
          Radius.circular(s),
        ),
        fill,
      );
    }

    line(8.5, 8.5);
    line(12, 8.5);
    line(15.5, 5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HiveJarIcon extends StatelessWidget {
  const HiveJarIcon({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/icon_jar.svg',
      width: size,
      height: size,
    );
  }
}

class HiveGearIcon extends StatelessWidget {
  const HiveGearIcon({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.settings_outlined,
      size: size,
      color: HiveColors.ink,
    );
  }
}

class HiveMonthBars extends StatelessWidget {
  const HiveMonthBars({
    super.key,
    required this.values,
    required this.selectedMonth,
    required this.onSelect,
  });

  /// 12 monthly amounts (any unit; only relative height is used).
  final List<int> values;
  final int selectedMonth;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final max = values.fold<int>(0, (a, b) => a > b ? a : b);
    return SizedBox(
      height: 130,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < 12; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(i + 1),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: max == 0
                              ? 0.04
                              : (values[i] / max).clamp(0.04, 1),
                          widthFactor: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: selectedMonth == i + 1
                                  ? HiveColors.accent
                                  : HiveColors.barMuted,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: selectedMonth == i + 1
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: selectedMonth == i + 1
                            ? HiveColors.accent
                            : HiveColors.dim,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
