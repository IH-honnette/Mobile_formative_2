import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/startup_provider.dart';
import '../../theme/app_theme.dart';

const List<String> kSectors = [
  'AgriTech', 'EdTech', 'FinTech', 'HealthTech', 'E-commerce',
  'Creative & Media', 'Logistics', 'Sustainability', 'Community', 'Other',
];

const List<String> kStages = ['Idea', 'MVP', 'Early revenue', 'Growing'];

/// One-time onboarding for founders. The created startup enters the
/// verification queue — founders see a clear explanation of why they
/// can't post yet.
class CreateStartupScreen extends StatefulWidget {
  const CreateStartupScreen({super.key});

  @override
  State<CreateStartupScreen> createState() => _CreateStartupScreenState();
}

class _CreateStartupScreenState extends State<CreateStartupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _sector = kSectors.first;
  String _stage = kStages.first;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await context.read<StartupProvider>().createStartup(
            ownerUid: context.read<AuthProvider>().uid,
            name: _nameController.text,
            sector: _sector,
            stage: _stage,
            description: _descriptionController.text,
          );
      // FounderShell flips to the dashboard when the stream emits.
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not create the startup. Try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your startup'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: auth.signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tell us about your venture',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text(
                  'The Stint team reviews every startup before it can '
                  'post opportunities. This keeps the platform trustworthy '
                  'for students.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration:
                      const InputDecoration(hintText: 'Startup name'),
                  validator: (v) => (v == null || v.trim().length < 2)
                      ? 'Startup name is required.'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _sector,
                  decoration: const InputDecoration(labelText: 'Sector'),
                  items: kSectors
                      .map((s) =>
                          DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _sector = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _stage,
                  decoration: const InputDecoration(labelText: 'Stage'),
                  items: kStages
                      .map((s) =>
                          DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _stage = v!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  maxLength: 600,
                  decoration: const InputDecoration(
                      hintText:
                          'What does your startup do? What problem does it solve at ALU or beyond?'),
                  validator: (v) => (v == null || v.trim().length < 30)
                      ? 'Describe your startup in at least 30 characters.'
                      : null,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Submit for verification'),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warningSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield_rounded,
                          color: AppTheme.warning, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Verification usually takes less than a day. You can prepare postings once approved.',
                          style: TextStyle(fontSize: 12.5, height: 1.4),
                        ),
                      ),
                    ],
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
