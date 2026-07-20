import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/skill_selector.dart';

class StudentProfileScreen extends StatefulWidget {
  final bool standalone;

  const StudentProfileScreen({super.key, this.standalone = false});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  List<String>? _draftSkills;
  bool _saving = false;

  Future<void> _save() async {
    if (_draftSkills == null) return;
    setState(() => _saving = true);
    await context.read<AuthProvider>().updateSkills(_draftSkills!);
    if (!mounted) return;
    setState(() {
      _saving = false;
      _draftSkills = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Skills updated — matching is now personalized.')));
    if (widget.standalone) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();

    final skills = _draftSkills ?? user.skills;
    final dirty = _draftSkills != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.standalone ? 'Your skills' : 'Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (!widget.standalone) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.navy,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name,
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(user.email,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          Text('My skills', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            'These power your match badges and match-based sorting on the Discover feed.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          SkillSelector(
            selected: skills,
            onChanged: (next) => setState(() => _draftSkills = next),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: dirty && !_saving ? _save : null,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Save skills'),
          ),
          if (!widget.standalone) ...[
            const SizedBox(height: 12),
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
}
