import 'package:study/features/student/data/models/course_detail_model.dart';

class MockCourseDetailData {
  const MockCourseDetailData._();

  static CourseDetailModel getCourseDetail(String courseId) {
    return CourseDetailModel(
      id: courseId,
      title: 'Xay dung ung dung Web Fullstack',
      thumbnail: null,
      badge: 'PRO COURSE',
      progress: 65,
      totalLessons: 36,
      completedLessons: 24,
      totalStudents: 1248,
      instructorName: 'Thay Mai Hoang Tung',
      instructorTitle: 'SENIOR SPECIALIST & TECH LEAD',
      instructorBio:
          'Voi hon 12 nam kinh nghiem trong linh vuc dao tao '
          'va phat trien cong nghe tai cac tap doan da quoc gia, '
          'Thay Tung da giup hon 5.000 hoc vien thay doi tu duy '
          'va dat duoc nhung buoc tien lon trong su nghiep.',
      instructorStudentCount: 5200,
      instructorRating: 4.8,
      instructorReviewCount: 1250,
      description:
          'Khoa hoc nay duoc thiet ke de giup ban lam chu cac ky nang '
          'can thiet trong ky nguyen so. Chung toi tap trung vao viec '
          'thuc hanh thuc te, giai quyet cac bai toan thuc te ma mot '
          'chuyen gia thuong gap phai.\n\n'
          'Voi lo trinh bai ban tu co ban den nang cao, ban se khong '
          'chi hoc ly thuyet ma con duoc tham gia vao cac du an thuc te '
          'de cung co kien thuc va xay dung portfolio ca nhan an tuong.',
      learningOutcomes: const [
        'Nam vung kien thuc nen tang va tu duy he thong chuyen nghiep.',
        'Thuc hanh tren 10 du an thuc te voi do kho tang dan.',
        'Ky nang toi uu hoa quy trinh lam viec va quan ly thoi gian '
            'hieu qua.',
        'Ket noi voi cong dong hoc vien va cac chuyen gia trong nganh.',
        'Cap chung chi hoan thanh khoa hoc co gia tri quoc te.',
      ],
      chapters: _chapters,
      documents: _documents,
      discussions: _discussions,
    );
  }

  static const _chapters = [
    ChapterModel(
      id: 'ch1',
      title: 'Khoi dau voi Fullstack',
      totalLessons: 4,
      completedLessons: 4,
      status: 'completed',
      lessons: [
        LessonModel(
          id: 'l1',
          title: 'Gioi thieu lo trinh hoc tap',
          duration: '12:45',
          status: LessonStatus.completed,
        ),
        LessonModel(
          id: 'l2',
          title: 'Cai dat moi truong phat trien',
          duration: '25:10',
          status: LessonStatus.completed,
        ),
        LessonModel(
          id: 'l3',
          title: 'Tong quan ve Frontend & Backend',
          duration: '18:30',
          status: LessonStatus.completed,
        ),
        LessonModel(
          id: 'l4',
          title: 'Quy trinh xay dung san pham',
          duration: '15:20',
          status: LessonStatus.completed,
        ),
      ],
    ),
    ChapterModel(
      id: 'ch2',
      title: 'Kien truc Backend voi Node.js',
      totalLessons: 6,
      completedLessons: 1,
      status: 'in_progress',
      lessons: [
        LessonModel(
          id: 'l5',
          title: 'Cau truc thu muc du an Node.js',
          duration: '14:00',
          status: LessonStatus.inProgress,
          currentTime: '08:15',
          totalTime: '14:00',
        ),
        LessonModel(
          id: 'l6',
          title: 'Quan ly Routes voi Express',
          duration: '22:45',
          status: LessonStatus.locked,
        ),
        LessonModel(
          id: 'l7',
          title: 'Middlewares trong ung dung thuc te',
          duration: '19:30',
          status: LessonStatus.locked,
        ),
        LessonModel(
          id: 'l8',
          title: 'Ket noi MongoDB va Mongoose',
          duration: '28:15',
          status: LessonStatus.locked,
        ),
        LessonModel(
          id: 'l9',
          title: 'Authentication voi JWT',
          duration: '35:20',
          status: LessonStatus.locked,
        ),
        LessonModel(
          id: 'l10',
          title: 'Unit Testing voi Jest',
          duration: '24:00',
          status: LessonStatus.locked,
        ),
      ],
    ),
    ChapterModel(
      id: 'ch3',
      title: 'Frontend voi React.js',
      totalLessons: 8,
      completedLessons: 0,
      lessons: [
        LessonModel(
          id: 'l11',
          title: 'React Components va JSX',
          duration: '20:00',
          status: LessonStatus.locked,
        ),
        LessonModel(
          id: 'l12',
          title: 'State Management voi Hooks',
          duration: '30:15',
          status: LessonStatus.locked,
        ),
        LessonModel(
          id: 'l13',
          title: 'React Router va Navigation',
          duration: '18:45',
          status: LessonStatus.locked,
        ),
        LessonModel(
          id: 'l14',
          title: 'API Integration voi Axios',
          duration: '25:30',
          status: LessonStatus.locked,
        ),
        LessonModel(
          id: 'l15',
          title: 'Form Handling va Validation',
          duration: '22:10',
          status: LessonStatus.locked,
        ),
        LessonModel(
          id: 'l16',
          title: 'Global State voi Redux Toolkit',
          duration: '35:00',
          status: LessonStatus.locked,
        ),
        LessonModel(
          id: 'l17',
          title: 'Performance Optimization',
          duration: '28:20',
          status: LessonStatus.locked,
        ),
        LessonModel(
          id: 'l18',
          title: 'Deploy len Vercel va Netlify',
          duration: '15:40',
          status: LessonStatus.locked,
        ),
      ],
    ),
    ChapterModel(
      id: 'ch4',
      title: 'Database & DevOps',
      totalLessons: 6,
      completedLessons: 0,
      lessons: [
        LessonModel(
          id: 'l19',
          title: 'SQL vs NoSQL - Khi nao dung gi',
          duration: '18:00',
          status: LessonStatus.locked,
        ),
        LessonModel(
          id: 'l20',
          title: 'PostgreSQL nang cao',
          duration: '32:00',
          status: LessonStatus.locked,
        ),
        LessonModel(
          id: 'l21',
          title: 'Redis va Caching Strategies',
          duration: '24:30',
          status: LessonStatus.locked,
        ),
        LessonModel(
          id: 'l22',
          title: 'Docker co ban',
          duration: '28:15',
          status: LessonStatus.locked,
        ),
        LessonModel(
          id: 'l23',
          title: 'CI/CD Pipeline voi GitHub Actions',
          duration: '22:40',
          status: LessonStatus.locked,
        ),
        LessonModel(
          id: 'l24',
          title: 'Deploy len AWS / GCP',
          duration: '30:00',
          status: LessonStatus.locked,
        ),
      ],
    ),
  ];

  static const _documents = [
    DocumentModel(
      id: 'doc1',
      title: 'Huong dan cai dat Figma & cong cu',
      type: DocumentType.pdf,
      size: '2.4 MB',
      updatedAt: '12/05',
    ),
    DocumentModel(
      id: 'doc2',
      title: 'Bai giang 01: Quy trinh Design System',
      type: DocumentType.pptx,
      size: '15.8 MB',
      updatedAt: '10/05',
    ),
    DocumentModel(
      id: 'doc3',
      title: 'Checklist kiem thu giao dien',
      type: DocumentType.pdf,
      size: '1.1 MB',
      updatedAt: '08/05',
    ),
    DocumentModel(
      id: 'doc4',
      title: 'Source Code du an mau (React Native)',
      type: DocumentType.zip,
      size: '45.2 MB',
      updatedAt: '05/05',
    ),
    DocumentModel(
      id: 'doc5',
      title: 'Ebook: Tam ly hoc trong UX Design',
      type: DocumentType.epub,
      size: '8.4 MB',
      updatedAt: '01/05',
      isGift: true,
    ),
  ];

  static const _discussions = [
    DiscussionModel(
      id: 'disc1',
      authorName: 'Minh Hoang',
      role: DiscussionRole.student,
      content:
          'Moi nguoi cho minh hoi, o phut 12:45 thay co noi ve '
          'quy tac Grid 8px, nhung neu minh dung font size le '
          'nhu 13px hoac 15px thi co anh huong nhieu den cau '
          'truc khong a?',
      timeAgo: '2 gio truoc',
      likes: 12,
      replyCount: 3,
      replies: [
        DiscussionModel(
          id: 'disc1r1',
          authorName: 'Co Lan Phuong',
          role: DiscussionRole.instructor,
          content:
              'Chao Hoang, cau hoi rat hay nhe! Thuc te font-size '
              'le van dung duoc, nhung line-height (do cao dong) '
              'nen la boi so cua 4 hoac 8 de dam bao khoi text '
              'van khop voi he thong Grid tong the nhe.',
          timeAgo: '1 gio truoc',
          likes: 5,
        ),
      ],
    ),
    DiscussionModel(
      id: 'disc2',
      authorName: 'Thuy Duong',
      role: DiscussionRole.student,
      content:
          'Bai hoc nay cuc ky thuc chien luon, minh da ap dung '
          'ngay vao project cuoi khoa va thay hieu qua ro ret. '
          'Cam on co Phuong nhieu a!',
      timeAgo: '4 gio truoc',
      likes: 8,
      replyCount: 0,
    ),
    DiscussionModel(
      id: 'disc3',
      authorName: 'Tran Phong',
      role: DiscussionRole.student,
      content:
          'Thay oi phan tai lieu dinh kem minh khong tai duoc a, '
          'no bao loi 404.',
      timeAgo: '6 gio truoc',
      likes: 1,
      replyCount: 1,
    ),
    DiscussionModel(
      id: 'disc4',
      authorName: 'Ngoc Anh',
      role: DiscussionRole.student,
      content:
          'Phan Docker co ban giai thich de hieu qua! Minh tu '
          'hoc hoai khong hieu, hoc xong bai nay la lam duoc '
          'ngay luon. Thanks thay!',
      timeAgo: '1 ngay truoc',
      likes: 15,
      replyCount: 2,
    ),
  ];
}
