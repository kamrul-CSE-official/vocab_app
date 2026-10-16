import 'package:flutter/material.dart';
import '../models/word_entry.dart';
import '../services/database_helper.dart';
import '../widgets/word_list_item.dart';
import 'add_edit_word_screen.dart';
import 'word_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<WordEntry> _words = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadWords() async {
    setState(() => _loading = true);
    final query = _searchCtrl.text.trim();
    final words = query.isEmpty
        ? await DatabaseHelper.instance.getAllWords()
        : await DatabaseHelper.instance.searchWords(query);
    if (!mounted) return;
    setState(() {
      _words = words;
      _loading = false;
    });
  }

  Future<void> _deleteWord(WordEntry entry) async {
    await DatabaseHelper.instance.deleteWord(entry.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${entry.word}" deleted')),
    );
    _loadWords();
  }

  Future<void> _openAddScreen() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditWordScreen()),
    );
    if (saved == true) _loadWords();
  }

  Future<void> _openDetail(WordEntry entry) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WordDetailScreen(entry: entry)),
    );
    _loadWords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vocabulary'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => _loadWords(),
                decoration: InputDecoration(
                  hintText: 'Search word or meaning...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchCtrl.clear();
                            _loadWords();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _words.isEmpty
                      ? _EmptyState(
                          hasQuery: _searchCtrl.text.trim().isNotEmpty)
                      : RefreshIndicator(
                          onRefresh: _loadWords,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 90, top: 4),
                            itemCount: _words.length,
                            itemBuilder: (context, index) {
                              final entry = _words[index];
                              return WordListItem(
                                entry: entry,
                                onTap: () => _openDetail(entry),
                                onDelete: () => _deleteWord(entry),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddScreen,
        icon: const Icon(Icons.add),
        label: const Text('Add Word'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasQuery;
  const _EmptyState({required this.hasQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              hasQuery
                  ? 'No matching words found'
                  : 'No words yet.\nTap "Add Word" to save your first one.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
