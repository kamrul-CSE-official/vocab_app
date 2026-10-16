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
      SnackBar(
        content: Text('"${entry.word}" deleted'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6C5CE7), Color(0xFF8E7CF8), Color(0xFFF7F8FC)],
            stops: [0.0, 0.28, 0.28],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.menu_book_rounded,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Vocabulary',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Learn a new word every day',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Word count badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_stories,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${_words.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Body card
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7F8FC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Search
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (_) => _loadWords(),
                          decoration: InputDecoration(
                            hintText: 'Search word or meaning...',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            prefixIcon: const Icon(Icons.search,
                                color: Color(0xFF6C5CE7)),
                            suffixIcon: _searchCtrl.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear,
                                        color: Colors.grey),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      _loadWords();
                                    },
                                  )
                                : null,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: _loading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFF6C5CE7)),
                              )
                            : _words.isEmpty
                                ? _EmptyState(
                                    hasQuery:
                                        _searchCtrl.text.trim().isNotEmpty)
                                : RefreshIndicator(
                                    color: const Color(0xFF6C5CE7),
                                    onRefresh: _loadWords,
                                    child: ListView.builder(
                                      padding: const EdgeInsets.only(
                                          bottom: 100, top: 4),
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
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C5CE7).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _openAddScreen,
          backgroundColor: const Color(0xFF6C5CE7),
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Add Word',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6C5CE7).withOpacity(0.12),
                    const Color(0xFF00B894).withOpacity(0.12),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasQuery
                    ? Icons.search_off_rounded
                    : Icons.auto_stories_rounded,
                size: 56,
                color: const Color(0xFF6C5CE7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasQuery ? 'No matching words found' : 'Your vocabulary is empty',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF2D3436),
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasQuery
                  ? 'Try a different keyword.'
                  : 'Tap "Add Word" to start building your list.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
