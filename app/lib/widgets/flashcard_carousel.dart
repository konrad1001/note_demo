import 'package:flutter/material.dart';
import 'package:note_demo/models/agent_responses/models.dart';

class FlashcardCarousel extends StatefulWidget {
  const FlashcardCarousel({super.key, required this.items, this.onFlip});

  final List<FlashcardItem> items;
  final Function(int index, bool isFlipped)? onFlip;

  @override
  State<FlashcardCarousel> createState() => _FlashcardCarouselState();
}

class _FlashcardCarouselState extends State<FlashcardCarousel>
    with TickerProviderStateMixin {
  late PageController _pageController;
  final Map<int, bool> _flippedState = {};
  final Map<int, AnimationController> _animationControllers = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Initialize all cards as not flipped
    for (int i = 0; i < widget.items.length; i++) {
      _flippedState[i] = false;
      _animationControllers[i] = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _flipCard(int index) {
    final isFlipped = _flippedState[index] ?? false;
    _flippedState[index] = !isFlipped;

    if (!isFlipped) {
      _animationControllers[index]?.forward();
    } else {
      _animationControllers[index]?.reverse();
    }

    widget.onFlip?.call(index, !isFlipped);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 600,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  return FlashcardWidget(
                    item: widget.items[index],
                    isFlipped: _flippedState[index] ?? false,
                    animationController: _animationControllers[index]!,
                    onTap: () => _flipCard(index),
                  );
                },
              ),
            ),
            IconButton(
              iconSize: 12,
              onPressed: () => _pageController.nextPage(
                duration: Duration(seconds: 1),
                curve: Curves.bounceInOut,
              ),
              icon: Icon(Icons.chevron_right),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ' / ${widget.items.length}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FlashcardWidget extends StatelessWidget {
  const FlashcardWidget({
    super.key,
    required this.item,
    required this.isFlipped,
    required this.animationController,
    required this.onTap,
  });

  final FlashcardItem item;
  final bool isFlipped;
  final AnimationController animationController;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          final angle = animationController.value * 3.14159;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          final shouldRender = animationController.value < 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Front side
                  if (shouldRender)
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(0),
                      child: _buildCardContent(
                        title: 'Front',
                        content: item.front,
                      ),
                    ),
                  // Back side
                  if (!shouldRender)
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(3.14159),
                      child: _buildCardContent(
                        title: 'Back',
                        content: item.back,
                        isBack: true,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardContent({
    required String title,
    required String content,
    bool isBack = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            content,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              fontStyle: isBack ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Tap to flip',
            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
