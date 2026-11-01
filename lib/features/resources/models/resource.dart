enum ResourceStatus { published, underReview, restricted, removed }

enum ResourceCategory {
  notes,
  assignments,
  pastPapers,
  books,
  presentations,
  tutorials,
  other;

  String get label => switch (this) {
    ResourceCategory.notes => 'Notes',
    ResourceCategory.assignments => 'Assignments',
    ResourceCategory.pastPapers => 'Past Papers',
    ResourceCategory.books => 'Books',
    ResourceCategory.presentations => 'Presentations',
    ResourceCategory.tutorials => 'Tutorials',
    ResourceCategory.other => 'Other',
  };
}

class AcademicResource {
  const AcademicResource({
    required this.id,
    required this.uploaderId,
    required this.title,
    required this.category,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSizeKb,
    required this.status,
    required this.uploadedAt,
    this.description,
    this.subject = '',
    this.department = '',
    this.semester,
    this.academicYear = '',
  });

  final String id;
  final String uploaderId;
  final String title;
  final String? description;
  final ResourceCategory category;
  final String fileUrl;
  final String fileName;
  final String fileType;
  final int fileSizeKb;
  final String subject;
  final String department;
  final int? semester;
  final String academicYear;
  final ResourceStatus status;
  final DateTime uploadedAt;

  double get fileSizeMb => fileSizeKb / 1024;
  String get fileSizeLabel => '${fileSizeMb.toStringAsFixed(1)} MB';

  AcademicResource copyWith({ResourceStatus? status}) => AcademicResource(
    id: id,
    uploaderId: uploaderId,
    title: title,
    description: description,
    category: category,
    fileUrl: fileUrl,
    fileName: fileName,
    fileType: fileType,
    fileSizeKb: fileSizeKb,
    subject: subject,
    department: department,
    semester: semester,
    academicYear: academicYear,
    status: status ?? this.status,
    uploadedAt: uploadedAt,
  );
}

class MockResourceFile {
  const MockResourceFile({
    required this.name,
    required this.fileType,
    required this.sizeKb,
  });

  final String name;
  final String fileType;
  final int sizeKb;

  String get extension => name.split('.').last.toLowerCase();
}
