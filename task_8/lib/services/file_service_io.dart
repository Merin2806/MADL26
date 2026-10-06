import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileService {
  Future<String> getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/notes.txt';
  }

  Future<void> saveFile(String content) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/notes.txt');

    await file.writeAsString(content);
  }

  Future<String> readFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/notes.txt');

    if (!await file.exists()) {
      throw Exception('File does not exist. Please save text first.');
    }

    return await file.readAsString();
  }
}