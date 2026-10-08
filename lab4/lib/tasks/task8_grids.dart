import 'package:flutter/material.dart';

/// Task 8: Grid Displays (GridView.count)
///
/// Exercise 8.1: a 2-column image gallery built with GridView.count, with
/// spacing between the columns.
/// Exercise 8.2: each photo is wrapped in a GestureDetector that opens a
/// full-screen preview when tapped.
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  static const _photoCount = 12;

  // picsum.photos returns the same random photo for the same seed.
  static String _photoUrl(int index) =>
      'https://picsum.photos/seed/lab4-$index/800';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        padding: const EdgeInsets.all(8.0),
        children: [
          for (var i = 0; i < _photoCount; i++)
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _PhotoPreviewPage(
                    url: _photoUrl(i),
                    title: 'Photo ${i + 1}',
                  ),
                ),
              ),
              // Hero animates the photo from its grid cell to full screen.
              child: Hero(
                tag: _photoUrl(i),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: _NetworkPhoto(url: _photoUrl(i), fit: BoxFit.cover),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A full-screen page that shows one photo, with pinch-to-zoom.
class _PhotoPreviewPage extends StatelessWidget {
  final String url;
  final String title;

  const _PhotoPreviewPage({required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: InteractiveViewer(
        maxScale: 4.0,
        child: Center(
          child: Hero(
            tag: url,
            child: _NetworkPhoto(url: url, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

/// A photo loaded from the internet, with placeholders while it loads and
/// if it fails (for example, when the device is offline).
class _NetworkPhoto extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const _NetworkPhoto({required this.url, required this.fit});

  @override
  Widget build(BuildContext context) {
    final placeholderColor = Theme.of(context)
        .colorScheme
        .surfaceContainerHighest;

    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        // progress is null once the image has finished loading.
        if (progress == null) return child;
        return Container(
          color: placeholderColor,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: placeholderColor,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image, size: 40),
        );
      },
    );
  }
}
