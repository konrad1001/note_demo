import 'package:flutter/material.dart';
import 'package:note_demo/models/agent_responses/models.dart';

class QuestionAnswerWidget extends StatefulWidget {
  final List<QuestionAnswerItem> questionAnswers;
  final double width;

  const QuestionAnswerWidget({
    Key? key,
    required this.questionAnswers,
    this.width = 700,
  }) : super(key: key);

  @override
  State<QuestionAnswerWidget> createState() => _QuestionAnswerWidgetState();
}

class _QuestionAnswerWidgetState extends State<QuestionAnswerWidget> {
  final Set<int> _expandedIndices = {};
  bool _expandAll = false;

  void _toggleExpanded(int index) {
    setState(() {
      if (_expandedIndices.contains(index)) {
        _expandedIndices.remove(index);
      } else {
        _expandedIndices.add(index);
      }
    });
  }

  void _toggleExpandAll() {
    setState(() {
      _expandAll = !_expandAll;
      if (_expandAll) {
        _expandedIndices.addAll(
          List.generate(widget.questionAnswers.length, (i) => i),
        );
      } else {
        _expandedIndices.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questionAnswers.isEmpty) {
      return Center(
        child: Text(
          'No questions available',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return Container(
      width: widget.width,
      constraints: const BoxConstraints(maxHeight: 600),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with expand/collapse all
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.questionAnswers.length} Questions',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _toggleExpandAll,
                  icon: Icon(
                    _expandAll ? Icons.unfold_less : Icons.unfold_more,
                  ),
                  label: Text(_expandAll ? 'Collapse All' : 'Expand All'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable Q&A list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16.0),
              itemCount: widget.questionAnswers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final qa = widget.questionAnswers[index];
                final isExpanded = _expandedIndices.contains(index);

                return _QuestionAnswerCard(
                  questionNumber: index + 1,
                  question: qa.question,
                  answer: qa.answer,
                  isExpanded: isExpanded,
                  onTap: () => _toggleExpanded(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionAnswerCard extends StatelessWidget {
  final int questionNumber;
  final String question;
  final String answer;
  final bool isExpanded;
  final VoidCallback onTap;

  const _QuestionAnswerCard({
    Key? key,
    required this.questionNumber,
    required this.question,
    required this.answer,
    required this.isExpanded,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isExpanded ? 4 : 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isExpanded
              ? Theme.of(context).primaryColor.withOpacity(0.3)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question number badge
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Q$questionNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Question text
                  Expanded(
                    child: Text(
                      question,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),

                  // Expand/collapse icon
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),

              // Answer (animated reveal)
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[200]!, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ANSWER',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            answer,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  height: 1.6,
                                  color: Colors.grey[800],
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
