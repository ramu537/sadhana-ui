import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickAndConvertImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        final Uint8List bytes = await image.readAsBytes();
        final String base64String = base64Encode(bytes);
        return base64String;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
    }
    return null;
  }

  static Future<String?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        final Uint8List bytes = await image.readAsBytes();
        final String base64String = base64Encode(bytes);
        return base64String;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error taking photo: $e');
      }
    }
    return null;
  }

  static void showImageSourceDialog(
    BuildContext context,
    Function(String) onImageSelected,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Profile Picture',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  context,
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () async {
                    Navigator.pop(context);
                    final base64Image = await pickAndConvertImage();
                    if (base64Image != null) {
                      onImageSelected(base64Image);
                    }
                  },
                ),
                _buildSourceOption(
                  context,
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () async {
                    Navigator.pop(context);
                    final base64Image = await pickImageFromCamera();
                    if (base64Image != null) {
                      onImageSelected(base64Image);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _buildSourceOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: const Color(0xFFFF6B35),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
} 