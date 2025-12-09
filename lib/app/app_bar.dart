import 'package:flutter/material.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class NoteAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NoteAppBar({
    super.key,
    required TabController tabController,
    required this.studyContent,
    required this.onTap,
    required this.isLoading,
  }) : _tabController = tabController;

  final bool isLoading;
  final TabController _tabController;
  final SummaryAgentState studyContent;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      toolbarHeight: 47,
      flexibleSpace: PreferredSize(
        preferredSize: Size(0, 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Row(
              children: [
                const SizedBox(width: 48),
                SizedBox(
                  width: 100,
                  child: TabBar(
                    controller: _tabController,
                    dividerHeight: 0,
                    onTap: onTap,
                    indicatorWeight: 1,
                    tabs: const <Widget>[
                      Tab(icon: Icon(Icons.edit, size: 16)),
                      Tab(icon: Icon(Icons.auto_awesome, size: 16)),
                    ],
                  ),
                ),
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
                    return (isLoading ||
                            studyContent is SummaryAgentStateLoading)
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
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(47.0);
}
