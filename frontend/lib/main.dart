import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'models/analysis.dart';
import 'services/api_service.dart';
import 'screens/result_screen.dart'; // Added for navigation

void main() => runApp(const ResumeApp());

class ResumeApp extends StatelessWidget {
  const ResumeApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Resume Analyzer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const AnalyzerPage(),
    );
  }
}

class AnalyzerPage extends StatefulWidget {
  const AnalyzerPage({super.key});
  @override
  State<AnalyzerPage> createState() => _AnalyzerPageState();
}

class _AnalyzerPageState extends State<AnalyzerPage> {
  final _jdController = TextEditingController();
  final _api = ApiService();

  Uint8List? _fileBytes;
  String? _fileName;

  bool _loading = false;
  String? _error;

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt'],
    );
    
    if (res != null && res.files.single.bytes != null) {
      setState(() {
        _fileBytes = res.files.single.bytes;
        _fileName = res.files.single.name;
        _error = null;
      });
    }
  }

  Future<void> _analyze() async {
    if (_fileBytes == null) {
      setState(() => _error = 'Please select a resume file first.');
      return;
    }
    if (_jdController.text.trim().isEmpty) {
      setState(() => _error = 'Please paste a job description.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _api.analyzeResume(
        fileBytes: _fileBytes!,
        fileName: _fileName!,
        jobDescription: _jdController.text.trim(),
      );
      
      final analysis = Analysis.fromJson(data);
      
      // Safety check: Ensure the widget is still mounted before navigating
      if (!mounted) return;

      // Navigate to the new ResultScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(result: analysis),
        ),
      );

    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Analysis failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Resume Analyzer'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- FILE PICKER CARD ---
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _fileBytes == null ? Icons.upload_file : Icons.check_circle,
                      color: _fileBytes == null ? Colors.grey : Colors.green,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _fileName ?? 'No resume selected',
                        style: TextStyle(
                          color: _fileBytes == null ? Colors.grey[700] : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _pickFile,
                      child: const Text('Select'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- JOB DESCRIPTION INPUT ---
            TextField(
              controller: _jdController,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Job Description',
                hintText: 'Paste the job requirements here...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // --- ANALYZE BUTTON ---
            FilledButton.icon(
              onPressed: _loading ? null : _analyze,
              icon: _loading 
                  ? const SizedBox(
                      width: 20, height: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2)
                    )
                  : const Icon(Icons.analytics),
              label: Text(
                _loading ? 'Analyzing...' : 'Analyze Resume', 
                style: const TextStyle(fontSize: 16)
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            // --- ERROR MESSAGE ---
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _error!, 
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
                ),
              ),
          ],
        ),
      ),
    );
  }
}