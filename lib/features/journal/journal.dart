import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mental_health_app/features/journal/utils/constants.dart';
import 'package:uuid/uuid.dart';
import 'Journal_Components/journal_entry_card.dart';
import 'Journal_Components/search_filter.dart';
import 'data/model/journal_model.dart';
import '../gamification/data/services/gamification_service.dart';
import '../../themes/app_colors.dart';

// Journal Service Class
class JournalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  final GamificationService _gamificationService = GamificationService();

  // Save journal entry
  Future<void> saveEntry(JournalEntry entry) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('journal')
        .doc(entry.id)
        .set(entry.toMap());

    // Track gamification
    final wordCount = entry.content.split(' ').length;
    await _gamificationService.trackJournalEntry(wordCount: wordCount);
  }

  // Get all journal entries
  Stream<List<JournalEntry>> getEntries() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('journal')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => JournalEntry.fromMap(doc.data()))
        .toList());
  }

  // Delete journal entry
  Future<void> deleteEntry(String entryId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('journal')
        .doc(entryId)
        .delete();
  }

  // Update journal entry
  Future<void> updateEntry(JournalEntry entry) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('journal')
        .doc(entry.id)
        .update({
      'title': entry.title,
      'content': entry.content,
      'updatedAt': entry.updatedAt,
      'mood': entry.mood,
    });
  }
}

// Journal Screen
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final JournalService _journalService = JournalService();
  String _searchQuery = '';
  String _selectedMoodFilter = '';

  void _navigateToEditor({JournalEntry? entry}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JournalEditorScreen(entry: entry),
      ),
    );
  }

  void _showDeleteDialog(JournalEntry entry) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Entry',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        content: const Text('Are you sure you want to delete this journal entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: context.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              await _journalService.deleteEntry(entry.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Journal entry deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  List<JournalEntry> _filterEntries(List<JournalEntry> entries) {
    return entries.where((entry) {
      final matchesSearch = _searchQuery.isEmpty ||
          entry.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          entry.content.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesMood = _selectedMoodFilter.isEmpty || entry.mood == _selectedMoodFilter;
      return matchesSearch && matchesMood;
    }).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onMoodFilterChanged(String mood) {
    setState(() {
      _selectedMoodFilter = mood;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        title: Text(
          'My Journal',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 4,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search and Filter Widget
          SearchFilterWidget(
            onSearchChanged: _onSearchChanged,
            onMoodFilterChanged: _onMoodFilterChanged,
            selectedMoodFilter: _selectedMoodFilter,
          ),
          // Entries List
          Expanded(
            child: StreamBuilder<List<JournalEntry>>(
              stream: _journalService.getEntries(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading journal entries',
                      style: TextStyle(color: context.textMuted),
                    ),
                  );
                }

                final entries = snapshot.data ?? [];
                final filteredEntries = _filterEntries(entries);

                if (filteredEntries.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredEntries.length,
                  itemBuilder: (context, index) {
                    final entry = filteredEntries[index];
                    return JournalEntryCard(
                      entry: entry,
                      primaryColor: primaryColor,
                      onTap: () => _navigateToEditor(entry: entry),
                      onEdit: () => _navigateToEditor(entry: entry),
                      onDelete: () => _showDeleteDialog(entry),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToEditor(),
        backgroundColor: primaryColor,
        icon: Icon(Icons.add, color: context.onPrimary),
        label: Text(
          'New Entry',
          style: TextStyle(color: context.onPrimary, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 80,
            color: context.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'No journal entries found',
            style: TextStyle(
              fontSize: 18,
              color: context.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter',
            style: TextStyle(
              fontSize: 14,
              color: context.textFaint,
            ),
          ),
        ],
      ),
    );
  }
}

// Journal Editor Screen
class JournalEditorScreen extends StatefulWidget {
  final JournalEntry? entry;

  const JournalEditorScreen({super.key, this.entry});

  @override
  State<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends State<JournalEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final JournalService _journalService = JournalService();
  final Uuid _uuid = const Uuid();
  String _selectedMood = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title;
      _contentController.text = widget.entry!.content;
      _selectedMood = widget.entry!.mood;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both title and content')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final entry = JournalEntry(
        id: widget.entry?.id ?? _uuid.v4(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        createdAt: widget.entry?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        mood: _selectedMood,
      );

      if (widget.entry != null) {
        await _journalService.updateEntry(entry);
      } else {
        await _journalService.saveEntry(entry);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.entry != null
              ? 'Entry updated successfully'
              : 'Entry saved successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save entry: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: context.background,
      appBar: AppBar(
        title: Text(
          widget.entry != null ? 'Edit Entry' : 'New Entry',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 4,
        centerTitle: true,
        actions: [
          if (_isSaving)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: context.onPrimary,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveEntry,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Entry Title',
                hintStyle: TextStyle(color: context.textFaint),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'How are you feeling?',
              style: TextStyle(
                fontSize: 14,
                color: context.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: JournalConstants.moods.map((mood) {
                final isSelected = _selectedMood == mood;
                return FilterChip(
                  label: Text(mood),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedMood = selected ? mood : '';
                    });
                  },
                  selectedColor: primaryColor.withValues(alpha: 0.2),
                  checkmarkColor: primaryColor,
                  backgroundColor: context.subtleFill,
                  labelStyle: TextStyle(
                    color: isSelected ? primaryColor : context.textPrimary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _contentController,
              style: TextStyle(
                fontSize: 16,
                color: context.textPrimary,
                height: 1.5,
              ),
              maxLines: null,
              minLines: 15,
              decoration: InputDecoration(
                hintText: 'Write your thoughts here...',
                hintStyle: TextStyle(color: context.textHint),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.borderStrong),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}