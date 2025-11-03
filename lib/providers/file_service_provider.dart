import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_demo/util/file_service.dart';

final fileServiceProvider = Provider<FileService>((ref) => FileService());
