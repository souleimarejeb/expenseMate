class ExpenseAttachment {
  final String? id;
  final String expenseId;
  final String fileName;
  final String filePath;
  final String fileType;
  final int? fileSize;
  final String? mimeType;
  final bool isReceipt;
  final String? ocrText;
  final DateTime createdAt;

  const ExpenseAttachment({
    this.id,
    required this.expenseId,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    this.fileSize,
    this.mimeType,
    this.isReceipt = true,
    this.ocrText,
    required this.createdAt,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expenseId': expenseId,
      'fileName': fileName,
      'filePath': filePath,
      'fileType': fileType,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'isReceipt': isReceipt ? 1 : 0,
      'ocrText': ocrText,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Map
  factory ExpenseAttachment.fromMap(Map<String, dynamic> map) {
    return ExpenseAttachment(
      id: map['id'],
      expenseId: map['expenseId'] ?? '',
      fileName: map['fileName'] ?? '',
      filePath: map['filePath'] ?? '',
      fileType: map['fileType'] ?? '',
      fileSize: map['fileSize'],
      mimeType: map['mimeType'],
      isReceipt: (map['isReceipt'] ?? 1) == 1,
      ocrText: map['ocrText'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Copy with method
  ExpenseAttachment copyWith({
    String? id,
    String? expenseId,
    String? fileName,
    String? filePath,
    String? fileType,
    int? fileSize,
    String? mimeType,
    bool? isReceipt,
    String? ocrText,
    DateTime? createdAt,
  }) {
    return ExpenseAttachment(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      isReceipt: isReceipt ?? this.isReceipt,
      ocrText: ocrText ?? this.ocrText,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Get file extension
  String get fileExtension {
    return fileName.split('.').last.toLowerCase();
  }

  // Check if it's an image
  bool get isImage {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    return imageExtensions.contains(fileExtension);
  }

  // Check if it's a PDF
  bool get isPdf => fileExtension == 'pdf';

  // Get formatted file size
  String get formattedFileSize {
    if (fileSize == null) return 'Unknown size';
    
    if (fileSize! < 1024) {
      return '$fileSize B';
    } else if (fileSize! < 1024 * 1024) {
      return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  @override
  String toString() {
    return 'ExpenseAttachment{id: $id, fileName: $fileName, fileType: $fileType}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseAttachment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}