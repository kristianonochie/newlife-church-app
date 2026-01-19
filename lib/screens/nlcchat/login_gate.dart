import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class LoginGate extends StatefulWidget {
  const LoginGate({super.key});

  @override
  State<LoginGate> createState() => _LoginGateState();
}

class _LoginGateState extends State<LoginGate> {
  final _formKey = GlobalKey<FormState>();
  String? _username, _password, _newPassword;
  bool _submitting = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final needsReset = auth.currentUser?.passwordChanged == false;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: needsReset ? _buildReset(auth) : _buildLogin(auth),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogin(AuthService auth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Engineer Login', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Username'),
          onSaved: (v) => _username = v,
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
          onSaved: (v) => _password = v,
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _submitting ? null : () async {
            if (!_formKey.currentState!.validate()) return;
            _formKey.currentState!.save();
            setState(() { _submitting = true; _error = null; });
            final ok = await auth.login(_username!, _password!);
            setState(() { _submitting = false; });
            if (!ok) {
              setState(() { _error = 'Invalid credentials or account locked.'; });
            }
          },
          child: _submitting ? const CircularProgressIndicator() : const Text('Login'),
        ),
      ],
    );
  }

  Widget _buildReset(AuthService auth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Change Password', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'New Password'),
          obscureText: true,
          onSaved: (v) => _newPassword = v,
          validator: (v) => v != null && v.length >= 12 && _strong(v) ? null : 'Min 12 chars, strong password',
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _submitting ? null : () async {
            if (!_formKey.currentState!.validate()) return;
            _formKey.currentState!.save();
            setState(() { _submitting = true; _error = null; });
            await auth.changePassword(_newPassword!);
            setState(() { _submitting = false; });
          },
          child: _submitting ? const CircularProgressIndicator() : const Text('Change Password'),
        ),
      ],
    );
  }

  bool _strong(String v) {
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{12,}$').hasMatch(v);
  }
}
