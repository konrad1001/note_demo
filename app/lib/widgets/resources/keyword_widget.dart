import 'package:flutter/material.dart';
import 'package:note_demo/models/agent_responses/models.dart';

class KeywordDefinitionsWidget extends StatefulWidget {
  final List<KeywordItem> keywords;
  final double width;

  const KeywordDefinitionsWidget({
    Key? key,
    required this.keywords,
    this.width = 700,
  }) : super(key: key);

  @override
  State<KeywordDefinitionsWidget> createState() =>
      _KeywordDefinitionsWidgetState();
}

class _KeywordDefinitionsWidgetState extends State<KeywordDefinitionsWidget> {
  String _searchQuery = '';
  String _selectedLetter = 'All';

  List<KeywordItem> get _filteredKeywords {
    var filtered = widget.keywords;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (kw) =>
                kw.keyword.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                kw.definition.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    // Filter by letter
    if (_selectedLetter != 'All') {
      filtered = filtered
          .where((kw) => kw.keyword.toUpperCase().startsWith(_selectedLetter))
          .toList();
    }

    // Sort alphabetically
    filtered.sort(
      (a, b) => a.keyword.toLowerCase().compareTo(b.keyword.toLowerCase()),
    );

    return filtered;
  }

  Set<String> get _availableLetters {
    final letters = widget.keywords
        .map((kw) => kw.keyword.isNotEmpty ? kw.keyword[0].toUpperCase() : '')
        .where((letter) => letter.isNotEmpty)
        .toSet();
    return letters;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.keywords.isEmpty) {
      return Center(
        child: Text(
          'No keywords available',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    final filteredKeywords = _filteredKeywords;

    return Container(
      width: widget.width,
      constraints: const BoxConstraints(maxHeight: 700),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo[600]!, Colors.indigo[400]!],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.book, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Keyword Glossary',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.keywords.length} terms',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search keywords or definitions...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Alphabet filter
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _LetterChip(
                    letter: 'All',
                    isSelected: _selectedLetter == 'All',
                    onTap: () {
                      setState(() {
                        _selectedLetter = 'All';
                      });
                    },
                  ),
                  const SizedBox(width: 4),
                  ..._availableLetters.map((letter) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: _LetterChip(
                        letter: letter,
                        isSelected: _selectedLetter == letter,
                        onTap: () {
                          setState(() {
                            _selectedLetter = letter;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          // Keywords list
          Flexible(
            child: filteredKeywords.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No keywords found',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filteredKeywords.length,
                    itemBuilder: (context, index) {
                      final keyword = filteredKeywords[index];
                      return _KeywordDefinitionCard(
                        keyword: keyword.keyword,
                        definition: keyword.definition,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _LetterChip extends StatelessWidget {
  final String letter;
  final bool isSelected;
  final VoidCallback onTap;

  const _LetterChip({
    Key? key,
    required this.letter,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo[600] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.indigo[600]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          letter,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _KeywordDefinitionCard extends StatelessWidget {
  final String keyword;
  final String definition;

  const _KeywordDefinitionCard({
    Key? key,
    required this.keyword,
    required this.definition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Keyword
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.indigo[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  keyword[0].toUpperCase(),
                  style: TextStyle(
                    color: Colors.indigo[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  keyword,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[900],
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Divider
          Container(height: 1, color: Colors.grey[200]),
          const SizedBox(height: 12),

          // Definition
          Text(
            definition,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
