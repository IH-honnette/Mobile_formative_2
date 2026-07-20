import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/startup_provider.dart';
import '../../widgets/startup_avatar.dart';
import '../../widgets/status_badge.dart';
import 'create_startup_screen.dart' show kSectors, kStages;

class StartupProfileScreen extends StatefulWidget {
  const StartupProfileScreen({super.key});

  @override
  State<StartupProfileScreen> createState() => _StartupProfileScreenState();
}

class _StartupProfileScreenState extends State<StartupProfileScreen> {
  bool _editing = false;
  bool _saving = false;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  String? _sector;
  String? _stage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _startEditing() {
    final startup = context.read<StartupProvider>().myStartup!;
    _nameController.text = startup.name;
    _descriptionController.text = startup.description;
    _sector = startup.sector;
    _stage = startup.stage;
    setState(() => _editing = true);
  }

  Future<void> _save() async {
    final provider = context.read<StartupProvider>();
    final startup = provider.myStartup!;
    if (_nameController.text.trim().length < 2 ||
        _descriptionController.text.trim().length < 30) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Name and a 30+ character description are required.')));
      return;
    }
    setState(() => _saving = true);
    await provider.updateProfile(
      id: startup.id,
      name: _nameController.text,
      sector: _sector!,
      stage: _stage!,
      description: _descriptionController.text,
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _editing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Startup profile updated.')));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final startup = context.watch<StartupProvider>().myStartup;
    if (startup == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup'),
        actions: [
          if (!_editing)
            IconButton(
                tooltip: 'Edit profile',
                onPressed: _startEditing,
                icon: const Icon(Icons.edit_rounded)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              StartupAvatar(name: startup.name, size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(startup.name,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    StatusBadge.verification(startup.verificationStatus),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_editing) ...[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Startup name'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _sector,
              decoration: const InputDecoration(labelText: 'Sector'),
              items: kSectors
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _sector = v),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _stage,
              decoration: const InputDecoration(labelText: 'Stage'),
              items: kStages
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _stage = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              maxLength: 600,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _saving ? null : () => setState(() => _editing = false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ] else ...[
            _infoRow(context, 'Sector', startup.sector),
            _infoRow(context, 'Stage', startup.stage),
            _infoRow(context, 'Founder', auth.user?.name ?? ''),
            const SizedBox(height: 10),
            Text('About', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(startup.description,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: auth.signOut,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Log out'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child:
                Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
