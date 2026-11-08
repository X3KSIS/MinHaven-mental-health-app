import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../../../themes/app_colors.dart';

class SearchFilterWidget extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onMoodFilterChanged;
  final String selectedMoodFilter;

  const SearchFilterWidget({
    super.key,
    required this.onSearchChanged,
    required this.onMoodFilterChanged,
    required this.selectedMoodFilter,
  });

  @override
  State<SearchFilterWidget> createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final newQuery = _searchController.text;
    if (_searchQuery != newQuery) {
      _searchQuery = newQuery;
      widget.onSearchChanged(newQuery);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    widget.onSearchChanged('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search entries...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _clearSearch,
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        // Mood Filter Chips
        if (JournalConstants.moods.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('All Moods'),
                  selected: widget.selectedMoodFilter.isEmpty,
                  onSelected: (selected) => widget.onMoodFilterChanged(''),
                  backgroundColor: context.subtleFill,
                  selectedColor: primaryColor.withValues(alpha: 0.2),
                ),
                ...JournalConstants.moods.map((mood) => FilterChip(
                  label: Text(mood),
                  selected: widget.selectedMoodFilter == mood,
                  onSelected: (selected) => widget.onMoodFilterChanged(selected ? mood : ''),
                  backgroundColor: context.subtleFill,
                  selectedColor: primaryColor.withValues(alpha: 0.2),
                  checkmarkColor: primaryColor,
                )),
              ],
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}