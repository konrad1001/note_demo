import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:note_demo/providers/models/models.dart';

class AppStateAdapter extends TypeAdapter<AppState> {
  @override
  read(BinaryReader reader) {
    final jsonString = reader.readString();
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    return AppState.fromJson(jsonMap);
  }

  @override
  final int typeId = 0;

  @override
  void write(BinaryWriter writer, AppState obj) {
    final jsonString = json.encode(obj.toJson());
    print("encoding::: $jsonString");
    writer.writeString(jsonString);
  }
}
