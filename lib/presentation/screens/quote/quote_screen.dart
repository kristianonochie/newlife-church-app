import 'package:flutter/material.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  final _formKey = GlobalKey<FormState>();
  String? name, email, service, message;
  bool submitting = false;
  final List<String> services = [
    'CCTV',
    'Fire Safety',
    'Intruder Alarms',
    'Access Control',
    'Thermal CCTV',
    'System Rentals',
    'Cameratech Electrical',
  ];

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => submitting = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => submitting = false);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Quote request sent!')));
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(title: const Text('Get a Quote')),
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => name = v,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) =>
                    v != null && v.contains('@') ? null : 'Enter a valid email',
                onSaved: (v) => email = v,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Service'),
                items: services
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                validator: (v) => v == null ? 'Select a service' : null,
                onChanged: (v) => service = v,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Message'),
                maxLines: 4,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => message = v,
              ),
              const SizedBox(height: 24),
              submitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Submit'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
