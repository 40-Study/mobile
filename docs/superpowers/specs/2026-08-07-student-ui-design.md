# Student UI Design Spec

**Date:** 2026-08-07
**Platform:** Flutter Mobile (40Study)
**Approach:** Soft Card System - Minimal, clean, professional, engaging

---

## 1. Overview

### Tab Structure

| Tab | Purpose |
|-----|---------|
| Home | Continue learning, today's schedule (timeline), assignments |
| Learning | Courses (3 states) > Lessons > Sub-lessons > Content |
| Schedule | Calendar view, tap day for timeline details |
| Achievement | Sub-tabs: Badges, Certificates, Stats |
| Profile | Info, portfolio, settings, linked accounts |

### Additional Features

- Notifications (push + in-app)
- Search (courses, lessons, quiz)
- Bookmarks/Favorites
- Settings (theme, language, notifications)

### Navigation

- Bottom tab bar (5 tabs)
- Drawer menu (notifications, bookmarks, search, settings, help, logout)

---

## 2. Design System Usage

### Colors (from `app_colors.dart`)

| Usage | Color |
|-------|-------|
| Primary/Active | `brandBlue` (#2563EB) |
| Accent light | `blue50` - `blue200` |
| Text primary | `slate900` |
| Text secondary | `slate500` |
| Background | `surfaceContainerLowest`, `slate50` |
| Success | `TogetherSemanticColors.success` |
| Warning | `TogetherSemanticColors.warning` |
| Error | `TogetherSemanticColors.error` |

### Typography (from `app_typography.dart`)

| Element | Style |
|---------|-------|
| Page title | `headlineMedium` |
| Section header | `headlineSmall` |
| Card title | `titleMedium` |
| Body text | `bodyMedium` |
| Caption/Meta | `bodySmall`, `caption` |
| Chip/Tab label | `labelMedium` |
| Badge | `overline` |

### Spacing (from `app_spacing.dart`)

| Element | Value |
|---------|-------|
| Screen padding | 24px (`screenPadding`) |
| Card padding | 16px (`cardPadding`) |
| Section gap | 32px (`sectionSpacing`) |
| List item gap | 12px (`listItemSpacing`) |
| Component gap | 8-16px (`sm`-`lg`) |

### Radius

| Component | Radius |
|-----------|--------|
| Card | 16px |
| Button | 12px |
| Chip/Tag | 20px (full round) |
| Input field | 12px |
| Avatar | circle |
| Thumbnail | 8px |

### Shadows

| Component | Shadow |
|-----------|--------|
| Card default | `shadowCard` |
| Card elevated | `shadowElevated` |
| Primary button | `shadowBlue` |

---

## 3. Navigation & App Shell

### Bottom Navigation

```
Height: 64px
Icon size: 24px
Label: labelSmall (11px)
Active: brandBlue + filled icon + pill indicator (blue100 bg)
Inactive: slate400 + outlined icon
```

### App Bar

```
Height: 56px
Left: Drawer icon (hamburger)
Center: Page title (headlineMedium)
Right: Notification bell + Avatar
```

### Drawer Menu

```
Width: 280px
Header: Avatar (48px) + Name + Email
Items: Icon (24px) + Label + Badge count (if any)
Sections: Main nav, Settings, Account
```

---

## 4. Home Tab

### Layout

1. **Greeting header**: "Xin chao, [Name]" + avatar
2. **Continue Learning Card**: Course thumbnail, title, current lesson, progress bar, CTA
3. **Today's Schedule**: Timeline list (vertical line + dots + event cards)
4. **Assignments Due**: List with deadline badges

### Continue Learning Card

```
Background: surfaceContainerLowest
Shadow: shadowCard
Radius: 16px
Padding: 16px
Progress bar: 6px height, brandBlue fill, blue100 track
```

### Schedule Timeline

```
Line: 2px width, blue200
Dot active: 12px, brandBlue (current/next)
Dot inactive: 12px, slate300 border, transparent fill
Time: labelLarge, brandBlue
Title: titleMedium, slate900
Meta: bodySmall, slate500
```

### Assignment Item

```
List tile with divider
Deadline badge: warning color if < 3 days
```

### Empty States

- No continue learning: "Bat dau khoa hoc dau tien" + CTA
- No schedule: "Khong co lich hoc hom nay"
- No assignments: "Hoan thanh tat ca bai tap!"

---

## 5. Learning Tab

### Main View (Course List)

1. Search bar (sticky top)
2. Filter chips: "Dang hoc" | "Hoan thanh" | "Cho khai giang"
3. Course cards list

### Course Card

```
Thumbnail: 80x80, radius 8px
Card: radius 16px, shadowCard
Content: Title, progress (X/Y bai), progress bar, next lesson hint
```

### Course Detail

1. Hero: Course thumbnail with overlay
2. Info: Title, instructor, duration, lesson count
3. Progress bar with percentage
4. Content tree:
   - Chapter (collapsible): Title + progress badge
   - Lesson items with status icons

### Lesson Status Icons

| Status | Icon |
|--------|------|
| Completed | Checkmark (success color) |
| Current | Play icon (brandBlue) |
| Locked | Lock icon (slate400) |

### Lesson Detail

1. Video player (16:9 aspect)
2. Content tabs: Video | Tai lieu | Bai tap | Ghi chu
3. Lesson description
4. Attachments list
5. Bottom nav: Prev/Next + Progress + Complete button

---

## 6. Schedule Tab

### Calendar View

```
Month header: headlineMedium + nav arrows
Day cell: 40x40, bodyMedium
Today: brandBlue border 2px, radius 8px
Selected: brandBlue bg, white text
Has event: 6px dot below date, brandBlue
Weekend: slate400 text
Other month: slate300 text
```

### Event Types (Color Coding)

| Type | Color | Icon |
|------|-------|------|
| Livestream | blue500 | Video camera |
| Video lesson | slate600 | Play |
| Quiz/Assignment | warning | Document |
| Deadline | error | Clock |

### Day Detail

- Date header
- Timeline list (reuse Home component)

---

## 7. Achievement Tab

### Hero Card

```
Background: gradientBlueSoft
Radius: 20px
Padding: 24px
Content: Level, XP bar, streak, courses completed
XP bar: 8px height, blue500 fill, blue100 track
```

### Sub-tabs

Badges | Certificates | Stats

### Badges Grid

```
Columns: 4
Gap: 12px
Card: 80x100, radius 12px, slate50 bg
Icon: 32px
Locked: grayscale filter + lock overlay
```

### Certificate Card

```
Thumbnail preview of certificate
Shadow: shadowCard
Radius: 16px
Actions: View detail, Download PDF, Share
```

### Stats View

```
Period selector: Dropdown (Tuan/Thang/Nam)
Bar chart: brandBlue bars, rounded top
Stat cards: 2 columns, blue50 bg, radius 12px
```

---

## 8. Profile Tab

### Layout

1. Header card: Avatar (80px) + Name + Email + Edit button
2. Menu sections (grouped cards)

### Menu Sections

**Account**
- Thong tin ca nhan
- Portfolio
- Doi mat khau
- Lien ket tai khoan

**Preferences**
- Giao dien toi (toggle)
- Ngon ngu
- Thong bao

**Support**
- Tro giup & Ho tro
- Dieu khoan su dung
- Chinh sach bao mat

**Logout** (error color)

### Menu Item

```
Height: 56px
Icon: 24px, slate600
Arrow: slate400
Divider between items
```

### Portfolio Screen

- Skills chips (blue50 bg, brandBlue text)
- Projects list (thumbnail 60x60, links)
- External certificates

---

## 9. Additional Screens

### Notifications

```
Grouped by: Hom nay, Hom qua, Tuan truoc
Unread indicator: blue dot
Item: Icon + Title + Time + Description
```

### Search

```
Search bar: sticky, with clear button
Recent searches: chip list
Filter tabs: Tat ca | Khoa hoc | Bai hoc | Quiz
Results: list cards
```

### Bookmarks

```
Filter tabs: Khoa hoc | Bai hoc | Tai lieu
Item: Card with bookmark icon, save date
```

---

## 10. Common Components

### Loading State

Shimmer skeleton matching content layout

### Empty State

```
Icon: 48px, slate400
Title: titleMedium, slate700
Description: bodySmall, slate500
CTA button (optional)
```

### Error State

```
Icon: warning, 48px
Title: "Khong the tai du lieu"
Description: "Kiem tra ket noi mang"
Retry button
```

### Toast/Snackbar

```
Radius: 8px
Shadow: shadowCard
Types: success (green), error (red), info (blue)
Action button optional
```

---

## 11. Component Reference Table

| Component | Background | Radius | Shadow |
|-----------|------------|--------|--------|
| Card default | surfaceContainerLowest | 16px | shadowCard |
| Card elevated | surface | 16px | shadowElevated |
| Chip inactive | slate100 | 20px | none |
| Chip active | brandBlue | 20px | none |
| Button primary | brandBlue | 12px | shadowBlue |
| Button secondary | blue50 | 12px | none |
| Input field | slate50 | 12px | none |
| Menu item | transparent | 0 | none |
| Toast success | success | 8px | shadowCard |
| Toast error | error | 8px | shadowCard |
| Avatar | blue100 placeholder | circle | none |
| Thumbnail | - | 8px | none |
| Progress bar | blue100 track | 3-4px | none |

---

## 12. State Management

Use existing Bloc/Provider patterns from project rules.

### Suggested Blocs/Cubits

| Feature | State Type |
|---------|------------|
| HomeBloc | Continue learning, schedule, assignments |
| LearningBloc | Courses list, filters |
| CourseDetailBloc | Course info, lessons tree |
| LessonBloc | Lesson content, progress |
| ScheduleBloc | Calendar data, selected date events |
| AchievementBloc | Badges, certificates, stats |
| ProfileBloc | User info, settings |
| NotificationBloc | Notifications list, unread count |
| SearchBloc | Query, results, filters |
| BookmarkBloc | Bookmarked items |

---

## 13. API Integration

Reference existing APIs from `FE_DESIGN_GUIDE.md`:

| Screen | APIs |
|--------|------|
| Home | GET /auth/me, GET /classes, GET /enrollments, GET /livestream |
| Learning | GET /enrollments, GET /courses/:id, GET /lessons/:id |
| Schedule | GET /classes/:id/schedules |
| Achievement | GET /me/badges, GET /me/certificates, GET /me/stats |
| Profile | GET /auth/me, PUT /auth/me, GET /auth/profiles |
| Notifications | GET /notifications |

---

## 14. Phased Implementation

Scope is large. Recommend breaking into phases:

| Phase | Scope | Priority |
|-------|-------|----------|
| 1 | Navigation shell (bottom tab + drawer) + App bar | P0 |
| 2 | Home tab (continue learning, schedule timeline, assignments) | P0 |
| 3 | Learning tab - Course list + Course detail | P0 |
| 4 | Learning tab - Lesson detail (video, docs, quiz) | P0 |
| 5 | Schedule tab (calendar + day detail) | P1 |
| 6 | Achievement tab (badges, certificates, stats) | P1 |
| 7 | Profile tab + Settings | P1 |
| 8 | Additional screens (notifications, search, bookmarks) | P2 |
| 9 | Common components (loading, empty, error states) | P0 (parallel) |

**P0**: Core learning flow - must have for MVP
**P1**: Important but can follow
**P2**: Nice to have, enhance UX

---

## 15. Implementation Notes

1. **Reuse design system**: All colors, typography, spacing from existing theme files
2. **Role colors**: Student uses `RoleColors.studentPrimary` (#2563EB)
3. **Permission-based UI**: Student has no special permissions, follow PERMISSION_BASED_UI.md
4. **Responsive**: Design for mobile-first, standard phone widths (375-428px)
5. **Accessibility**: Minimum touch target 44px, sufficient color contrast
6. **Animation**: Subtle transitions, 200-300ms duration, standard curves
