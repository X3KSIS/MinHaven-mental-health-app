import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSourceDialog extends StatelessWidget {
  final Function(ImageSource) onCameraSelected;
  final Function(ImageSource) onGallerySelected;
  final VoidCallback onRemovePhoto;

  const ImageSourceDialog({
    super.key,
    required this.onCameraSelected,
    required this.onGallerySelected,
    required this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera, color: Theme.of(context).colorScheme.primary),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                onCameraSelected(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Theme.of(context).colorScheme.primary),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                onGallerySelected(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove photo', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                onRemovePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }
}