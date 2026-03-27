import 'package:study/features/student/data/models/lesson_detail_model.dart';

class MockLessonDetailData {
  const MockLessonDetailData._();

  static LessonDetailModel getLessonDetail(String lessonId) {
    return switch (lessonId) {
      'l2' => _noHomeworkNoQuiz(),
      'l3' => _noMaterials(),
      'l4' => _minimalLesson(),
      _ => _fullLesson(),
    };
  }

  static LessonDetailModel _fullLesson() {
    return const LessonDetailModel(
      id: 'l-full',
      title: 'Kien truc Microservices va Design Patterns co ban',
      chapterTitle: 'Chuong 3: Phan tich du lieu',
      instructorName: 'Dr. Nguyen Anh Tu',
      instructorTitle: 'Senior Software Architect',
      level: 'INTERMEDIATE',
      duration: '35:00',
      currentTime: '12:45',
      viewCount: 1200,
      description:
          'Bai hoc nay cung cap cai nhin tong quan ve kien truc '
          'Microservices, so sanh voi kien truc Monolithic truyen thong '
          'va cach ap dung cac Design Patterns de giai quyet cac thach '
          'thuc ve kha nang mo rong trong he thong hien dai.',
      objectives: [
        LessonObjective(
          id: 'obj1',
          title: 'Hieu ro khai niem Microservices',
          icon: 'cloud',
        ),
        LessonObjective(
          id: 'obj2',
          title: 'Phan biet Mono vs Micro',
          icon: 'compare',
        ),
        LessonObjective(
          id: 'obj3',
          title: 'Nam vung 5 Design Patterns pho bien nhat hien nay',
          icon: 'pattern',
        ),
      ],
      contentSections: [
        LessonContentSection(
          id: 'cs1',
          order: 1,
          title: 'Tien hoa tu Monolithic len Microservices',
          subtitle: 'Lich su va ly do tai sao cac doanh nghiep dich chuyen.',
        ),
        LessonContentSection(
          id: 'cs2',
          order: 2,
          title: 'API Gateway & Service Discovery',
          subtitle: 'Cach cac dich vu tim thay va giao tiep voi nhau.',
        ),
        LessonContentSection(
          id: 'cs3',
          order: 3,
          title: 'Database per Service Pattern',
          subtitle: 'Quan ly du lieu phan tan va tinh toan ven.',
        ),
        LessonContentSection(
          id: 'cs4',
          order: 4,
          title: 'Circuit Breaker & Resilience',
          subtitle: 'Xay dung he thong co kha nang chiu loi cao.',
        ),
      ],
      materials: [
        LessonMaterial(
          id: 'mat1',
          title: 'Slide_Bai_12.pdf',
          type: LessonMaterialType.pdf,
          size: '2.4 MB',
          description: 'PDF Document',
        ),
        LessonMaterial(
          id: 'mat2',
          title: 'Source_Code_React.zip',
          type: LessonMaterialType.zip,
          size: '15.8 MB',
          description: 'Archive File',
        ),
        LessonMaterial(
          id: 'mat3',
          title: 'Cheatsheet_UIUX.pdf',
          type: LessonMaterialType.pdf,
          size: '850 KB',
          description: 'Visual Guide',
        ),
        LessonMaterial(
          id: 'mat4',
          title: 'Demo_Recording.mp4',
          type: LessonMaterialType.video,
          size: '120 MB',
          description: 'Video ghi lai demo tren lop',
        ),
        LessonMaterial(
          id: 'mat5',
          title: 'Architecture_Diagrams.pptx',
          type: LessonMaterialType.slide,
          size: '5.2 MB',
          description: 'Slide trinh bay',
        ),
      ],
      homework: HomeworkModel(
        id: 'hw1',
        title: 'Yeu cau bai tap',
        deadline: '23:59, 20 Th10',
        description:
            'Chao cac ban hoc vien cua 40Study! Dua tren noi dung '
            'bai giang ve Cau truc du lieu va Giai thuat, hay thuc '
            'hien cac yeu cau sau:',
        requirements: [
          'Thiet ke so do luong cho thuat toan Tim kiem nhi phan '
              '(Binary Search).',
          'Viet ma gia (Pseudocode) cho bai toan toi uu hoa bo nho '
              'da neu o phut 15:20.',
          'Giai thich su khac biet ve do phuc tap thoi gian giua O(n) '
              'va O(log n) trong cac truong hop thuc te.',
        ],
        note:
            'Ghi chu: Bai lam can trinh bay sach dep duoi dinh dang '
            'PDF hoac Link GitHub.',
        attachments: [
          LessonMaterial(
            id: 'att1',
            title: 'Tai-lieu-huong-dan.pdf',
            type: LessonMaterialType.pdf,
            size: '1.2 MB',
            description: 'PDF Document',
          ),
          LessonMaterial(
            id: 'att2',
            title: 'So-do-mau.jpg',
            type: LessonMaterialType.image,
            size: '450 KB',
            description: 'Image',
          ),
        ],
      ),
      hasQuiz: true,
      quizAttempts: [
        QuizAttempt(
          id: 'qa1',
          attemptNumber: 3,
          score: 10,
          totalScore: 10,
          date: '20/10/2023',
          status: QuizStatus.completed,
        ),
        QuizAttempt(
          id: 'qa2',
          attemptNumber: 2,
          score: 9,
          totalScore: 10,
          date: '15/10/2023',
          status: QuizStatus.completed,
        ),
        QuizAttempt(
          id: 'qa3',
          attemptNumber: 1,
          score: 7,
          totalScore: 10,
          date: '12/10/2023',
          status: QuizStatus.saved,
        ),
      ],
    );
  }

  static LessonDetailModel _noHomeworkNoQuiz() {
    return const LessonDetailModel(
      id: 'l-no-hw-quiz',
      title: 'Cai dat moi truong phat trien',
      chapterTitle: 'Chuong 1: Bat dau',
      instructorName: 'Tran Van Binh',
      instructorTitle: 'DevOps Engineer',
      level: 'BEGINNER',
      duration: '25:10',
      currentTime: '08:30',
      viewCount: 3500,
      description:
          'Huong dan chi tiet cach cai dat Node.js, VS Code, Git va '
          'cac extension can thiet de bat dau lap trinh. Bai hoc nay '
          'giup ban chuan bi moi truong lam viec chuyen nghiep ngay tu '
          'dau.',
      objectives: [
        LessonObjective(
          id: 'obj1',
          title: 'Cai dat Node.js va npm',
          icon: 'cloud',
        ),
        LessonObjective(
          id: 'obj2',
          title: 'Thiet lap VS Code chuyen nghiep',
          icon: 'pattern',
        ),
      ],
      contentSections: [
        LessonContentSection(
          id: 'cs1',
          order: 1,
          title: 'Cai dat Node.js tren Windows / MacOS / Linux',
          subtitle: 'Download va verify phien ban LTS.',
        ),
        LessonContentSection(
          id: 'cs2',
          order: 2,
          title: 'Thiet lap VS Code',
          subtitle: 'Cai extension Prettier, ESLint, GitLens.',
        ),
        LessonContentSection(
          id: 'cs3',
          order: 3,
          title: 'Cau hinh Git va SSH Key',
          subtitle: 'Ket noi voi GitHub repository.',
        ),
      ],
      materials: [
        LessonMaterial(
          id: 'mat1',
          title: 'Huong_dan_cai_dat.pdf',
          type: LessonMaterialType.pdf,
          size: '3.1 MB',
          description: 'Step-by-step guide',
        ),
        LessonMaterial(
          id: 'mat2',
          title: 'VS_Code_Settings.json',
          type: LessonMaterialType.zip,
          size: '12 KB',
          description: 'Config file',
        ),
      ],
      hasQuiz: false,
    );
  }

  static LessonDetailModel _noMaterials() {
    return const LessonDetailModel(
      id: 'l-no-mat',
      title: 'Tong quan ve Frontend & Backend',
      chapterTitle: 'Chuong 1: Bat dau',
      instructorName: 'Le Thi Mai',
      instructorTitle: 'Fullstack Developer',
      level: 'BEGINNER',
      duration: '18:30',
      currentTime: '05:12',
      viewCount: 2100,
      description:
          'Tim hieu su khac biet giua Frontend va Backend, cach '
          'chung giao tiep qua API va kien truc client-server co ban '
          'trong cac ung dung web hien dai.',
      objectives: [
        LessonObjective(
          id: 'obj1',
          title: 'Hieu khai niem Client-Server',
          icon: 'cloud',
        ),
        LessonObjective(
          id: 'obj2',
          title: 'Phan biet FE vs BE',
          icon: 'compare',
        ),
        LessonObjective(
          id: 'obj3',
          title: 'REST API la gi',
          icon: 'pattern',
        ),
        LessonObjective(
          id: 'obj4',
          title: 'HTTP Methods co ban',
          icon: 'cloud',
        ),
      ],
      contentSections: [
        LessonContentSection(
          id: 'cs1',
          order: 1,
          title: 'Kien truc Client-Server',
          subtitle: 'Mo hinh co ban cua ung dung web.',
        ),
        LessonContentSection(
          id: 'cs2',
          order: 2,
          title: 'Frontend: HTML, CSS, JavaScript',
          subtitle: 'Nhung gi nguoi dung nhin thay.',
        ),
        LessonContentSection(
          id: 'cs3',
          order: 3,
          title: 'Backend: Server, Database, API',
          subtitle: 'Xu ly logic va luu tru du lieu.',
        ),
      ],
      homework: HomeworkModel(
        id: 'hw2',
        title: 'Bai tap thuc hanh',
        deadline: '23:59, 25 Th10',
        description:
            'Viet 1 bai blog ngan (300-500 tu) giai thich su khac '
            'biet giua Frontend va Backend cho nguoi moi bat dau.',
        requirements: [
          'Giai thich FE va BE bang ngon ngu don gian.',
          'Cho 2-3 vi du thuc te minh hoa.',
          'Trinh bay duoi dang PDF hoac Google Docs.',
        ],
        note: 'Khong can viet code, chi can giai thich khai niem.',
      ),
      hasQuiz: true,
      quizAttempts: [
        QuizAttempt(
          id: 'qa1',
          attemptNumber: 1,
          score: 8,
          totalScore: 10,
          date: '18/10/2023',
          status: QuizStatus.completed,
        ),
      ],
    );
  }

  static LessonDetailModel _minimalLesson() {
    return const LessonDetailModel(
      id: 'l-minimal',
      title: 'Quy trinh xay dung san pham',
      chapterTitle: 'Chuong 1: Bat dau',
      instructorName: 'Pham Duc Huy',
      level: 'BEGINNER',
      duration: '15:20',
      viewCount: 50,
      hasQuiz: false,
    );
  }
}
