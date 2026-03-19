import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_demo/models/agent_responses/models.dart';

class KeywordDefinitionsWidget extends StatelessWidget {
  final List<KeywordItem> keywords;
  final double width;

  const KeywordDefinitionsWidget({
    Key? key,
    required this.keywords,
    this.width = 700,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (keywords.isEmpty) {
      return Center(
        child: Text(
          'No keywords available',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return Container(
      width: width,
      constraints: const BoxConstraints(maxHeight: 700),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...keywords.map(
            (keyword) => _KeywordDefinitionCard(
              keyword: keyword.keyword,
              definition: keyword.definition,
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
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    keyword[0].toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    keyword,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Opacity(opacity: 0.5, child: const Divider(height: 1)),
            const SizedBox(height: 12),

            Opacity(
              opacity: 0.5,
              child: Text(definition, style: GoogleFonts.ptSerif()),
            ),
          ],
        ),
      ),
    );
  }
}
