import 'package:flutter/material.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

class ToolSearchBar extends StatelessWidget {
  const ToolSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search tools...',
        prefixIcon: const Icon(Icons.search, color: VStackColors.muted),
        filled: true,
        fillColor: VStackColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(VStackRadius.md),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class ToolCategoryChips extends StatelessWidget {
  const ToolCategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String? selected;
  final ValueChanged<String?> onSelected;

  static const categories = [
    (null, 'All'),
    ('Popular', 'Popular'),
    ('Image', 'Image'),
    ('PDF', 'PDF'),
    ('Business', 'Business'),
    ('Marketing', 'Marketing'),
    ('Developer', 'Developer'),
    ('Design', 'Design'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((c) {
        final isSelected = selected == c.$1;
        return FilterChip(
          label: Text(c.$2),
          selected: isSelected,
          onSelected: (_) => onSelected(c.$1),
        );
      }).toList(),
    );
  }
}
