import 'package:flutter/material.dart';

/// Task 4: Indicators & Feedback (CircularProgressIndicator & SnackBar)
///
/// Exercise 4.1: tapping the button shows a centered
/// CircularProgressIndicator for 3 seconds.
/// Exercise 4.2: when the work completes, a SnackBar with an "Undo" action
/// appears at the bottom of the screen.
class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool _isLoading = false;
  int _uploadedFiles = 0;

  Future<void> _upload() async {
    setState(() => _isLoading = true);

    // Stands in for a real asynchronous operation such as a network request.
    await Future.delayed(const Duration(seconds: 3));

    // The user may have left this screen while we were waiting.
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _uploadedFiles++;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('File uploaded'),
          // SnackBars with an action stay open by default; let this one time out.
          persist: false,
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // The SnackBar outlives this page if the user navigates back.
              if (mounted) setState(() => _uploadedFiles--);
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_upload_outlined, size: 64),
                  const SizedBox(height: 12.0),
                  Text(
                    'Uploaded files: $_uploadedFiles',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton.icon(
                    onPressed: _upload,
                    icon: const Icon(Icons.upload),
                    label: const Text('Upload file'),
                  ),
                ],
              ),
      ),
    );
  }
}
