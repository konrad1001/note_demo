import 'package:flutter/material.dart';
import 'package:note_demo/app/theme.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class NoteAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NoteAppBar({
    super.key,
    required this.studyContent,
    required this.onTap,
    required this.isLoading,
    required this.isRightPanelOpen,
  });

  final bool isLoading;
  final SummaryAgentState studyContent;
  final Function() onTap;
  final bool isRightPanelOpen;

  static const kToolBarHeight = 64.0;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      scrolledUnderElevation: 1.0,
      toolbarHeight: kToolBarHeight,
      shadowColor: Colors.black,
      actions: [
        IconButton(
          onPressed: onTap,
          icon: Icon(Icons.auto_awesome),
          iconSize: 20.0,
          color: isRightPanelOpen ? NTheme.primary : NTheme.greyed,
        ),
      ],
      actionsPadding: EdgeInsets.only(right: 8),
      flexibleSpace: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: Alignment.center,
          child: Row(
            children: [
              const SizedBox(width: 48),
              studyContent.maybeWhen(
                idle: (design, isLoading) => Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Opacity(
                      opacity: isLoading ? 0.5 : 1.0,
                      child: Text(
                        design.title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                orElse: () {
                  return (isLoading || studyContent is SummaryAgentStateLoading)
                      ? Flexible(
                          child: Container(
                            child: Shimmer(
                              color: Colors.black,
                              duration: Duration(milliseconds: 900),
                              interval: Duration(milliseconds: 200),
                              child: Text(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                "Placeholder. Placeholder. Placeholder",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolBarHeight);
}
