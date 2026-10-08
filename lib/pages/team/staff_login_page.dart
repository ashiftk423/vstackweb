import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vstackweb/services/admin_auth.dart';
import 'package:vstackweb/theme/vstack_theme.dart';
import 'package:vstackweb/widgets/page_scroll.dart';

/// Reached only through the Ctrl + A + G shortcut; not linked anywhere.
class StaffLoginPage extends StatefulWidget {
  const StaffLoginPage({super.key});

  static const path = '/staff-access';

  @override
  State<StaffLoginPage> createState() => _StaffLoginPageState();
}

class _StaffLoginPageState extends State<StaffLoginPage> {
  final _loginId = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _loginId.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    // Let the spinner paint before the hashing work blocks the frame.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final ok = AdminAuth.signIn(_loginId.text, _password.text);
    if (!mounted) return;
    if (ok) {
      context.go('/team');
    } else {
      setState(() {
        _busy = false;
        _error = 'Invalid login ID or password.';
        _password.clear();
      });
    }
  }

  InputDecoration _field(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: VStackColors.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageScroll(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ValueListenableBuilder<bool>(
              valueListenable: AdminAuth.signedIn,
              builder: (context, signedIn, _) =>
                  signedIn ? _signedInView() : _form(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _signedInView() {
    return Column(
      children: [
        const Icon(Icons.verified_user_outlined, size: 48, color: VStackColors.accent),
        const SizedBox(height: 16),
        const Text(
          'You are signed in',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => context.go('/team'),
          child: const Text('Open team ID cards'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: AdminAuth.signOut,
          child: const Text('Sign out'),
        ),
      ],
    );
  }

  Widget _form() {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.admin_panel_settings_outlined, size: 48, color: VStackColors.accent),
          const SizedBox(height: 16),
          const Text(
            'Staff sign in',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Authorised VStack staff only.',
            textAlign: TextAlign.center,
            style: TextStyle(color: VStackColors.muted),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _loginId,
            autofocus: true,
            enabled: !_busy,
            autofillHints: const [AutofillHints.username],
            textInputAction: TextInputAction.next,
            decoration: _field('Login ID', Icons.person_outline),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _password,
            enabled: !_busy,
            obscureText: _obscure,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) => _submit(),
            decoration: _field(
              'Password',
              Icons.lock_outline,
              suffix: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          ],
          const SizedBox(height: 22),
          FilledButton(
            onPressed: _busy ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: VStackColors.accent,
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : const Text('Sign in'),
          ),
        ],
      ),
    );
  }
}
