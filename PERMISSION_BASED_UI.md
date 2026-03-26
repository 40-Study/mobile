# Permission-Based UI - Hướng dẫn hiển thị theo quyền

## Tổng quan hệ thống Permission

### Cấu trúc

```
User
├── UserSystemRole (STUDENT, TEACHER, PARENT, ORG_OWNER, SYSTEM_ADMIN)
│   └── SystemRolePermission
│       └── Permission
│
└── UserOrganizationRole (role trong tổ chức cụ thể)
    └── RolePermission
        └── Permission
```

### API lấy Permissions

```
GET /me/system-roles                      → Roles của tôi
GET /system-roles/:id/permissions         → Permissions của 1 role
GET /auth/profiles                        → Active role hiện tại
```

**Flow lấy permissions:**
```
1. Login → nhận access_token (chứa active_role)
2. GET /me/system-roles → lấy danh sách roles
3. GET /system-roles/:roleId/permissions → lấy permissions của role đang active
4. Lưu permissions vào state/context
5. Render UI dựa trên permissions
```

---

## Danh sách Permissions

### Permissions theo nhóm chức năng

| Nhóm | Permission | Mô tả |
|------|------------|-------|
| **Khóa học** | `COURSES_CREATE` | Tạo khóa học mới |
| | `COURSES_UPDATE_OWN` | Sửa khóa học của mình |
| | `COURSES_DELETE_OWN` | Xóa khóa học của mình |
| | `COURSES_DELETE_ORG` | Xóa khóa học của tổ chức |
| | `COURSES_DELETE_ALL` | Xóa bất kỳ khóa học nào |
| | `COURSES_APPROVE_OWN_ORG` | Duyệt khóa học trong tổ chức |
| | `COURSES_APPROVE_ALL` | Duyệt tất cả khóa học |
| **Bài học** | `LESSONS_MANAGE` | Quản lý bài học |
| **Danh mục** | `CATEGORIES_SYSTEM_MANAGE` | Quản lý danh mục hệ thống |
| | `ORG_CATEGORIES_MANAGE` | Quản lý danh mục tổ chức |
| **Tổ chức** | `ORG_CREATE` | Tạo tổ chức mới |
| | `ORG_DELETE` | Xóa tổ chức |
| | `ORG_MEMBERS_MANAGE` | Quản lý thành viên |
| | `ORG_ROLES_MANAGE` | Quản lý roles trong tổ chức |
| **Báo cáo** | `REPORTS_VIEW_ORG` | Xem báo cáo tổ chức |
| | `DASHBOARD_VIEW_GLOBAL` | Xem dashboard hệ thống |
| **Người dùng** | `USERS_VIEW_ALL` | Xem tất cả users |
| | `USERS_BAN` | Khóa/mở khóa user |
| **Giáo viên** | `TEACHER_PROFILE_UPDATE` | Cập nhật hồ sơ GV |
| | `APPLICATION_VIEW_STATUS` | Xem trạng thái đăng ký GV |
| **Theo dõi** | `TRACKING_VIEW_ORG_STUDENTS` | Xem tiến độ học sinh |
| **Hệ thống** | `ROLES_MANAGE_SYSTEM` | Quản lý roles hệ thống |
| | `SYSTEM_SETTINGS_MANAGE` | Cài đặt hệ thống |

---

## Permissions theo Role

### STUDENT (Học sinh)
```
❌ Không có permission đặc biệt
```
**UI hiển thị:**
- Xem khóa học (public)
- Đăng ký học
- Xem lớp học của mình
- Tham gia livestream
- Nộp bài tập

---

### PARENT (Phụ huynh)
```
❌ Không có permission đặc biệt
```
**UI hiển thị:**
- Xem danh sách con
- Xem điểm danh của con
- Xem tiến độ học tập của con

---

### TEACHER (Giáo viên)
```
✓ COURSES_CREATE
✓ COURSES_UPDATE_OWN
✓ COURSES_DELETE_OWN
✓ LESSONS_MANAGE
✓ ORG_CREATE
```
**UI hiển thị:**
- Tạo khóa học mới
- Chỉnh sửa khóa học của mình
- Xóa khóa học của mình
- Quản lý bài học (video, tài liệu, quiz)
- Tạo tổ chức mới

---

### ORG_OWNER (Chủ tổ chức)
```
✓ COURSES_APPROVE_OWN_ORG
✓ COURSES_DELETE_ORG
✓ ORG_CATEGORIES_MANAGE
✓ ORG_MEMBERS_MANAGE
✓ ORG_ROLES_MANAGE
✓ REPORTS_VIEW_ORG
✓ TRACKING_VIEW_ORG_STUDENTS
```
**UI hiển thị:**
- Duyệt khóa học của giáo viên trong tổ chức
- Xóa khóa học của tổ chức
- Quản lý danh mục nội bộ
- Mời/xóa thành viên
- Tạo/sửa roles nội bộ
- Xem báo cáo doanh thu
- Theo dõi tiến độ học sinh

---

### SYSTEM_ADMIN (Admin hệ thống)
```
✓ TẤT CẢ PERMISSIONS
```
**UI hiển thị:**
- Full access tất cả chức năng

---

## Cách FE hiển thị UI theo Permission

### 1. Lưu permissions vào Context/Store

```typescript
// types.ts
interface User {
  id: string;
  email: string;
  activeRole: string;
  permissions: string[];
}

// AuthContext.tsx
const AuthContext = createContext<{
  user: User | null;
  hasPermission: (permission: string) => boolean;
}>({
  user: null,
  hasPermission: () => false
});

function AuthProvider({ children }) {
  const [user, setUser] = useState<User | null>(null);

  const hasPermission = (permission: string) => {
    return user?.permissions?.includes(permission) ?? false;
  };

  // Load user & permissions on login
  useEffect(() => {
    async function loadPermissions() {
      const profiles = await api.get('/auth/profiles');
      const activeProfile = profiles.find(p => p.isActive);

      const permissions = await api.get(
        `/system-roles/${activeProfile.systemRoleId}/permissions`
      );

      setUser({
        ...userData,
        activeRole: activeProfile.roleName,
        permissions: permissions.map(p => p.name)
      });
    }
    loadPermissions();
  }, []);

  return (
    <AuthContext.Provider value={{ user, hasPermission }}>
      {children}
    </AuthContext.Provider>
  );
}
```

### 2. Component kiểm tra Permission

```tsx
// PermissionGate.tsx
interface PermissionGateProps {
  permission: string | string[];
  children: React.ReactNode;
  fallback?: React.ReactNode;
}

function PermissionGate({ permission, children, fallback = null }: PermissionGateProps) {
  const { hasPermission } = useAuth();

  const permissions = Array.isArray(permission) ? permission : [permission];
  const hasAccess = permissions.some(p => hasPermission(p));

  return hasAccess ? <>{children}</> : <>{fallback}</>;
}

// Sử dụng
<PermissionGate permission="COURSES_CREATE">
  <Button>+ Tạo khóa học</Button>
</PermissionGate>

<PermissionGate permission={["COURSES_DELETE_OWN", "COURSES_DELETE_ALL"]}>
  <Button variant="danger">Xóa khóa học</Button>
</PermissionGate>
```

### 3. Hook kiểm tra Permission

```tsx
// usePermission.ts
function usePermission(permission: string | string[]) {
  const { hasPermission } = useAuth();

  const permissions = Array.isArray(permission) ? permission : [permission];
  return permissions.some(p => hasPermission(p));
}

// Sử dụng
function CourseCard({ course }) {
  const canEdit = usePermission("COURSES_UPDATE_OWN");
  const canDelete = usePermission(["COURSES_DELETE_OWN", "COURSES_DELETE_ALL"]);

  return (
    <Card>
      <h3>{course.title}</h3>
      {canEdit && <Button>Chỉnh sửa</Button>}
      {canDelete && <Button variant="danger">Xóa</Button>}
    </Card>
  );
}
```

---

## Wireframe theo Permission

### Trang Quản lý Khóa học

#### TEACHER (có COURSES_CREATE, COURSES_UPDATE_OWN, COURSES_DELETE_OWN)

```
┌─────────────────────────────────────────────────────────────────────┐
│  KHÓA HỌC CỦA TÔI                                [+ Tạo khóa học]  │
│                                                   ↑ COURSES_CREATE  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  📖 Python Cơ bản                            ● Đã xuất bản  │   │
│  │  ⭐ 4.8 (120)  │  👨‍🎓 450 học viên  │  💰 500,000đ          │   │
│  │                                                             │   │
│  │  [Chỉnh sửa] [Quản lý bài học] [Xóa]                       │   │
│  │   ↑ COURSES_UPDATE_OWN  ↑ LESSONS_MANAGE  ↑ COURSES_DELETE_OWN│   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

#### ORG_OWNER (có thêm COURSES_APPROVE_OWN_ORG, COURSES_DELETE_ORG)

```
┌─────────────────────────────────────────────────────────────────────┐
│  KHÓA HỌC TỔ CHỨC                    [+ Tạo khóa học]              │
│                                                                     │
│  [Tất cả] [Chờ duyệt (3)] [Đã xuất bản] [Nháp]                     │
│            ↑ COURSES_APPROVE_OWN_ORG                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  CHỜ DUYỆT                                                          │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  📖 React Nâng cao                          ○ Chờ duyệt     │   │
│  │  👨‍🏫 GV: Nguyễn Văn A  │  Gửi duyệt: 23/03/2024              │   │
│  │                                                             │   │
│  │  [Xem trước] [✓ Duyệt] [✗ Từ chối] [Xóa]                   │   │
│  │              ↑ COURSES_APPROVE_OWN_ORG     ↑ COURSES_DELETE_ORG│   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

#### STUDENT (không có permission khóa học)

```
┌─────────────────────────────────────────────────────────────────────┐
│  KHÓA HỌC CỦA TÔI                                                   │
│  (Không có nút "Tạo khóa học")                                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │  📖 Python Cơ bản                                           │   │
│  │  Tiến độ: ████████░░ 75%                                    │   │
│  │                                                             │   │
│  │  [Tiếp tục học]                                            │   │
│  │  (Không có nút Chỉnh sửa, Xóa)                              │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

### Sidebar Navigation theo Role

#### STUDENT

```
┌──────────────────────┐
│  📊 Dashboard        │
│  📚 Lớp học của tôi  │
│  📖 Khóa học         │
│  📅 Lịch học         │
│  📝 Bài tập          │
│  ───────────────────  │
│  ⚙️ Cài đặt          │
└──────────────────────┘
```

#### TEACHER

```
┌──────────────────────┐
│  📊 Dashboard        │
│  📚 Lớp học          │
│  📖 Khóa học của tôi │ ← COURSES_CREATE
│  📹 Livestream       │
│  📝 Bài tập & Chấm   │
│  ───────────────────  │
│  👤 Hồ sơ chuyên môn │ ← TEACHER_PROFILE_UPDATE
│  ⚙️ Cài đặt          │
└──────────────────────┘
```

#### ORG_OWNER

```
┌──────────────────────┐
│  📊 Dashboard        │
│  📚 Quản lý lớp      │
│  📖 Quản lý khóa học │
│  ✓  Duyệt khóa học   │ ← COURSES_APPROVE_OWN_ORG
│  ───────────────────  │
│  👥 Thành viên       │ ← ORG_MEMBERS_MANAGE
│  🏷️ Danh mục         │ ← ORG_CATEGORIES_MANAGE
│  👔 Vai trò          │ ← ORG_ROLES_MANAGE
│  📈 Báo cáo          │ ← REPORTS_VIEW_ORG
│  📊 Theo dõi HS      │ ← TRACKING_VIEW_ORG_STUDENTS
│  ───────────────────  │
│  ⚙️ Cài đặt          │
└──────────────────────┘
```

#### SYSTEM_ADMIN

```
┌──────────────────────┐
│  📊 Dashboard Global │ ← DASHBOARD_VIEW_GLOBAL
│  ───────────────────  │
│  👥 Người dùng       │ ← USERS_VIEW_ALL
│  🏢 Tổ chức          │ ← ORG_CREATE, ORG_DELETE
│  📖 Tất cả khóa học  │ ← COURSES_APPROVE_ALL
│  🏷️ Danh mục hệ thống│ ← CATEGORIES_SYSTEM_MANAGE
│  ───────────────────  │
│  🔑 Roles & Perms    │ ← ROLES_MANAGE_SYSTEM
│  ⚙️ Cài đặt hệ thống │ ← SYSTEM_SETTINGS_MANAGE
│  📝 Duyệt hồ sơ GV   │ ← APPLICATION_VIEW_STATUS
│  🚫 Quản lý vi phạm  │ ← USERS_BAN
└──────────────────────┘
```

---

### PARENT

```
┌──────────────────────┐
│  📊 Dashboard        │
│  👶 Con của tôi      │
│  📅 Lịch học con     │
│  📊 Điểm danh        │
│  📈 Kết quả học tập  │
│  ───────────────────  │
│  ⚙️ Cài đặt          │
└──────────────────────┘
```

---

## Ma trận Permission - UI Element

| UI Element | Permission cần | STUDENT | TEACHER | ORG_OWNER | ADMIN |
|------------|----------------|---------|---------|-----------|-------|
| Nút "Tạo khóa học" | `COURSES_CREATE` | ❌ | ✅ | ✅ | ✅ |
| Nút "Chỉnh sửa khóa học" | `COURSES_UPDATE_OWN` | ❌ | ✅ | ✅ | ✅ |
| Nút "Xóa khóa học mình" | `COURSES_DELETE_OWN` | ❌ | ✅ | ✅ | ✅ |
| Nút "Xóa khóa học tổ chức" | `COURSES_DELETE_ORG` | ❌ | ❌ | ✅ | ✅ |
| Nút "Xóa bất kỳ khóa học" | `COURSES_DELETE_ALL` | ❌ | ❌ | ❌ | ✅ |
| Tab "Chờ duyệt" | `COURSES_APPROVE_*` | ❌ | ❌ | ✅ | ✅ |
| Nút "Duyệt khóa học" | `COURSES_APPROVE_*` | ❌ | ❌ | ✅ | ✅ |
| Menu "Quản lý bài học" | `LESSONS_MANAGE` | ❌ | ✅ | ✅ | ✅ |
| Menu "Thành viên tổ chức" | `ORG_MEMBERS_MANAGE` | ❌ | ❌ | ✅ | ✅ |
| Menu "Báo cáo doanh thu" | `REPORTS_VIEW_ORG` | ❌ | ❌ | ✅ | ✅ |
| Menu "Dashboard hệ thống" | `DASHBOARD_VIEW_GLOBAL` | ❌ | ❌ | ❌ | ✅ |
| Menu "Quản lý users" | `USERS_VIEW_ALL` | ❌ | ❌ | ❌ | ✅ |
| Nút "Ban user" | `USERS_BAN` | ❌ | ❌ | ❌ | ✅ |
| Menu "Cài đặt hệ thống" | `SYSTEM_SETTINGS_MANAGE` | ❌ | ❌ | ❌ | ✅ |

---

## API cần phát triển thêm

### 1. Lấy permissions của user hiện tại

```
GET /me/permissions
Authorization: Bearer <token>
```

**Response:**
```json
{
  "permissions": [
    "COURSES_CREATE",
    "COURSES_UPDATE_OWN",
    "COURSES_DELETE_OWN",
    "LESSONS_MANAGE"
  ]
}
```

### 2. Kiểm tra permission (batch)

```
POST /me/permissions/check
Authorization: Bearer <token>

{
  "permissions": ["COURSES_CREATE", "COURSES_DELETE_ALL"]
}
```

**Response:**
```json
{
  "results": {
    "COURSES_CREATE": true,
    "COURSES_DELETE_ALL": false
  }
}
```

---

## Lưu ý khi implement

1. **Backend vẫn phải validate** - FE ẩn UI nhưng user có thể gọi API trực tiếp
2. **Cache permissions** - Không gọi API mỗi lần render
3. **Refresh khi switch profile** - Permissions thay đổi khi đổi role
4. **Loading state** - Hiển thị skeleton khi đang load permissions
5. **Fallback UI** - Hiển thị thông báo "Không có quyền" thay vì blank
