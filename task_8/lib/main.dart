
import 'package:flutter/material.dart';
import 'services/file_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter File Handling',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const FileHandlingPage(),
    );
  }
}

class FileHandlingPage extends StatefulWidget {
  const FileHandlingPage({super.key});

  @override
  State<FileHandlingPage> createState() =>
      _FileHandlingPageState();
}

class _FileHandlingPageState
    extends State<FileHandlingPage> {
  final FileService _fileService = FileService();

  final TextEditingController _controller =
      TextEditingController();

  String _fileContent = '';
  String _filePath = '';
  String _status = 'No file operation performed yet.';
  bool _loading = false;

  // 2. ACCESS STORAGE
  Future<void> getFileLocation() async {
    setState(() {
      _loading = true;
    });

    try {
      final path = await _fileService.getFilePath();

      setState(() {
        _filePath = path;
        _status = 'Storage location accessed successfully.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error accessing storage: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // 3. CREATE AND WRITE FILE
  Future<void> saveFile() async {
    setState(() {
      _loading = true;
    });

    try {
      final content = _controller.text;

      if (content.trim().isEmpty) {
        throw Exception('Please enter some text first.');
      }

      final path = await _fileService.getFilePath();

      await _fileService.saveFile(content);

      setState(() {
       _filePath = path;
       _fileContent = content;
       _status = 'File created and saved successfully!';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File saved successfully!'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = 'Error writing file: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // 3. READ FILE
  Future<void> readFile() async {
    setState(() {
      _loading = true;
    });

    try {
      final content = await _fileService.readFile();

      setState(() {
        _fileContent = content;
        _status = 'File read successfully.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error reading file: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Handling App'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // TITLE
            const Center(
              child: Icon(
                Icons.folder,
                size: 70,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 10),

            const Center(
              child: Text(
                'Text File Manager',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 2. STORAGE ACCESS
            const Text(
              '1. Access Storage',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : getFileLocation,
                icon: const Icon(Icons.folder_open),
                label: const Text('Get Storage Location'),
              ),
            ),

            if (_filePath.isNotEmpty) ...[
              const SizedBox(height: 10),
              SelectableText(
                'File path: $_filePath',
                style: const TextStyle(fontSize: 14),
              ),
            ],

            const SizedBox(height: 25),

            // 3. CREATE AND WRITE
            const Text(
              '2. Create and Write a File',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter your notes here...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : saveFile,
                icon: const Icon(Icons.save),
                label: const Text('Create and Save File'),
              ),
            ),

            const SizedBox(height: 25),

            // 3. READ FILE
            const Text(
              '3. Read File',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : readFile,
                icon: const Icon(Icons.menu_book),
                label: const Text('Read Saved File'),
              ),
            ),

            const SizedBox(height: 25),

            // 4. DISPLAY FILE CONTENT
            const Text(
              '4. File Content',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(
                  color: Colors.blue.shade200,
                ),
                borderRadius: BorderRadius.circular(12),
              ),

              child: Text(
                _fileContent.isEmpty
                    ? 'No content to display.'
                    : _fileContent,
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 25),

            // 4. ERROR HANDLING
            const Text(
              'Status',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),

              child: Text(
                _loading ? 'Please wait...' : _status,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}