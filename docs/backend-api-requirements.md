# Backend API Requirements for Mobile

## 1. Teacher Stats Endpoint (NEW)

```
GET /api/teachers/:id/stats

Response:
{
  "data": {
    "total_courses": 12,
    "total_students": 2400,
    "total_lessons": 128,
    "average_rating": "4.9",
    "total_reviews": 156
  }
}
```

## 2. Teacher Courses Endpoint (NEW)

```
GET /api/teachers/:id/courses?page=1&page_size=10

Response:
{
  "data": {
    "courses": [
      {
        "id": "uuid",
        "title": "Course Title",
        "thumbnail_url": "...",
        "lesson_count": 12,
        "duration": "6h 40m",
        "progress": 0.65
      }
    ],
    "total": 12,
    "page": 1,
    "page_size": 10
  }
}
```

## 3. Extend TeacherProfileDTO

Add fields:

```go
type TeacherProfileResponseDTO struct {
  // existing fields...
  ShortBio    *string   `json:"short_bio,omitempty"`
  About       *string   `json:"about,omitempty"`
  Skills      []string  `json:"skills,omitempty"`
  Location    *string   `json:"location,omitempty"`
}
```

## 4. Extend CertificateDTO

Add fields:

```go
type CertificateResponseDTO struct {
  // existing fields...
  Skills      []string  `json:"skills,omitempty"`
  Duration    *string   `json:"duration,omitempty"`
  Level       *string   `json:"level,omitempty"`
}
```

## 5. Portfolio Extensions (Optional)

If public-profile is not sufficient:

```
GET /api/users/:id/portfolio

Response includes:
- projects[]
- skills[] with level
- experiences[]
- social_links[]
```

## Priority

| API | Priority | Blocking |
|-----|----------|----------|
| Teacher Stats | High | instructor_detail_screen.dart |
| Teacher Courses | High | instructor_detail_screen.dart |
| TeacherProfileDTO extension | Medium | instructor bio/skills |
| CertificateDTO extension | Low | certificate_detail_screen.dart |
| Portfolio | Low | portfolio_screen.dart |
