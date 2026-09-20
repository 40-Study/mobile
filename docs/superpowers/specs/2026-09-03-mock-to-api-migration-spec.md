# Mock Data to API Migration Spec

> **Goal:** Replace all mock/hardcoded data in mobile app with real API calls

**Created:** 2026-09-03

---

## Executive Summary

Audit identified **17 mock data locations** across the mobile app. After cross-referencing with backend APIs:
- **Group A (6 items):** APIs exist, connect immediately
- **Group B (5 items):** APIs exist but need FE model adaptation
- **Group C (2 items):** Keep as-is (localStorage/fallback)
- **Group D (4 items):** Need backend API extensions (document only)

---

## Detailed Findings

### Group A: Connect Existing APIs

| Location | Mock Data | Backend API | Status |
|----------|-----------|-------------|--------|
| `profile_bloc.dart:18-29` | Hardcoded UserModel | Auth service `/api/auth/me` | Need to inject AuthRepository |
| `achievement_bloc.dart` | Was 404 due to wrong path | `GET /api/achievements/me` | **FIXED** - endpoint corrected |
| `quiz_bloc.dart` | Calls repository correctly | `GET /api/quizzes/:id/questions` | Working via StudentApiClient |
| `student_repository_impl.dart` | getCertificates | `GET /api/certificates` | Already implemented in CourseApiClient |
| `search_bloc.dart` | Uses repository | `GET /api/courses?search=` | Working |
| `notification_bloc.dart` | Uses repository | `GET /api/notifications/` | Working |

### Group B: Adapt Frontend Models

| Location | Issue | Backend Response | Required Changes |
|----------|-------|------------------|------------------|
| `stats_view.dart:182-193` | Mock contribution grid | `/api/users/:id/public-profile` returns `activity[]` | Create ContributionModel, parse activity array |
| `achievement_screen.dart:820-828` | Mock contribution data | Same as above | Share ContributionModel |
| `certificate_detail_screen.dart:39-45` | Hardcoded skills array | CertificateModel missing skills | Backend: add skills to certificate response |
| `portfolio_screen.dart:19-116` | Full mock profile/projects/skills | `/api/users/:id/public-profile` partial | Need portfolio-specific fields in backend |
| `profile_screen.dart:46-47` | Mock profiles list | No API for user list | For demo only - acceptable |

### Group C: Keep As-Is

| Location | Reason |
|----------|--------|
| `bookmark_storage.dart` | User confirmed: use localStorage |
| `lesson_video_player.dart:21` | Fallback sample video URL - acceptable |

### Group D: Backend API Extensions Needed

| Feature | Current State | Required API |
|---------|---------------|--------------|
| **Instructor Stats** | Hardcoded in `instructor_detail_screen.dart:252-258` | `GET /api/teachers/:id/stats` → `{courses: 12, students: 2400, lessons: 128, rating: 4.9}` |
| **Instructor Bio/About** | Hardcoded Vietnamese text `instructor_detail_screen.dart:276-283` | Extend TeacherProfileDTO with `about`, `short_bio` |
| **Instructor Skills** | Hardcoded array `instructor_detail_screen.dart:310-316` | Extend TeacherProfileDTO with `skills[]` |
| **Instructor Courses** | Mock course cards `instructor_detail_screen.dart:375-398` | `GET /api/teachers/:id/courses` |

---

## File-by-File Audit

### 1. ProfileBloc (`lib/features/student/bloc/profile/profile_bloc.dart`)
```dart
// Line 18-29: Full mock user
emit(const ProfileSuccess(
  user: UserModel(
    id: 'user-1',
    email: 'student@example.com',
    fullName: 'Nguyen Van A',
    // ...
  ),
));
```
**Fix:** Inject AuthRepository, call `getCurrentUser()`.

### 2. InstructorDetailScreen (`lib/features/student/presentation/learning/instructor_detail_screen.dart`)
```dart
// Line 214: Hardcoded bio
'Chuyên gia thiết kế sản phẩm số với hơn 8 năm kinh nghiệm...'

// Line 252-258: Hardcoded stats
const _StatItem(value: '12', label: 'Khóa học'),
const _StatItem(value: '2.4K', label: 'Học viên'),
const _StatItem(value: '128', label: 'Bài học'),
const _StatItem(value: '4.9', label: 'Đánh giá'),

// Line 276-283: Hardcoded about section
'Cô Minh Anh hiện là Product Designer...'

// Line 310-316: Hardcoded skills
final skills = [
  (Icons.devices_rounded, 'UI/UX Design'),
  (Icons.widgets_outlined, 'Product Design'),
  // ...
];

// Line 375-398: Mock course cards
const _CourseCard(
  title: 'UI/UX Design Fundamentals',
  lessonCount: 12,
  // ...
),
```
**Fix:** Create InstructorBloc, fetch from `/api/teachers/:id` + `/api/teacher-profiles/:id`. Backend needs extension for stats/skills/courses.

### 3. PortfolioScreen (`lib/features/student/presentation/portfolio/portfolio_screen.dart`)
```dart
// Line 19-33: Full mock profile
_PortfolioProfile _profile = const _PortfolioProfile(
  name: 'Linh Nguyen',
  title: 'UI/UX Designer',
  // ...
);

// Line 35-40: Mock stats
final _stats = const _PortfolioStats(
  yearsExperience: '3+',
  projectsCompleted: 18,
  // ...
);

// Line 69-94: Mock projects
final List<_Project> _projects = [
  const _Project(title: 'EduFlow', ...),
  // ...
];

// Line 96-105: Mock skills with levels
final List<_Skill> _skills = [
  const _Skill(name: 'UI Design', level: 5),
  // ...
];

// Line 107-116: Mock experiences
final List<_Experience> _experiences = [
  const _Experience(position: 'Senior UI/UX Designer', ...),
];
```
**Fix:** Backend `/api/users/:id/public-profile` exists but missing portfolio-specific fields. Need API extension.

### 4. StatsView/ContributionGrid (`lib/features/student/presentation/achievement/widgets/stats_view.dart`)
```dart
// Line 46-48: Generate mock contributions
final contributions = _generateMockContributions(now);

// Line 182-193: Random mock generator
List<int> _generateMockContributions(DateTime now) {
  final random = Random(now.year * 1000 + now.month * 100 + now.day);
  return List.generate(84, (_) => random.nextInt(5));
}
```
**Fix:** Backend `/api/users/:id/public-profile` returns `activity[]` with `{date, count}`. Create model and fetch.

### 5. CertificateDetailScreen (`lib/features/student/presentation/achievement/certificate_detail_screen.dart`)
```dart
// Line 39-45: Hardcoded skills
const _SkillsSection(skills: [
  'User Research',
  'Wireframing',
  'UI Design',
  'Prototyping',
  'Design System',
]),
```
**Fix:** Backend CertificateModel needs `skills[]` field. Document for backend team.

### 6. AchievementScreen (`lib/features/student/presentation/achievement/achievement_screen.dart`)
```dart
// Line 820-828: Mock contribution similar to StatsView
```
**Fix:** Same as StatsView - use public profile activity API.

---

## Backend API Requirements (for backend team)

### 1. Teacher Stats Endpoint
```
GET /api/teachers/:id/stats

Response:
{
  "data": {
    "total_courses": 12,
    "total_students": 2400,
    "total_lessons": 128,
    "average_rating": 4.9,
    "total_reviews": 156
  }
}
```

### 2. Teacher Courses Endpoint
```
GET /api/teachers/:id/courses?page=1&page_size=10

Response:
{
  "data": {
    "courses": [...],
    "total": 12,
    "page": 1,
    "page_size": 10
  }
}
```

### 3. Extend TeacherProfileDTO
```go
type TeacherProfileResponseDTO struct {
  // existing fields...
  ShortBio    *string   `json:"short_bio,omitempty"`    // NEW
  About       *string   `json:"about,omitempty"`        // NEW
  Skills      []string  `json:"skills,omitempty"`       // NEW
  Location    *string   `json:"location,omitempty"`     // NEW
}
```

### 4. Extend CertificateDTO
```go
type CertificateResponseDTO struct {
  // existing fields...
  Skills      []string  `json:"skills,omitempty"`       // NEW
  Duration    *string   `json:"duration,omitempty"`     // NEW (e.g., "42h 30m")
  Level       *string   `json:"level,omitempty"`        // NEW
}
```

### 5. Portfolio Extensions (if needed beyond public-profile)
```
GET /api/users/:id/portfolio

Response includes:
- projects[]
- skills[] with level
- experiences[]
- social_links[]
```

---

## Implementation Priority

### Phase 1: Quick Wins (Group A)
1. Fix ProfileBloc to use AuthRepository
2. Verify achievement/notification/quiz APIs working

### Phase 2: Model Adaptation (Group B)
1. Create ContributionModel for activity data
2. Connect contribution grid to public-profile API
3. Update StatsView and AchievementScreen

### Phase 3: Backend Coordination (Group D)
1. Document API requirements for backend team
2. Create InstructorBloc with loading states
3. Connect when APIs ready

---

## Files to Modify

### Frontend (can fix now)
- `lib/features/student/bloc/profile/profile_bloc.dart`
- `lib/features/student/presentation/achievement/widgets/stats_view.dart`
- `lib/features/student/presentation/achievement/achievement_screen.dart`
- `lib/features/student/data/models/` (add ContributionModel)

### Frontend (after backend ready)
- `lib/features/student/presentation/learning/instructor_detail_screen.dart`
- `lib/features/student/presentation/portfolio/portfolio_screen.dart`
- `lib/features/student/presentation/achievement/certificate_detail_screen.dart`

### Backend (document for team)
- Teacher stats/courses endpoints
- TeacherProfileDTO extensions
- CertificateDTO extensions
