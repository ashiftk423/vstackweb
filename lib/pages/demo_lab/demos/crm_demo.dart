import 'package:flutter/material.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/layout_widgets.dart';

class CrmDemo extends StatelessWidget {
  const CrmDemo({super.key});

  @override
  Widget build(BuildContext context) {
    const stages = ['Lead', 'Qualified', 'Proposal', 'Won'];
    return Container(
      color: VStackColors.bg,
      padding: const EdgeInsets.all(VStackSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CRM Pipeline', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: VStackSpacing.lg),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: stages.map((stage) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(stage, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 8),
                        VStackCard(
                          padding: const EdgeInsets.all(10),
                          child: Text('$stage Co. (demo)', style: const TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(height: 8),
                        VStackCard(
                          padding: const EdgeInsets.all(10),
                          child: Text('Sample lead ${stage[0]}1', style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
