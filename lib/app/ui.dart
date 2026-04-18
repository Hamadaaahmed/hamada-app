import 'package:flutter/material.dart';

class AppUiColors {
  static const Color primary = Color(0xFFE53935);
  static const Color primaryDark = Color(0xFFCC2F2C);
  static const Color background = Color(0xFFF3F4F6);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE5E7EB);
  static const Color muted = Color(0xFF6B7280);
  static const Color text = Color(0xFF111827);
  static const Color success = Color(0xFF16A34A);
  static const Color info = Color(0xFF2563EB);
  static const Color warning = Color(0xFFF59E0B);
  static const Color purple = Color(0xFF8B5CF6);
}

class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 26,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Material(
        color: AppUiColors.surface,
        elevation: 1,
        shadowColor: const Color(0x12000000),
        borderRadius: BorderRadius.circular(radius),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: AppUiColors.border),
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class AppHeroHeader extends StatelessWidget {
  const AppHeroHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
    this.icon = Icons.widgets_outlined,
  });

  final String title;
  final String subtitle;
  final Widget? action;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppUiColors.primary, AppUiColors.primaryDark],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24E53935),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(48),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'حمادة صيانة',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFFDECEC),
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(height: 16),
                  action!,
                ],
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(38),
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppUiColors.text,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppUiColors.muted,
                height: 1.5,
              ),
        ),
      ],
    );
  }
}

class AppCountBadge extends StatelessWidget {
  const AppCountBadge({
    super.key,
    required this.count,
    this.compact = false,
    this.color = AppUiColors.primary,
  });

  final int count;
  final bool compact;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return Container(
      constraints: BoxConstraints(
        minWidth: compact ? 20 : 28,
        minHeight: compact ? 20 : 28,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 5 : 8,
        vertical: compact ? 2 : 5,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: compact ? 10 : 12,
        ),
      ),
    );
  }
}

class AppTag extends StatelessWidget {
  const AppTag({
    super.key,
    required this.icon,
    required this.label,
    this.color = AppUiColors.info,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
