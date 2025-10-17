import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DemoWidgetCubit extends Cubit<AppState> {
  DemoWidgetCubit() : super(AppState(controller: TextEditingController())) {
    print("init");
  }
}

class AppState {
  final TextEditingController controller;

  AppState({required this.controller});
}
