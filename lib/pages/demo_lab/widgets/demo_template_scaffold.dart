import 'package:flutter/material.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

class DemoTemplateScaffold extends StatelessWidget {
  const DemoTemplateScaffold({
    super.key,
    required this.body,
    this.navItems = const ['Home', 'Features', 'Pricing', 'Contact'],
    this.brand = 'VSTACK',
    this.backgroundColor = const Color(0xFF0A1020),
  });

  final Widget body;
  final List<String> navItems;
  final String brand;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor.withValues(alpha: 0.95),
              border: Border(bottom: BorderSide(color: VStackColors.border.withValues(alpha: 0.5))),
            ),
            child: Row(
              children: [
                Text(brand, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const Spacer(),
                ...navItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(item, style: const TextStyle(color: VStackColors.muted, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
