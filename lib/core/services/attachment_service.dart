import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/expense_attachment.dart';
import '../database/databaseHelper.dart';

class AttachmentService extends ChangeNotifier {
  final DatabaseHelper _databaseHelper;
  final ImagePicker _imagePicker = ImagePicker();

  AttachmentService(this._databaseHelper);

  // Get app documents directory for storing attachments
  Future<Directory> get _attachmentsDirectory async {
    final appDir = await getApplicationDocumentsDirectory();
    final attachmentsDir = Directory(path.join(appDir.path, 'attachments'));
    
    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
    }
    
    return attachmentsDir;
  }

  // Pick image from camera
  Future<ExpenseAttachment?> pickImageFromCamera(String expenseId) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        return await _saveAttachment(expenseId, image.path, image.name);
      }
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
    }
    return null;
  }

  // Pick image from gallery
  Future<ExpenseAttachment?> pickImageFromGallery(String expenseId) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        return await _saveAttachment(expenseId, image.path, image.name);
      }
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
    }
    return null;
  }

  // Pick file (PDF, etc.)
  Future<ExpenseAttachment?> pickFile(String expenseId) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'gif'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        return await _saveAttachment(expenseId, file.path!, file.name);
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
    return null;
  }

  // Save attachment to app directory and database
  Future<ExpenseAttachment> _saveAttachment(
    String expenseId,
    String sourcePath,
    String fileName,
  ) async {
    final attachmentsDir = await _attachmentsDirectory;
    final sourceFile = File(sourcePath);
    
    // Generate unique filename
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(fileName);
    final newFileName = '${timestamp}_$fileName';
    final targetPath = path.join(attachmentsDir.path, newFileName);
    
    // Copy file to attachments directory
    final targetFile = await sourceFile.copy(targetPath);
    final stats = await targetFile.stat();
    
    // Create attachment object
    final attachment = ExpenseAttachment(
      expenseId: expenseId,
      fileName: fileName,
      filePath: targetPath,
      fileType: extension.replaceFirst('.', '').toUpperCase(),
      fileSize: stats.size,
      mimeType: _getMimeType(extension),
      isReceipt: true,
      createdAt: DateTime.now(),
    );

    // Save to database
    await _databaseHelper.insertExpenseAttachment(attachment);
    
    notifyListeners();
    return attachment;
  }

  // Get MIME type from file extension
  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }

  // Get attachments for expense
  Future<List<ExpenseAttachment>> getExpenseAttachments(String expenseId) async {
    return await _databaseHelper.getExpenseAttachments(expenseId);
  }

  // Delete attachment
  Future<bool> deleteAttachment(String attachmentId) async {
    try {
      // Get attachment details
      final attachments = await _databaseHelper.getExpenseAttachments('');
      final attachment = attachments.firstWhere(
        (a) => a.id == attachmentId,
        orElse: () => throw Exception('Attachment not found'),
      );

      // Delete file from storage
      final file = File(attachment.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Delete from database
      await _databaseHelper.deleteExpenseAttachment(attachmentId);
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting attachment: $e');
      return false;
    }
  }

  // Get file as bytes (for display)
  Future<Uint8List?> getAttachmentBytes(ExpenseAttachment attachment) async {
    try {
      final file = File(attachment.filePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    } catch (e) {
      debugPrint('Error reading attachment file: $e');
    }
    return null;
  }

  // Check if file exists
  Future<bool> attachmentExists(ExpenseAttachment attachment) async {
    final file = File(attachment.filePath);
    return await file.exists();
  }

  // Get total attachments size for expense
  Future<int> getTotalAttachmentsSize(String expenseId) async {
    final attachments = await getExpenseAttachments(expenseId);
    return attachments.fold<int>(0, (int total, attachment) => 
      total + (attachment.fileSize ?? 0));
  }

  // Clean up orphaned attachment files
  Future<void> cleanupOrphanedFiles() async {
    try {
      final attachmentsDir = await _attachmentsDirectory;
      final allAttachments = await _databaseHelper.getAllExpenseAttachments();
      final validPaths = allAttachments.map((a) => a.filePath).toSet();
      
      final dirList = attachmentsDir.listSync();
      for (final entity in dirList) {
        if (entity is File && !validPaths.contains(entity.path)) {
          await entity.delete();
          debugPrint('Deleted orphaned file: ${entity.path}');
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up orphaned files: $e');
    }
  }

  // Get attachment icon based on file type
  IconData getAttachmentIcon(ExpenseAttachment attachment) {
    if (attachment.isImage) {
      return Icons.image;
    } else if (attachment.isPdf) {
      return Icons.picture_as_pdf;
    } else {
      return Icons.attach_file;
    }
  }

  // Show attachment options dialog
  Future<ExpenseAttachment?> showAttachmentOptions(
    BuildContext context,
    String expenseId,
  ) async {
    return showModalBottomSheet<ExpenseAttachment>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Attachment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final attachment = await pickImageFromCamera(expenseId);
                  if (context.mounted && attachment != null) {
                    Navigator.pop(context, attachment);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final attachment = await pickImageFromGallery(expenseId);
                  if (context.mounted && attachment != null) {
                    Navigator.pop(context, attachment);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: const Text('Choose File'),
                onTap: () async {
                  Navigator.pop(context);
                  final attachment = await pickFile(expenseId);
                  if (context.mounted && attachment != null) {
                    Navigator.pop(context, attachment);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }
}