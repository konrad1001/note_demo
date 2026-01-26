import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:note_demo/app/theme.dart';
import 'package:note_demo/providers/agent_providers/summary_agent_provider.dart';
import 'package:note_demo/providers/app_notifier.dart';
import 'package:note_demo/providers/models/models.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class NoteAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NoteAppBar({
    super.key,
    required this.onTap,
    required this.isRightPanelOpen,
  });

  final Function() onTap;
  final bool isRightPanelOpen;

  static const kToolBarHeight = 64.0;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 1.0,
      toolbarHeight: kToolBarHeight,
      shadowColor: Colors.black,
      actions: [
        IconButton(
          onPressed: onTap,
          icon: Icon(Icons.auto_awesome),
          iconSize: 20.0,
          color: isRightPanelOpen
              ? NTheme.primary
              : Theme.of(context).unselectedWidgetColor,
        ),
      ],
      actionsPadding: EdgeInsets.only(right: 8),
      flexibleSpace: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: Alignment.center,
          child: Row(
            children: [
              const SizedBox(width: 24),
              _NoteTitle(),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolBarHeight);
}

class _NoteTitle extends ConsumerWidget {
  const _NoteTitle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appNotifierProvider);
    final appNotifier = ref.watch(appNotifierProvider.notifier);
    final summary = ref.watch(summaryAgentProvider);

    final currentTitle = app.userSetFileName ?? app.autoFileName ?? "";

    final maxWidth = MediaQuery.of(context).size.width / 2.5;

    if (app.userSetFileName == null &&
        app.autoFileName == null &&
        summary.isLoading) {
      return _loadingShimmer;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: max(maxWidth, 250)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Opacity(
          opacity: summary.isLoading ? 0.5 : 1.0,
          child: TextField(
            controller: appNotifier.titleController,
            maxLines: 1,
            cursorColor: Colors.black,
            cursorHeight: 17.0,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                gapPadding: 4,
                borderSide: BorderSide(color: Colors.transparent),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                gapPadding: 4,
                borderSide: BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                gapPadding: 4,
                borderSide: BorderSide(color: Colors.black26),
              ),
            ),
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            onChanged: (newText) {
              ref.read(appNotifierProvider.notifier).setUserTitle(newText);
            },
          ),
        ),
      ),
    );
  }

  Widget get _loadingShimmer => Flexible(
    child: Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.0)),
      clipBehavior: Clip.hardEdge,
      child: Shimmer(
        color: NTheme.primary,
        colorOpacity: 0.3,
        duration: Duration(seconds: 1),
        interval: Duration(seconds: 0),
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
  );
}
