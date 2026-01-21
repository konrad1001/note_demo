import 'dart:convert';

import 'package:hive_ce/hive.dart';
import 'package:note_demo/providers/models/models.dart';

class MetaDataAdapter extends TypeAdapter<NMetaData> {
  @override
  read(BinaryReader reader) {
    final jsonString = reader.readString();
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    return NMetaData.fromJson(jsonMap);
  }

  @override
  final int typeId = 0;

  @override
  void write(BinaryWriter writer, NMetaData obj) {
    final jsonString = json.encode(obj.toJson());
    writer.writeString(jsonString);
  }
}
