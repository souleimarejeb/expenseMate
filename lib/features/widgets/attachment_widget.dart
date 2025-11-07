import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/models/expense_attachment.dart';
import '../../core/services/attachment_service.dart';

class AttachmentWidget extends StatelessWidget {
  final ExpenseAttachment attachment;
  final AttachmentService attachmentService;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const AttachmentWidget({
    Key? key,
    required this.attachment,
    required this.attachmentService,
    this.onDelete,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
          ),
          child: attachment.isImage
              ? _buildImagePreview()
              : Icon(
                  attachmentService.getAttachmentIcon(attachment),
                  color: Theme.of(context).primaryColor,
                ),
        ),
        title: Text(
          attachment.fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${attachment.fileType} • ${attachment.formattedFileSize}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (attachment.ocrText != null && attachment.ocrText!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'OCR: ${attachment.ocrText!.substring(0, 
                    attachment.ocrText!.length > 50 ? 50 : attachment.ocrText!.length)}...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (String action) {
            switch (action) {
              case 'view':
                if (onTap != null) onTap!();
                break;
              case 'delete':
                if (onDelete != null) onDelete!();
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 18),
                  SizedBox(width: 8),
                  Text('View'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildImagePreview() {
    return FutureBuilder<bool>(
      future: attachmentService.attachmentExists(attachment),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == true) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(attachment.filePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.broken_image,
                  color: Theme.of(context).primaryColor,
                );
              },
            ),
          );
        } else {
          return Icon(
            Icons.image,
            color: Theme.of(context).primaryColor,
          );
        }
      },
    );
  }
}

class AttachmentListWidget extends StatefulWidget {
  final String expenseId;
  final AttachmentService attachmentService;
  final bool allowEditing;

  const AttachmentListWidget({
    Key? key,
    required this.expenseId,
    required this.attachmentService,
    this.allowEditing = true,
  }) : super(key: key);

  @override
  State<AttachmentListWidget> createState() => _AttachmentListWidgetState();
}

class _AttachmentListWidgetState extends State<AttachmentListWidget> {
  List<ExpenseAttachment> _attachments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAttachments();
    
    // Listen to attachment service changes
    widget.attachmentService.addListener(_loadAttachments);
  }

  @override
  void dispose() {
    widget.attachmentService.removeListener(_loadAttachments);
    super.dispose();
  }

  Future<void> _loadAttachments() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final attachments = await widget.attachmentService.getExpenseAttachments(widget.expenseId);
      if (mounted) {
        setState(() {
          _attachments = attachments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading attachments: $e')),
        );
      }
    }
  }

  Future<void> _addAttachment() async {
    final attachment = await widget.attachmentService.showAttachmentOptions(
      context,
      widget.expenseId,
    );

    if (attachment != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attachment added successfully')),
      );
      _loadAttachments(); // Refresh the list
    }
  }

  Future<void> _deleteAttachment(ExpenseAttachment attachment) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Attachment'),
          content: Text('Are you sure you want to delete "${attachment.fileName}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      final success = await widget.attachmentService.deleteAttachment(attachment.id!);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Attachment deleted successfully')),
          );
          _loadAttachments(); // Refresh the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete attachment')),
          );
        }
      }
    }
  }

  void _viewAttachment(ExpenseAttachment attachment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttachmentViewScreen(
          attachment: attachment,
          attachmentService: widget.attachmentService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_attachments.isEmpty) {
      return Column(
        children: [
          if (widget.allowEditing)
            ElevatedButton.icon(
              onPressed: _addAttachment,
              icon: const Icon(Icons.add),
              label: const Text('Add Attachment'),
            ),
          const SizedBox(height: 16),
          const Text(
            'No attachments yet',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Attachments (${_attachments.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (widget.allowEditing)
              IconButton(
                onPressed: _addAttachment,
                icon: const Icon(Icons.add),
                tooltip: 'Add Attachment',
              ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _attachments.length,
          itemBuilder: (context, index) {
            final attachment = _attachments[index];
            return AttachmentWidget(
              attachment: attachment,
              attachmentService: widget.attachmentService,
              onTap: () => _viewAttachment(attachment),
              onDelete: widget.allowEditing 
                ? () => _deleteAttachment(attachment)
                : null,
            );
          },
        ),
      ],
    );
  }
}

class AttachmentViewScreen extends StatelessWidget {
  final ExpenseAttachment attachment;
  final AttachmentService attachmentService;

  const AttachmentViewScreen({
    Key? key,
    required this.attachment,
    required this.attachmentService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(attachment.fileName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildAttachmentViewer(context),
    );
  }

  Widget _buildAttachmentViewer(BuildContext context) {
    if (attachment.isImage) {
      return InteractiveViewer(
        child: Center(
          child: Image.file(
            File(attachment.filePath),
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget(context);
            },
          ),
        ),
      );
    } else if (attachment.isPdf) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf,
              size: 64,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'PDF Preview',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(attachment.fileName),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Open with external app
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PDF viewer not implemented yet')),
                );
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open with external app'),
            ),
          ],
        ),
      );
    } else {
      return _buildErrorWidget(context);
    }
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Cannot preview this file type',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(attachment.fileName),
        ],
      ),
    );
  }
}