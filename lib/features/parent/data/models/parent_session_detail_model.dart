import 'package:study/features/parent/data/models/family_scope_child.dart';
import 'package:study/features/parent/data/models/parent_schedule_session.dart';

/// Đại diện cho một file tài liệu đính kèm của buổi học.
class SessionMaterial {
  const SessionMaterial({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.uploadTime,
    this.fileType = 'pdf',
    this.downloadUrl,
  });

  /// ID duy nhất của tài liệu
  final String id;

  /// Tên file tài liệu kèm phần mở rộng
  final String fileName;

  /// Dung lượng file (VD: "2.4 MB")
  final String fileSize;

  /// Thời điểm tải lên hoặc ghi chú thời gian
  final String uploadTime;

  /// Loại file định dạng ("pdf", "docx", "pptx", "zip")
  final String fileType;

  /// Đường dẫn tải file tài liệu an toàn từ server
  final String? downloadUrl;
}

/// Loại nhiệm vụ chuẩn bị: Dụng cụ mang theo hoặc Bài tập cần làm.
enum ChecklistItemType {
  tool, // Dụng cụ mang theo
  task, // Nhiệm vụ học tập
}

/// Một mục trong danh sách cần chuẩn bị trước buổi học.
class SessionChecklistItem {
  const SessionChecklistItem({
    required this.id,
    required this.title,
    required this.type,
    this.isCompleted = false,
    this.actionHint,
  });

  /// ID định danh của mục checklist
  final String id;

  /// Nội dung việc cần chuẩn bị
  final String title;

  /// Phân loại dụng cụ hay nhiệm vụ học tập
  final ChecklistItemType type;

  /// Học sinh đã hoàn thành trên hệ thống hay chưa
  final bool isCompleted;

  /// Gợi ý nhắc nhở cho phụ huynh
  final String? actionHint;
}

/// Thông tin điểm danh tức thời của buổi học.
class SessionAttendanceInfo {
  const SessionAttendanceInfo({
    required this.status,
    required this.statusLabel,
    this.checkInTime,
    this.lateMinutes = 0,
    this.note,
  });

  /// Trạng thái mã hóa: not_opened, present, late, absent...
  final String status;

  /// Label hiển thị cho phụ huynh
  final String statusLabel;

  /// Thời gian học sinh điểm danh vào lớp
  final DateTime? checkInTime;

  /// Số phút đi muộn (nếu có)
  final int lateMinutes;

  /// Ghi chú của giáo viên điểm danh
  final String? note;
}

/// Thông tin chi tiết giáo viên phụ trách buổi học.
class TeacherDetailInfo {
  const TeacherDetailInfo({
    this.id,
    required this.fullName,
    this.title,
    this.school,
    this.avatarUrl,
    this.canChat = true,
  });

  final String? id;

  /// Họ tên giáo viên (VD: "Cô Lan", "Thầy Dũng")
  final String fullName;

  /// Học vị hoặc chức danh (VD: "ThS. Toán")
  final String? title;

  /// Nơi công tác (VD: "THPT Chuyên Hà Nội - Amsterdam")
  final String? school;

  /// Ảnh đại diện giáo viên
  final String? avatarUrl;

  /// Cho phép phụ huynh nhắn tin trực tiếp
  final bool canChat;

  /// Chuỗi hiển thị gộp tên và học vị (VD: "Cô Lan (ThS. Toán)")
  String get displayTitleWithName {
    if (title != null && title!.isNotEmpty) {
      return '$fullName ($title)';
    }
    return fullName;
  }
}

/// Dữ liệu phân tích và kết quả khi ca học đã kết thúc.
class SessionCompletedAnalysis {
  const SessionCompletedAnalysis({
    required this.attendanceStatus,
    this.checkInTime,
    this.attendedMinutes = 0,
    this.totalMinutes = 0,
    this.quizTitle,
    this.scoreLabel,
    this.quizScore,
    this.maxQuizScore = 10.0,
    this.quizCorrectAnswers,
    this.quizTotalQuestions,
    this.timeSpentMins = 0,
    this.timeLimitMins = 0,
    this.teacherComment,
    this.teacherSubject,
    this.teacherCommentTime,
    this.homeworkTitle,
    this.homeworkDueDate,
    this.homeworkStatus,
    this.hasRecording = false,
    this.recordingDuration,
  });

  /// Trạng thái có mặt ("Có mặt", "Đi muộn", "Vắng mặt")
  final String attendanceStatus;

  /// Giờ vào lớp thực tế (VD: "09:02")
  final String? checkInTime;

  /// Số phút tham gia học thực tế (VD: 58)
  final int attendedMinutes;

  /// Tổng thời lượng ca học tính bằng phút (VD: 60)
  final int totalMinutes;

  /// Tiêu đề bài kiểm tra trên lớp (VD: "Quiz & Thực hành tính toán nhanh")
  final String? quizTitle;

  /// Nhãn đánh giá học lực (VD: "Cần rèn luyện thêm", "Xuất sắc")
  final String? scoreLabel;

  /// Điểm số bài kiểm tra / quiz trong buổi học (VD: 6.0)
  final double? quizScore;

  /// Thang điểm tối đa (mặc định 10.0)
  final double maxQuizScore;

  /// Số câu làm đúng (VD: 3)
  final int? quizCorrectAnswers;

  /// Tổng số câu hỏi (VD: 5)
  final int? quizTotalQuestions;

  /// Thời gian làm bài thực tế tính bằng phút (VD: 18)
  final int timeSpentMins;

  /// Thời gian tối đa làm bài tính bằng phút (VD: 25)
  final int timeLimitMins;

  /// Nhận xét chi tiết từ giáo viên đứng lớp
  final String? teacherComment;

  /// Bộ môn giảng dạy của giáo viên (VD: "Bộ môn Toán")
  final String? teacherSubject;

  /// Thời gian giáo viên gửi nhận xét (VD: "Đã nhận xét lúc 11:30 hôm nay")
  final String? teacherCommentTime;

  /// Tên bài tập về nhà được giao sau buổi học
  final String? homeworkTitle;

  /// Hạn nộp bài tập về nhà (VD: "23:59 Ngày mai")
  final String? homeworkDueDate;

  /// Trạng thái nộp bài tập ("Chưa nộp", "Đã nộp", "Đang chấm")
  final String? homeworkStatus;

  /// Có video xem lại buổi học hay không
  final bool hasRecording;

  /// Thời lượng video xem lại (VD: "48 phút")
  final String? recordingDuration;

  /// Tỷ lệ thời gian tham gia lớp (phần trăm 0 - 100)
  int get attendancePercentage {
    if (totalMinutes <= 0) return 100;
    final pct = ((attendedMinutes / totalMinutes) * 100).round();
    return pct > 100 ? 100 : pct;
  }

  /// Tỷ lệ phần trăm làm đúng câu hỏi quiz (0 - 100)
  int get quizPercentage {
    if (quizTotalQuestions == null || quizTotalQuestions! <= 0) return 0;
    if (quizCorrectAnswers == null) return 0;
    return ((quizCorrectAnswers! / quizTotalQuestions!) * 100).round();
  }

  /// Có bài tập về nhà được giao hay không
  bool get hasHomework =>
      homeworkTitle != null && homeworkTitle!.trim().isNotEmpty;

  /// Có nhận xét từ giáo viên hay không
  bool get hasTeacherComment =>
      teacherComment != null && teacherComment!.trim().isNotEmpty;

  /// Có điểm quiz / kiểm tra trên lớp hay không
  bool get hasQuizScore => quizScore != null;
}

/// Model dữ liệu chi tiết cho màn hình Chi tiết ca học của Phụ huynh.
class ParentSessionDetail {
  const ParentSessionDetail({
    required this.session,
    this.studentCode,
    this.studentMajor,
    this.schoolYear,
    this.teacherInfo,
    this.attendanceInfo,
    this.materials = const [],
    this.checklist = const [],
    this.parentGuidance,
    this.sessionCode,
    this.rescheduleReason,
    this.lessonId,
    this.completedAnalysis,
  });

  /// Factory chuyển đổi từ session và child
  factory ParentSessionDetail.fromSession(
    ParentScheduleSession session, {
    FamilyScopeChild? child,
  }) {
    final isDone = session.status == ParentSessionStatus.completed;

    // 1. Kiểm tra nếu là 2 con mẫu demo (Minh & Lan)
    final isMinh = session.childName.toLowerCase().contains('minh') ||
        session.childId == 'a055e1b3-bbfe-46b1-8e01-df7aac8c2732';
    final isLan = session.childName.toLowerCase().contains('lan') ||
        session.childId == 'a0f88b81-94ca-4328-b46a-b61a1a53a9ad';

    if (isMinh) {
      return ParentSessionDetail(
        session: session,
        studentCode: 'HS-10294',
        studentMajor: 'Khối chuyên Toán Tin',
        schoolYear: 'Lớp 10A1 — Niên khóa 2024–2025',
        sessionCode: '#MAT10-B24',
        teacherInfo: TeacherDetailInfo(
          id: 'tch_lan',
          fullName: session.instructorName.isNotEmpty
              ? session.instructorName
              : 'Cô Lan',
          title: 'ThS. Toán',
          school: 'THPT Chuyên Hà Nội - Amsterdam',
          canChat: true,
        ),
        attendanceInfo: SessionAttendanceInfo(
          status: isDone ? 'present' : 'not_opened',
          statusLabel: isDone
              ? 'Có mặt (Vào lớp lúc 09:02)'
              : 'Chưa mở điểm danh\n(Mở trước giờ học 10p)',
        ),
        materials: const [
          SessionMaterial(
            id: 'mat_parabol_01',
            fileName: 'Bai_tap_chuyen_de_Parabol_T10.pdf',
            fileSize: '2.4 MB',
            uploadTime: 'Giáo viên gửi hôm qua',
            fileType: 'pdf',
          ),
        ],
        checklist: const [
          SessionChecklistItem(
            id: 'chk_casio',
            title: 'Mang theo máy tính Casio fx-580VNX hoặc tương đương.',
            type: ChecklistItemType.tool,
            isCompleted: false,
            actionHint: 'Nhắc con kiểm tra máy tính trước khi vào học',
          ),
          SessionChecklistItem(
            id: 'chk_quiz',
            title: 'Đã hoàn thành 5 câu hỏi trắc nghiệm khởi động.',
            type: ChecklistItemType.task,
            isCompleted: true,
            actionHint: 'Con đã hoàn thành câu hỏi chuẩn bị',
          ),
        ],
        parentGuidance:
            'Phụ huynh nên nhắc Minh kiểm tra tai nghe, đường truyền '
            'Internet và vào bàn học trước 5–10 phút để bài học đạt kết '
            'quả tốt nhất.',
        lessonId: 'lesson_parabol_10',
        completedAnalysis: isDone
            ? const SessionCompletedAnalysis(
                attendanceStatus: 'Có mặt đúng giờ',
                checkInTime: '08:58',
                attendedMinutes: 58,
                totalMinutes: 60,
                quizTitle: 'Quiz & Thực hành tính toán nhanh',
                scoreLabel: 'Cần rèn luyện thêm',
                quizScore: 6.0,
                maxQuizScore: 10.0,
                quizCorrectAnswers: 3,
                quizTotalQuestions: 5,
                timeSpentMins: 18,
                timeLimitMins: 25,
                teacherSubject: 'Bộ môn Toán',
                teacherCommentTime: 'Đã nhận xét lúc 11:30 hôm nay',
                teacherComment:
                    'Minh nắm nhanh định nghĩa và tính chất cơ bản, '
                    'tương tác sôi nổi trong giờ học. Tuy nhiên khi làm bài '
                    'thực hành, con còn vội vàng ở bước rút gọn phân số chứa '
                    'biến số nên tính nhầm dấu. Phụ huynh nhắc con làm '
                    'thêm bài tập luyện tập số 5 để khắc phục nhé!',
                homeworkTitle:
                    'Toán 10 — Bài luyện tập 5: Rút gọn phân số có ẩn',
                homeworkDueDate: 'Hạn chót: 20:00 tối nay',
                homeworkStatus: 'Chưa nộp',
                hasRecording: true,
                recordingDuration: '48 phút',
              )
            : null,
      );
    }

    if (isLan) {
      return ParentSessionDetail(
        session: session,
        studentCode: 'HS-07182',
        studentMajor: 'Lớp Năng khiếu Ngôn ngữ',
        schoolYear: 'Lớp 7B — Niên khóa 2024–2025',
        sessionCode: '#ENG7-B16',
        teacherInfo: TeacherDetailInfo(
          id: 'tch_nam',
          fullName: session.instructorName.isNotEmpty
              ? session.instructorName
              : 'Thầy Nam',
          title: 'IELTS 8.5',
          school: 'Học viện Ngoại ngữ Hà Nội',
          canChat: true,
        ),
        attendanceInfo: SessionAttendanceInfo(
          status: isDone ? 'present' : 'not_opened',
          statusLabel: isDone
              ? 'Có mặt (Vào lớp lúc 14:00)'
              : 'Chưa mở điểm danh\n(Mở trước giờ học 10p)',
        ),
        materials: const [
          SessionMaterial(
            id: 'mat_speaking_01',
            fileName: 'Speaking_Unit4_Presentation_Guide.pdf',
            fileSize: '1.8 MB',
            uploadTime: 'Giáo viên gửi sáng nay',
            fileType: 'pdf',
          ),
        ],
        checklist: const [
          SessionChecklistItem(
            id: 'chk_lan_mic',
            title: 'Chuẩn bị tai nghe có mic để thực hành phát âm trực tuyến.',
            type: ChecklistItemType.tool,
            isCompleted: false,
          ),
        ],
        parentGuidance:
            'Phụ huynh nên khích lệ Lan tự tin nói tiếng Anh to rõ và '
            'không ngắt lời khi con đang luyện tập cùng nhóm.',
        lessonId: 'lesson_speaking_7',
        completedAnalysis: isDone
            ? const SessionCompletedAnalysis(
                attendanceStatus: 'Có mặt',
                checkInTime: '14:00',
                attendedMinutes: 90,
                totalMinutes: 90,
                quizScore: 8.5,
                quizCorrectAnswers: 17,
                quizTotalQuestions: 20,
                teacherComment:
                    'Lan phát âm chuẩn, ngữ điệu tự nhiên và tương tác '
                    'nhóm sôi nổi trong phần thuyết trình Unit 4.',
                homeworkTitle:
                    'Ghi âm bài nói Unit 4: Presentation Skills',
                homeworkDueDate: '20:00 Thứ Bảy',
                homeworkStatus: 'Chưa nộp',
              )
            : null,
      );
    }

    // 2. Đối với tài khoản thật: Không tự tạo mock data
    return ParentSessionDetail(
      session: session,
      studentCode: child?.id,
      studentMajor: child?.className != null
          ? 'Lớp ${child!.className}'
          : null,
      schoolYear: child?.className != null
          ? 'Lớp ${child!.className} — Niên khóa 2024–2025'
          : null,
      sessionCode: '#SES-${session.startTime.month}${session.startTime.day}',
      teacherInfo: TeacherDetailInfo(
        fullName: session.instructorName.isNotEmpty
            ? session.instructorName
            : 'Giáo viên',
        title: null,
        school: null,
        canChat: true,
      ),
      attendanceInfo: isDone
          ? const SessionAttendanceInfo(
              status: 'present',
              statusLabel: 'Có mặt',
            )
          : (session.startTime.isAfter(DateTime.now())
              ? const SessionAttendanceInfo(
                  status: 'not_opened',
                  statusLabel: 'Chưa mở điểm danh\n(Mở trước giờ học 10p)',
                )
              : const SessionAttendanceInfo(
                  status: 'present',
                  statusLabel: 'Có mặt',
                )),
      materials: const [],
      checklist: const [],
      parentGuidance: null,
      rescheduleReason: session.statusNote,
      completedAnalysis: isDone
          ? const SessionCompletedAnalysis(
              attendanceStatus: 'Có mặt',
              attendedMinutes: 0,
              totalMinutes: 0,
            )
          : null,
    );
  }

  /// Thông tin phiên học cơ bản (giờ, môn, ngày, trạng thái)
  final ParentScheduleSession session;

  /// Mã số học sinh của con (VD: "HS-202410")
  final String? studentCode;

  /// Chuyên ban / khối chuyên của con (VD: "Khối chuyên Toán Tin")
  final String? studentMajor;

  /// Niên khóa học tập (VD: "Lớp 10A1 — Niên khóa 2024–2025")
  final String? schoolYear;

  /// Chi tiết về giáo viên đứng lớp
  final TeacherDetailInfo? teacherInfo;

  /// Thông tin điểm danh của buổi học
  final SessionAttendanceInfo? attendanceInfo;

  /// Danh sách tài liệu đính kèm (giáo trình, bài tập PDF)
  final List<SessionMaterial> materials;

  /// Danh sách nhiệm vụ / dụng cụ chuẩn bị trước giờ học
  final List<SessionChecklistItem> checklist;

  /// Lời khuyên gợi ý đồng hành của giáo viên dành cho phụ huynh
  final String? parentGuidance;

  /// Mã buổi học định danh (VD: "#MAT10-B24")
  final String? sessionCode;

  /// Lý do dời lịch hoặc hủy lịch nếu ca học bị đổi
  final String? rescheduleReason;

  /// ID bài giảng để chuyển tiếp sang xem chi tiết bài học
  final String? lessonId;

  /// Dữ liệu phân tích và kết quả sau khi buổi học kết thúc
  final SessionCompletedAnalysis? completedAnalysis;

  /// Có tài liệu đính kèm hay không
  bool get hasMaterials => materials.isNotEmpty;

  /// Có checklist chuẩn bị hay không
  bool get hasChecklist => checklist.isNotEmpty;

  /// Có gợi ý đồng hành cho phụ huynh hay không
  bool get hasGuidance =>
      parentGuidance != null && parentGuidance!.trim().isNotEmpty;

  /// Ca học có bị dời lịch hoặc hủy không
  bool get hasRescheduleInfo =>
      rescheduleReason != null && rescheduleReason!.isNotEmpty;

  /// Ca học đã kết thúc hay chưa
  bool get isCompleted =>
      session.status == ParentSessionStatus.completed;

  /// Có dữ liệu phân tích kết quả buổi học hay không
  bool get hasCompletedAnalysis => completedAnalysis != null;
}
