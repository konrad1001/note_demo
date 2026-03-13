import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:note_demo/models/agent_responses/models.dart';

class FlashcardWidget extends StatefulWidget {
  final List<FlashcardItem> flashcards;
  final double height;
  final double width;

  const FlashcardWidget({
    super.key,
    required this.flashcards,
    this.height = 400,
    this.width = 600,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  int _currentIndex = 0;
  bool _showBack = false;

  void _nextCard() {
    if (_currentIndex < widget.flashcards.length - 1) {
      setState(() {
        _currentIndex++;
        _showBack = false;
      });
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showBack = false;
      });
    }
  }

  void _flipCard() {
    setState(() {
      _showBack = !_showBack;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flashcards.isEmpty) {
      return Center(
        child: Text(
          'No flashcards available',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    final currentCard = widget.flashcards[_currentIndex];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Row(
            children: [
              Text(
                '${_currentIndex + 1} / ${widget.flashcards.length}',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / widget.flashcards.length,
                  backgroundColor: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        GestureDetector(
          onTap: _flipCard,
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              _previousCard();
            } else if (details.primaryVelocity! < 0) {
              _nextCard();
            }
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              final rotate = Tween(begin: math.pi, end: 0.0).animate(animation);
              return AnimatedBuilder(
                animation: rotate,
                child: child,
                builder: (context, child) {
                  final value = math.min(rotate.value, math.pi / 2);
                  return Transform(
                    transform: Matrix4.rotationY(value),
                    alignment: Alignment.center,
                    child: child,
                  );
                },
              );
            },
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            child: _FlashcardFace(
              key: ValueKey(_showBack),
              content: _showBack ? currentCard.back : currentCard.front,
              isBack: _showBack,
              height: widget.height,
              width: widget.width,
            ),
          ),
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filled(
              onPressed: _currentIndex > 0 ? _previousCard : null,
              icon: const Icon(Icons.chevron_left),
              iconSize: 32,
              tooltip: 'Previous card',
            ),
            const SizedBox(width: 24),

            ElevatedButton.icon(
              onPressed: _flipCard,
              icon: const Icon(Icons.flip),
              label: Text(_showBack ? 'Show Front' : 'Show Back'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(width: 24),

            IconButton.filled(
              onPressed: _currentIndex < widget.flashcards.length - 1
                  ? _nextCard
                  : null,
              icon: const Icon(Icons.chevron_right),
              iconSize: 32,
              tooltip: 'Next card',
            ),
          ],
        ),
        const SizedBox(height: 8),

        Text(
          'Tap to flip • Navigate using arrows',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}

class _FlashcardFace extends StatelessWidget {
  final String content;
  final bool isBack;
  final double height;
  final double width;

  const _FlashcardFace({
    super.key,
    required this.content,
    required this.isBack,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: isBack
            ? Theme.of(context).canvasColor
            : Theme.of(context).cardColor,

        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: SingleChildScrollView(
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
