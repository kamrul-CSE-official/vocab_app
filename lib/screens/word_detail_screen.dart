import 'package:flutter/material.dart';
import '../models/word_entry.dart';
import '../services/database_helper.dart';
import 'add_edit_word_screen.dart';

class WordDetailScreen extends StatefulWidget {
  final WordEntry entry;

  const WordDetailScreen({super.key, required this.entry});

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  late WordEntry _entry;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }

  Widget _section(String title, String content, {IconData? icon}) {
    if (content.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: Colors.deepPurple),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(content, style: const TextStyle(fontSize: 16, height: 1.4)),
        ],
      ),
    );
  }

  Widget _chipSection(String title, String raw, {IconData? icon}) {
    final items = WordEntry.splitList(raw);
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: Colors.deepPurple),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map((s) => Chip(
                      label: Text(s),
                      backgroundColor: Colors.deepPurple.shade50,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_entry.word),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditWordScreen(existing: _entry),
                ),
              );
              if (updated == true) {
                // Reload the latest copy from the DB.
                final all = await DatabaseHelper.instance.getAllWords();
                final fresh = all.firstWhere((w) => w.id == _entry.id,
                    orElse: () => _entry);
                setState(() => _entry = fresh);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _section('বাংলা অর্থ · Bangla meaning', _entry.banglaMeaning,
                  icon: Icons.translate),
              _chipSection('Similar words', _entry.synonyms,
                  icon: Icons.sync_alt),
              _chipSection('Opposite words', _entry.antonyms,
                  icon: Icons.compare_arrows),
              _section('Example sentence', _entry.exampleSentence,
                  icon: Icons.format_quote),
              const SizedBox(height: 10),
              Text(
                'Added on ${_entry.createdAt.day}/${_entry.createdAt.month}/${_entry.createdAt.year}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
