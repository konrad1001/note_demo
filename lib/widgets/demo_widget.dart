import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_demo/widgets/ai_screen.dart';
import 'package:note_demo/widgets/demo_widget_cubit.dart';
import 'package:note_demo/widgets/text_editor.dart';

class DemoWidget extends StatefulWidget {
  const DemoWidget({super.key});

  @override
  State<DemoWidget> createState() => _DemoWidgetState();
}

class _DemoWidgetState extends State<DemoWidget> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DemoWidgetCubit(),
      child: BlocBuilder<DemoWidgetCubit, AppState>(
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: const Text("Notes demo"),
            bottom: TabBar(
              controller: _tabController,
              onTap: (index) {
                print("swupe, $index");
                if (index == 1) context.read<DemoWidgetCubit>().fetch();
              },
              tabs: const <Widget>[
                Tab(text: "Write"),
                Tab(text: "Revise"),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[
              Center(child: TextEditor(controller: state.controller)),
              Center(
                child: AIScreen(
                  controller: TextEditingController(text: state.modelAnswer),
                  isLoading: state.isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
