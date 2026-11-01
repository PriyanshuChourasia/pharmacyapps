import 'package:flutter/material.dart';

/// Widget for uploading prescription images during checkout.
///
/// Currently a mock/placeholder - in a full implementation this would
/// integrate with a image picker/picker provider and upload to a storage service.
class PrescriptionImageUpload extends StatefulWidget {
  const PrescriptionImageUpload({super.key, required this.onImageSelected});

  final VoidCallback onImageSelected;

  @override
  State<PrescriptionImageUpload> createState() => _PrescriptionImageUploadState();
}

class _PrescriptionImageUploadState extends State<PrescriptionImageUpload> {
  String _selectedImagePath = '';
  bool _isUploading = false;

  Future<void> _pickImage() async {
    setState(() => _isUploading = true);
    // Mock: simulate image selection after a short delay
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _selectedImagePath = 'assets/images/products/tablet_strip.jpg';
      _isUploading = false;
    });
    widget.onImageSelected();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prescription (optional)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        _isUploading
            ? const Row(
                children: [
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(width: 8),
                  Text('Uploading prescription...'),
                ],
              )
            : Row(
                children: [
                  const Icon(Icons.upload_file, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton(
                      onPressed: _pickImage,
                      child: const Text('Upload prescription image'),
                    ),
                  ),
                  if (_selectedImagePath.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
        if (_selectedImagePath.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'Prescription uploaded - ready to place order',
            style: TextStyle(fontSize: 12, color: Colors.green),
          ),
        ],
      ],
    );
  }
}