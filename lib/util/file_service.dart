import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class FileService {
  Future<File?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'md'],
    );

    if (result != null) {
      return File(result.files.single.path!);
    } else {
      return null;
    }
  }

  Future<String?> saveFile(String content) async {
    return await FilePicker.platform.saveFile(
      dialogTitle: 'Please select an output file:',
      type: FileType.custom,
      allowedExtensions: ['txt', 'md'],
      bytes: Uint8List.fromList(content.codeUnits),
    );
  }
}
