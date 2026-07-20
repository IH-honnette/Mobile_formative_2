import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/opportunity.dart';
import '../../models/startup.dart';
import '../../providers/opportunity_provider.dart';
import '../../widgets/skill_selector.dart';

const List<String> kCommitments = [
  'Part-time',
  'Full-time',
  'Flexible hours',
  'Project-based',
];

class PostOpportunityScreen extends StatefulWidget {
  final Startup startup;
  final Opportunity? existing;

  const PostOpportunityScreen(
      {super.key, required this.startup, this.existing});

  @override
  State<PostOpportunityScreen> createState() => _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends State<PostOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late String _category;
  late String _commitment;
  late bool _paid;
  late List<String> _requiredSkills;
  late DateTime _deadline;
  bool _submitting = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _descriptionController =
        TextEditingController(text: existing?.description ?? '');
    _category = existing?.category ?? kOpportunityCategories.first;
    _commitment = existing?.commitment ?? kCommitments.first;
    _paid = existing?.paid ?? false;
    _requiredSkills = List<String>.from(existing?.requiredSkills ?? []);
    _deadline =
        existing?.deadline ?? DateTime.now().add(const Duration(days: 14));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_requiredSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Select at least one required skill — it powers student matching.')));
      return;
    }
    setState(() => _submitting = true);
    final provider = context.read<OpportunityProvider>();
    try {
      if (_isEdit) {
        await provider.update(widget.existing!.id, {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'category': _category,
          'requiredSkills': _requiredSkills,
          'paid': _paid,
          'commitment': _commitment,
          'deadline': _deadline,
        });
      } else {
        await provider.create(Opportunity(
          id: '',
          startupId: widget.startup.id,
          startupName: widget.startup.name,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _category,
          requiredSkills: _requiredSkills,
          paid: _paid,
          commitment: _commitment,
          deadline: _deadline,
          createdAt: DateTime.now(),
        ));
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEdit
              ? 'Posting updated.'
              : 'Opportunity posted — students can see it right now.')));
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save. Try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_isEdit ? 'Edit posting' : 'Post an opportunity')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                      hintText: 'Role title, e.g. "Flutter Developer Intern"'),
                  validator: (v) => (v == null || v.trim().length < 5)
                      ? 'Give the role a clear title.'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: kOpportunityCategories
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _commitment,
                  decoration: const InputDecoration(labelText: 'Commitment'),
                  items: kCommitments
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _commitment = v!),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: _paid,
                  onChanged: (v) => setState(() => _paid = v),
                  title: const Text('This is a paid role',
                      style: TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w600)),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_rounded),
                  title: Text(
                      'Deadline: ${DateFormat('MMM d, yyyy').format(_deadline)}',
                      style: const TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w600)),
                  trailing: TextButton(
                      onPressed: _pickDeadline, child: const Text('Change')),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 6,
                  maxLength: 1000,
                  decoration: const InputDecoration(
                      hintText:
                          'Describe the role: what the intern will do, what they will learn, how you will support them…'),
                  validator: (v) => (v == null || v.trim().length < 40)
                      ? 'Describe the role in at least 40 characters.'
                      : null,
                ),
                const SizedBox(height: 8),
                Text('Required skills',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                SkillSelector(
                  selected: _requiredSkills,
                  onChanged: (next) =>
                      setState(() => _requiredSkills = next),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(_isEdit ? 'Save changes' : 'Publish opportunity'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
