import 'package:equatable/equatable.dart';

/// Trang thai livestream.
enum LivestreamStatus {
  scheduled,
  live,
  ended;

  static LivestreamStatus fromString(String? value) {
    switch (value) {
      case 'scheduled':
        return LivestreamStatus.scheduled;
      case 'live':
        return LivestreamStatus.live;
      case 'ended':
        return LivestreamStatus.ended;
      default:
        return LivestreamStatus.scheduled;
    }
  }

  String get displayName {
    switch (this) {
      case LivestreamStatus.scheduled:
        return 'Sap dien ra';
      case LivestreamStatus.live:
        return 'Dang phat';
      case LivestreamStatus.ended:
        return 'Da ket thuc';
    }
  }
}

/// Model cho livestream.
class LivestreamModel extends Equatable {
  const LivestreamModel({
    required this.id,
    required this.title,
    this.description,
    required this.hostId,
    required this.hostName,
    this.hostAvatarUrl,
    this.classId,
    this.className,
    this.courseId,
    this.courseName,
    required this.status,
    this.scheduledAt,
    this.startedAt,
    this.endedAt,
    required this.maxViewers,
    this.activeParticipants = 0,
    required this.isRecorded,
    this.thumbnailUrl,
  });

  final String id;
  final String title;
  final String? description;
  final String hostId;
  final String hostName;
  final String? hostAvatarUrl;
  final String? classId;
  final String? className;
  final String? courseId;
  final String? courseName;
  final LivestreamStatus status;
  final DateTime? scheduledAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int maxViewers;
  final int activeParticipants;
  final bool isRecorded;
  final String? thumbnailUrl;

  /// Dang phat truc tiep.
  bool get isLive => status == LivestreamStatus.live;

  /// Thoi gian hien thi.
  String get timeDisplay {
    final dateTime = scheduledAt ?? startedAt ?? DateTime.now();
    final now = DateTime.now();
    final diff = dateTime.difference(now);

    if (status == LivestreamStatus.live) {
      return 'Dang phat';
    }

    if (diff.isNegative) {
      return 'Da bat dau';
    }

    if (diff.inDays > 0) {
      return '${diff.inDays} ngay nua';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} gio nua';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} phut nua';
    }
    return 'Sap bat dau';
  }

  /// Ngay gio chi tiet.
  String get scheduledTimeDisplay {
    final dateTime = scheduledAt ?? startedAt ?? DateTime.now();
    final weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final weekday = weekdays[dateTime.weekday - 1];
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$weekday, ${dateTime.day}/${dateTime.month} - $hour:$minute';
  }

  factory LivestreamModel.fromJson(Map<String, dynamic> json) {
    return LivestreamModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      hostId: json['host_id'] as String? ?? '',
      hostName: json['host_name'] as String? ?? '',
      hostAvatarUrl: json['host_avatar_url'] as String?,
      classId: json['class_id'] as String?,
      className: json['class_name'] as String?,
      courseId: json['course_id'] as String?,
      courseName: json['course_name'] as String?,
      status: LivestreamStatus.fromString(json['status'] as String?),
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.tryParse(json['scheduled_at'] as String)
          : null,
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'] as String)
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.tryParse(json['ended_at'] as String)
          : null,
      maxViewers: json['max_viewers'] as int? ?? 100,
      activeParticipants: json['active_participants'] as int? ?? 0,
      isRecorded: json['is_recorded'] as bool? ?? false,
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        hostId,
        hostName,
        hostAvatarUrl,
        classId,
        className,
        courseId,
        courseName,
        status,
        scheduledAt,
        startedAt,
        endedAt,
        maxViewers,
        activeParticipants,
        isRecorded,
        thumbnailUrl,
      ];
}
