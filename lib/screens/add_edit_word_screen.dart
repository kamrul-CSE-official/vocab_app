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
          SnackBar(
            content: Text('Failed to save: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          labelStyle: TextStyle(color: color.withOpacity(0.9)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: color, width: 1.6),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF6C5CE7);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primary, Color(0xFF8E7CF8)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        _isEditing ? 'Edit Word' : 'Add New Word',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7F8FC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _field(
                          controller: _wordCtrl,
                          label: 'Word',
                          icon: Icons.menu_book_rounded,
                          color: primary,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter a word'
                              : null,
                        ),
                        _field(
                          controller: _banglaCtrl,
                          label: 'বাংলা অর্থ (Bangla meaning)',
                          icon: Icons.translate_rounded,
                          color: const Color(0xFF00B894),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter the Bangla meaning'
                              : null,
                        ),
                        _field(
                          controller: _synonymsCtrl,
                          label: 'Similar words (synonyms)',
                          hint: 'comma separated, e.g. happy, glad',
                          icon: Icons.sync_alt_rounded,
                          color: const Color(0xFF0984E3),
                        ),
                        _field(
                          controller: _antonymsCtrl,
                          label: 'Opposite words (antonyms)',
                          hint: 'comma separated, e.g. sad, unhappy',
                          icon: Icons.compare_arrows_rounded,
                          color: const Color(0xFFE17055),
                        ),
                        _field(
                          controller: _exampleCtrl,
                          label: 'Example sentence',
                          icon: Icons.format_quote_rounded,
                          color: const Color(0xFFD63031),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _saving ? null : _save,
                              icon: _saving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.check_rounded),
                              label: Text(
                                _isEditing ? 'Update Word' : 'Save Word',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
