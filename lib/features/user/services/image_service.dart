// image_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

class ImageService {
  static const String _avatarDirectoryName = 'avatars';
  
  // Get application documents directory path
  static Future<String> get _localPath async {
    // For now, we'll use a simple path
    // In a real app, you'd use path_provider package
    return '/data/data/com.example.expensemate/files';
  }

  static Future<Directory> get _avatarDirectory async {
    final localPath = await _localPath;
    final directory = Directory(path.join(localPath, _avatarDirectoryName));
    
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    return directory;
  }

  // Save avatar image
  static Future<String?> saveAvatar(String userId, Uint8List imageData) async {
    try {
      final directory = await _avatarDirectory;
      final fileName = 'avatar_$userId.jpg';
      final file = File(path.join(directory.path, fileName));
      
      await file.writeAsBytes(imageData);
      return file.path;
    } catch (e) {
      debugPrint('Error saving avatar: $e');
      return null;
    }
  }

  // Load avatar image
  static Future<Uint8List?> loadAvatar(String avatarPath) async {
    try {
      final file = File(avatarPath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      debugPrint('Error loading avatar: $e');
      return null;
    }
  }

  // Delete avatar image
  static Future<bool> deleteAvatar(String avatarPath) async {
    try {
      final file = File(avatarPath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting avatar: $e');
      return false;
    }
  }

  // Get default avatar colors based on initials
  static Color getAvatarColor(String initials) {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.blueGrey,
    ];
    
    int hash = 0;
    for (int i = 0; i < initials.length; i++) {
      hash = initials.codeUnitAt(i) + ((hash << 5) - hash);
    }
    
    return colors[hash.abs() % colors.length];
  }

  // Validate image file
  static bool isValidImageFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif'].contains(extension);
  }

  // Get file size in bytes
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return 0;
    }
  }

  // Compress image (placeholder - in real app, use image package)
  static Future<Uint8List> compressImage(Uint8List imageData, {int quality = 85}) async {
    // This is a placeholder implementation
    // In a real app, you would use the image package to compress
    return imageData;
  }
}