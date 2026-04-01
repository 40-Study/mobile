import 'package:equatable/equatable.dart';

class ClassAssignmentModel extends Equatable {
  const ClassAssignmentModel({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.maxScore = 100,
    this.submittedCount = 0,
    this.totalStudents = 0,
    this.gradedCount = 0,
    this.status = ClassAssignmentStatus.active,
    this.createdAt,
  });

  final String id;
  final String title;
  final String? description;
  final String dueDate;
  final double maxScore;
  final int submittedCount;
  final int totalStudents;
  final int gradedCount;
  final ClassAssignmentStatus status;
  final String? createdAt;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        dueDate,
        maxScore,
        submittedCount,
        totalStudents,
        gradedCount,
        status,
        createdAt,
      ];

  double get submissionRate =>
      totalStudents > 0 ? submittedCount / totalStudents * 100 : 0;

  int get pendingGradeCount => submittedCount - gradedCount;

  bool get isOverdue {
    try {
      final due = DateTime.parse(dueDate);
      return DateTime.now().isAfter(due);
    } catch (_) {
      return false;
    }
  }
}

enum ClassAssignmentStatus {
  draft,
  active,
  closed,
}

class ClassDocumentModel extends Equatable {
  const ClassDocumentModel({
    required this.id,
    required this.title,
    required this.type,
    this.description,
    this.fileUrl,
    this.fileSize,
    this.downloadCount = 0,
    this.uploadedAt,
  });

  final String id;
  final String title;
  final DocumentType type;
  final String? description;
  final String? fileUrl;
  final String? fileSize;
  final int downloadCount;
  final String? uploadedAt;

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        description,
        fileUrl,
        fileSize,
        downloadCount,
        uploadedAt,
      ];
}

enum DocumentType {
  pdf,
  doc,
  ppt,
  xls,
  image,
  video,
  link,
  other,
}

extension DocumentTypeX on DocumentType {
  String get icon {
    return switch (this) {
      DocumentType.pdf => 'picture_as_pdf',
      DocumentType.doc => 'description',
      DocumentType.ppt => 'slideshow',
      DocumentType.xls => 'table_chart',
      DocumentType.image => 'image',
      DocumentType.video => 'video_library',
      DocumentType.link => 'link',
      DocumentType.other => 'insert_drive_file',
    };
  }

  String get label {
    return switch (this) {
      DocumentType.pdf => 'PDF',
      DocumentType.doc => 'Word',
      DocumentType.ppt => 'PowerPoint',
      DocumentType.xls => 'Excel',
      DocumentType.image => 'Hình ảnh',
      DocumentType.video => 'Video',
      DocumentType.link => 'Liên kết',
      DocumentType.other => 'Khác',
    };
  }
}
