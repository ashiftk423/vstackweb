import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/services/admin_auth.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/page_scroll.dart';

/// Shows [child] only to signed-in staff; everyone else sees "Unauthorised".
class StaffGate extends StatelessWidget {
  const StaffGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AdminAuth.signedIn,
      builder: (context, signedIn, _) =>
          signedIn ? child : const UnauthorisedView(),
    );
  }
}

class UnauthorisedView extends StatelessWidget {
  const UnauthorisedView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScroll(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 96),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent.withValues(alpha: 0.12),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 40,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Unauthorised',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                const Text(
                  'This page is restricted to authorised VStack staff only.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: VStackColors.muted,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Back to home'),
                  style: FilledButton.styleFrom(
                    backgroundColor: VStackColors.accent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
