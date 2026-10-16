import 'package:flutter/material.dart';
import '../models/word_entry.dart';
import '../services/database_helper.dart';

class AddEditWordScreen extends StatefulWidget {
  final WordEntry? existing;

  const AddEditWordScreen({super.key, this.existing});

  @override
  State<AddEditWordScreen> createState() => _AddEditWordScreenState();
}

class _AddEditWordScreenState extends State<AddEditWordScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _wordCtrl;
  late final TextEditingController _banglaCtrl;
  late final TextEditingController _synonymsCtrl;
  late final TextEditingController _antonymsCtrl;
  late final TextEditingController _exampleCtrl;

  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _wordCtrl = TextEditingController(text: e?.word ?? '');
    _banglaCtrl = TextEditingController(text: e?.banglaMeaning ?? '');
    _synonymsCtrl = TextEditingController(text: e?.synonyms ?? '');
    _antonymsCtrl = TextEditingController(text: e?.antonyms ?? '');
    _exampleCtrl = TextEditingController(text: e?.exampleSentence ?? '');
  }

  @override
  void dispose() {
    _wordCtrl.dispose();
    _banglaCtrl.dispose();
    _synonymsCtrl.dispose();
    _antonymsCtrl.dispose();
    _exampleCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final entry = WordEntry(
      id: widget.existing?.id,
      word: _wordCtrl.text.trim(),
      banglaMeaning: _banglaCtrl.text.trim(),
      synonyms: _synonymsCtrl.text.trim(),
      antonyms: _antonymsCtrl.text.trim(),
      exampleSentence: _exampleCtrl.text.trim(),
      createdAt: widget.existing?.createdAt,
    );

    try {
      if (_isEditing) {
        await DatabaseHelper.instance.updateWord(entry);
      } else {
        await DatabaseHelper.instance.insertWord(entry);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _decoration(String label, {String? hint, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Word' : 'Add New Word'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _wordCtrl,
                decoration: _decoration('Word', icon: Icons.menu_book),
                textCapitalization: TextCapitalization.none,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a word' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _banglaCtrl,
                decoration: _decoration('বাংলা অর্থ (Bangla meaning)',
                    icon: Icons.translate),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Enter the Bangla meaning'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _synonymsCtrl,
                decoration: _decoration(
                  'Similar words (synonyms)',
                  hint: 'comma separated, e.g. happy, glad, joyful',
                  icon: Icons.sync_alt,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _antonymsCtrl,
                decoration: _decoration(
                  'Opposite words (antonyms)',
                  hint: 'comma separated, e.g. sad, unhappy',
                  icon: Icons.compare_arrows,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _exampleCtrl,
                decoration: _decoration('Example sentence',
                    icon: Icons.format_quote),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check),
                  label: Text(_isEditing ? 'Update Word' : 'Save Word'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
