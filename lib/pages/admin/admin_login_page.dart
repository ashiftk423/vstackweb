import 'package:flutter/material.dart';
import 'package:vstackweb/config/admin_auth_config.dart';
import 'package:vstackweb/pages/admin/admin_dashboard_page.dart';
import 'package:vstackweb/services/admin_session.dart';
import 'package:vstackweb/theme/vstack_theme.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _username = TextEditingController(text: AdminAuthConfig.username);
  final _password = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    if (!AdminAuthConfig.verify(_username.text, _password.text)) {
      setState(() => _error = 'Invalid username or password.');
      return;
    }
    setState(() => _error = null);
    AdminSession.signIn();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const AdminDashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VStackColors.bg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.lock_outline, color: VStackColors.accent, size: 40),
                const SizedBox(height: 16),
                Text(
                  'VStack Admin',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Shift + Ctrl + O',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: VStackColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: _username,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    hintText: 'vstackadmin',
                  ),
                  onSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  onSubmitted: (_) => _login(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                ],
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: _login,
                  style: FilledButton.styleFrom(
                    backgroundColor: VStackColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Sign in'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to website', style: TextStyle(color: VStackColors.muted)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
