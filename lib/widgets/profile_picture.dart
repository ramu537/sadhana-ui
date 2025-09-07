import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

class ProfilePicture extends StatelessWidget {
  final String name;
  final String? profilePictureBase64;
  final double radius;
  final VoidCallback? onTap;
  final bool showEditIcon;

  const ProfilePicture({
    super.key,
    required this.name,
    this.profilePictureBase64,
    this.radius = 30,
    this.onTap,
    this.showEditIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: _getInitialsColor(name),
            backgroundImage: _getProfileImage(),
            child: _getProfileImage() == null
                ? Text(
                    _getInitials(name),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: radius * 0.6,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          if (showEditIcon)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: radius * 0.4,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final words = name.split(' ').where((word) => word.isNotEmpty).toList();
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    } else if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Color _getInitialsColor(String name) {
    // Generate a consistent color based on the name
    final colors = [
      const Color(0xFFFF6B35), // Orange (primary)
      const Color(0xFF4CAF50), // Green
      const Color(0xFF2196F3), // Blue
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFFF9800), // Amber
      const Color(0xFF607D8B), // Blue Grey
      const Color(0xFFE91E63), // Pink
      const Color(0xFF795548), // Brown
    ];
    
    final index = name.hashCode % colors.length;
    return colors[index.abs()];
  }

  ImageProvider? _getProfileImage() {
    if (profilePictureBase64 == null || profilePictureBase64!.isEmpty) {
      return null;
    }
    
    try {
      final Uint8List bytes = base64Decode(profilePictureBase64!);
      return MemoryImage(bytes);
    } catch (e) {
      return null;
    }
  }
} 