String _savedContent = '';

class FileService {
  Future<String> getFilePath() async {
    return 'Browser temporary storage (in memory)';
  }

  Future<void> saveFile(String content) async {
    _savedContent = content;
  }

  Future<String> readFile() async {
    if (_savedContent.isEmpty) {
      throw Exception('No saved content found. Please save text first.');
    }

    return _savedContent;
  }
}