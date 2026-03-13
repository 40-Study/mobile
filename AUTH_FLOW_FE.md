# Tài liệu Luồng Authentication – Hướng dẫn cho Frontend

Tài liệu này mô tả chi tiết các API auth, request/response body và luồng hoạt động để FE tích hợp.

**Base URL:** `/api/auth`

---

## 1. Cách gửi token (Protected routes)

Mọi API **yêu cầu đăng nhập** chấp nhận access token theo **một trong hai cách**:

| Cách | Mô tả |
|------|--------|
| **Header** | `Authorization: Bearer <access_token>` |
| **Cookie** | Cookie tên `accessToken` (backend tự set khi login thành công) |

**Refresh token** dùng để gia hạn session:
- Lấy từ cookie `rfToken`, **hoặc**
- Body JSON: `{ "refresh_token": "<refresh_token>" }`

---

## 2. Danh sách API Auth

### 2.1. API không cần đăng nhập (public)

| Method | Endpoint | Mô tả |
|--------|----------|--------|
| POST | `/api/auth/register/request` | Gửi thông tin đăng ký, nhận OTP qua email |
| POST | `/api/auth/register` | Xác thực OTP và tạo tài khoản |
| POST | `/api/auth/login` | Đăng nhập (có thể multi-step: chọn role → chọn org) |
| POST | `/api/auth/select-profile` | Chọn system role (sau bước login khi có nhiều role) |
| POST | `/api/auth/select-org` | Chọn tổ chức (sau khi chọn role, khi user thuộc nhiều org) |
| POST | `/api/auth/refresh-token` | Đổi access token bằng refresh token |
| POST | `/api/auth/reset-password/request` | Gửi OTP reset mật khẩu qua email |
| POST | `/api/auth/reset-password` | Xác thực OTP và đặt lại mật khẩu |

### 2.2. API cần đăng nhập (gửi access token)

| Method | Endpoint | Mô tả |
|--------|----------|--------|
| POST | `/api/auth/switch-profile` | Đổi system role (đã đăng nhập) |
| POST | `/api/auth/switch-org` | Đổi organization (đã đăng nhập) |
| GET | `/api/auth/me` | Lấy thông tin user hiện tại |
| PUT | `/api/auth/me` | Cập nhật profile (username, phone, date_of_birth) |
| GET | `/api/auth/devices` | Danh sách thiết bị đã đăng nhập |
| POST | `/api/auth/logout` | Đăng xuất thiết bị hiện tại |
| POST | `/api/auth/logout-all` | Đăng xuất tất cả thiết bị |
| PUT | `/api/auth/change-password` | Đổi mật khẩu (khi đã đăng nhập) |

---

## 3. Chi tiết Request/Response theo từng API

### 3.1. Đăng ký (Register)

#### Bước 1: Request đăng ký – `POST /api/auth/register/request`

**Request body:**

| Field | Type | Bắt buộc | Validation | Mô tả |
|-------|------|----------|------------|--------|
| `email` | string | ✅ | email, max 255 | Email đăng ký |
| `password` | string | ✅ | min 8, max 72 | Mật khẩu |
| `confirm_password` | string | ✅ | phải bằng `password` | Xác nhận mật khẩu |
| `user_name` | string | ✅ | min 3, max 100 | Tên đăng nhập (username) |
| `full_name` | string | ❌ | min 2, max 255 | Họ tên đầy đủ |
| `role_ids` | string[] | ❌ | max 10 phần tử, mỗi phần tử là UUID | Danh sách ID system role (STUDENT, TEACHER, PARENT, ORG_OWNER) |

**Ví dụ:**
```json
{
  "email": "student@example.com",
  "password": "SecurePass123!",
  "confirm_password": "SecurePass123!",
  "user_name": "student123",
  "full_name": "Nguyen Van A",
  "role_ids": ["550e8400-e29b-41d4-a716-446655440000"]
}
```

**Response (200):**
```json
{
  "message": "OTP sent to your email. Please verify within 5 minutes."
}
```

**Lưu ý:** OTP hết hạn sau **5 phút**. Nếu sai/trễ FE nên cho user gọi lại `register/request`.

---

#### Bước 2: Xác thực OTP và tạo tài khoản – `POST /api/auth/register`

**Request body:**

| Field | Type | Bắt buộc | Validation | Mô tả |
|-------|------|----------|------------|--------|
| `email` | string | ✅ | email | Cùng email đã gửi ở bước 1 |
| `otp` | string | ✅ | đúng 6 ký tự số | Mã OTP nhận qua email |

**Ví dụ:**
```json
{
  "email": "student@example.com",
  "otp": "123456"
}
```

**Response (201):**
```json
{
  "message": "User registered successfully",
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "student@example.com",
    "user_name": "student123",
    "full_name": "Nguyen Van A",
    "role_ids": ["550e8400-e29b-41d4-a716-446655440000"]
  }
}
```

Sau khi đăng ký thành công, user cần **đăng nhập** (`POST /api/auth/login`) để nhận token.

---

### 3.2. Đăng nhập (Login) – Multi-step

Login có thể **1 bước** (nhận luôn token) hoặc **nhiều bước** (chọn role → chọn org). FE xử lý theo từng response.

#### `POST /api/auth/login`

**Request body:**

| Field | Type | Bắt buộc | Validation | Mô tả |
|-------|------|----------|------------|--------|
| `email` | string | ✅ | email | Email đăng nhập |
| `password` | string | ✅ | min 8 | Mật khẩu |
| `device_info` | object | ✅ | - | Thông tin thiết bị |

**`device_info`:**

| Field | Type | Bắt buộc | Validation | Mô tả |
|-------|------|----------|------------|--------|
| `device_id` | string | ✅ | UUID | ID thiết bị (FE tự generate UUID, lưu localStorage/AsyncStorage) |
| `device_name` | string | ✅ | min 2, max 100 | Tên hiển thị (vd: "iPhone 14 Pro") |
| `os` | string | ✅ | max 50 | Hệ điều hành (vd: "iOS 16.5") |
| `app_version` | string | ❌ | max 50 | Phiên bản app |
| `user_agent` | string | ❌ | max 512 | User-Agent trình duyệt (nếu có) |

**Ví dụ:**
```json
{
  "email": "student@example.com",
  "password": "ResilientPass123!",
  "device_info": {
    "device_id": "550e8400-e29b-41d4-a716-446655440000",
    "device_name": "iPhone 14 Pro",
    "os": "iOS 16.5",
    "app_version": "1.0.0",
    "user_agent": "Mozilla/5.0..."
  }
}
```

**Response (200) – Các trường hợp:**

**Trường hợp 1: Đăng nhập xong ngay (1 role, 0 org hoặc 1 org auto)**  
`data.completed === true` → Có token, có user, có role/org. Chuyển vào app.

```json
{
  "message": "Login successful",
  "data": {
    "completed": true,
    "access_token": "eyJhbGc...",
    "refresh_token": "eyJhbGc...",
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "username": "student123",
      "email": "student@example.com",
      "phone": null,
      "avatar_url": null,
      "date_of_birth": null,
      "is_active": true,
      "created_at": "2023-01-01T00:00:00Z"
    },
    "active_role": {
      "id": "uuid",
      "name": "STUDENT"
    },
    "active_org": null,
    "entry_context": {
      "primary_role": "STUDENT",
      "requires_setup": false,
      "setup_endpoint": ""
    },
    "current_device": {
      "device_id": "uuid",
      "device_name": "iPhone 14 Pro",
      "user_agent": "...",
      "logged_in_at": "2024-01-01T00:00:00Z"
    }
  }
}
```

**Trường hợp 2: Cần chọn role (nhiều system role)**  
`data.completed === false` và có `data.system_roles`, có `data.session_token`.  
→ Hiển thị màn chọn role, sau đó gọi `POST /api/auth/select-profile` với `session_token` + `system_role_id`.

```json
{
  "message": "Login successful",
  "data": {
    "completed": false,
    "session_token": "uuid-session-token",
    "system_roles": [
      { "id": "uuid-1", "name": "STUDENT" },
      { "id": "uuid-2", "name": "TEACHER" }
    ]
  }
}
```

**Trường hợp 3: Đã chọn role, cần chọn org (nhiều tổ chức)**  
`data.completed === false`, `data.requires_org_selection === true`, có `data.organizations`, có `data.session_token`.  
→ Hiển thị màn chọn tổ chức (hoặc “Độc lập”), sau đó gọi `POST /api/auth/select-org` với `session_token` + `organization_id` (để “Độc lập” thì gửi `organization_id` rỗng hoặc không gửi).

```json
{
  "message": "Login successful",
  "data": {
    "completed": false,
    "session_token": "uuid-session-token",
    "requires_org_selection": true,
    "organizations": [
      { "id": "org-uuid-1", "name": "Trường THPT ABC" },
      { "id": "org-uuid-2", "name": "Trung tâm XYZ" }
    ],
    "active_role": { "id": "uuid", "name": "TEACHER" }
  }
}
```

**Cấu trúc chung `data` (Login response):**

| Field | Type | Khi nào có | Mô tả |
|-------|------|------------|--------|
| `completed` | boolean | Luôn | `true` = đã có token, vào app; `false` = cần gọi thêm select-profile hoặc select-org |
| `session_token` | string | Khi `completed === false` | Dùng cho select-profile / select-org, hết hạn 5 phút |
| `system_roles` | array | Khi cần chọn role | `{ id, name }` (STUDENT, TEACHER, PARENT, ORG_OWNER) |
| `requires_org_selection` | boolean | Khi cần chọn org | `true` → gọi select-org |
| `organizations` | array | Khi requires_org_selection | `{ id, name }`; chọn “Độc lập” = không gửi org khi gọi select-org |
| `access_token` | string | Khi completed | JWT access token |
| `refresh_token` | string | Khi completed | JWT refresh token |
| `user` | object | Khi completed | Thông tin user (xem bảng User bên dưới) |
| `active_role` | object | Khi completed hoặc sau chọn role | `{ id, name }` |
| `active_org` | object \| null | Khi completed | `{ id, name }` hoặc null (Độc lập) |
| `entry_context` | object | Khi completed | Điều hướng sau login (xem bảng Entry context) |
| `current_device` | object | Khi completed | Thông tin thiết bị hiện tại |

**User object:**

| Field | Type | Mô tả |
|-------|------|--------|
| `id` | string (UUID) | ID user |
| `username` | string | Tên đăng nhập |
| `email` | string | Email |
| `phone` | string \| null | Số điện thoại |
| `avatar_url` | string \| null | URL avatar |
| `date_of_birth` | string \| null | Ngày sinh (YYYY-MM-DD) |
| `is_active` | boolean | Trạng thái kích hoạt |
| `created_at` | string | ISO 8601 |

**Entry context (điều hướng sau login):**

| Field | Type | Mô tả |
|-------|------|--------|
| `primary_role` | string | Role ưu tiên (STUDENT, TEACHER, PARENT, ORG_OWNER) |
| `requires_setup` | boolean | Có cần setup bổ sung không (vd: thêm con, thêm trường) |
| `setup_endpoint` | string | API cần gọi / route cần đi khi cần setup (vd: `/me/children`, `/me/organizations`) |

---

### 3.3. Chọn role (sau login) – `POST /api/auth/select-profile`

Dùng khi login trả về `completed: false` và có `system_roles` + `session_token`.

**Request body:**

| Field | Type | Bắt buộc | Validation | Mô tả |
|-------|------|----------|------------|--------|
| `session_token` | string | ✅ | - | Session token từ response login |
| `system_role_id` | string | ✅ | UUID | ID role user chọn (trong `system_roles`) |

**Ví dụ:**
```json
{
  "session_token": "uuid-session-token",
  "system_role_id": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Response (200):**

- Nếu user **có org** → `data.completed === false`, `data.requires_org_selection === true`, có `data.organizations` và `data.session_token` (có thể dùng lại session_token cũ).  
  → FE chuyển sang màn chọn org và gọi `POST /api/auth/select-org`.
- Nếu user **không có org** → `data.completed === true`, có `access_token`, `refresh_token`, `user`, `active_role`, `active_org: null`, `entry_context`, `current_device`.  
  → Lưu token và chuyển vào app.

Cấu trúc `data` tương tự phần Login khi completed (cùng kiểu với Select Profile Response).

---

### 3.4. Chọn tổ chức (sau khi chọn role) – `POST /api/auth/select-org`

Dùng khi select-profile trả về `requires_org_selection === true` (hoặc login trả về bước “chọn org”).

**Request body:**

| Field | Type | Bắt buộc | Validation | Mô tả |
|-------|------|----------|------------|--------|
| `session_token` | string | ✅ | - | Session token từ login/select-profile |
| `organization_id` | string | ❌ | UUID nếu gửi | ID org user chọn; **để trống hoặc không gửi = chế độ “Độc lập”** (active_org = null) |

**Ví dụ – Chọn org:**
```json
{
  "session_token": "uuid-session-token",
  "organization_id": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Ví dụ – Chế độ Độc lập:**
```json
{
  "session_token": "uuid-session-token"
}
```
hoặc `"organization_id": ""`

**Response (200):** Luôn `data.completed === true`, có `access_token`, `refresh_token`, `user`, `active_role`, `active_org` (hoặc null), `entry_context`, `current_device`.  
→ Lưu token và chuyển vào app.

---

### 3.5. Refresh token – `POST /api/auth/refresh-token`

**Request:**  
- Cookie `rfToken` (ưu tiên), **hoặc**  
- Body: `{ "refresh_token": "<refresh_token>" }`

**Response (200):**
```json
{
  "message": "Refresh token successfully",
  "data": {
    "access_token": "eyJhbGc...",
    "refresh_token": "eyJhbGc..."
  }
}
```

Backend có thể set lại cookie `accessToken` và `rfToken`. FE nên lưu token mới (nếu dùng header) và dùng access token mới cho các request tiếp theo.

---

### 3.6. Reset mật khẩu (quên mật khẩu)

#### Bước 1: Yêu cầu OTP – `POST /api/auth/reset-password/request`

**Request body:**

| Field | Type | Bắt buộc | Validation | Mô tả |
|-------|------|----------|------------|--------|
| `email` | string | ✅ | email | Email tài khoản cần reset |

**Response (200):** Luôn trả thành công (không lộ email có tồn tại hay không):
```json
{
  "message": "OTP has been sent"
}
```

OTP hết hạn **5 phút**. Sai OTP quá 5 lần phải gửi lại request mới.

#### Bước 2: Đặt lại mật khẩu – `POST /api/auth/reset-password`

**Request body:**

| Field | Type | Bắt buộc | Validation | Mô tả |
|-------|------|----------|------------|--------|
| `email` | string | ✅ | email | Email đã gửi ở bước 1 |
| `otp` | string | ✅ | 6 ký tự số | Mã OTP |
| `new_password` | string | ✅ | min 8, max 72 | Mật khẩu mới |
| `confirm_password` | string | ✅ | phải bằng `new_password` | Xác nhận mật khẩu mới |

**Response (200):**
```json
{
  "message": "Password reset successfully"
}
```

---

### 3.7. Các API cần đăng nhập (dùng access token)

#### Đổi role (khi đã đăng nhập) – `POST /api/auth/switch-profile`

**Header:** `Authorization: Bearer <access_token>` (hoặc cookie)

**Request body:**

| Field | Type | Bắt buộc | Validation | Mô tả |
|-------|------|----------|------------|--------|
| `system_role_id` | string | ✅ | UUID | ID system role muốn chuyển sang |

**Response:** Giống luồng select-profile: có thể `completed: false` + `requires_org_selection` (cần gọi tiếp `switch-org`) hoặc `completed: true` với token mới. FE cập nhật token và context (role/org) sau khi completed.

---

#### Đổi tổ chức – `POST /api/auth/switch-org`

**Header:** `Authorization: Bearer <access_token>` (hoặc cookie)

**Request body:**

| Field | Type | Bắt buộc | Validation | Mô tả |
|-------|------|----------|------------|--------|
| `organization_id` | string | ❌ | UUID nếu gửi | ID org; **rỗng/không gửi = Độc lập** |

**Response (200):** `data` có `access_token`, `refresh_token`, `user`, `active_role`, `active_org`, v.v. FE cập nhật token và context.

---

#### Lấy thông tin user – `GET /api/auth/me`

**Header:** `Authorization: Bearer <access_token>` (hoặc cookie)

**Response (200):**
```json
{
  "message": "Get user info successfully",
  "data": {
    "id": "uuid",
    "username": "student123",
    "email": "student@example.com",
    "phone": null,
    "avatar_url": null,
    "date_of_birth": null,
    "is_active": true,
    "created_at": "2023-01-01T00:00:00Z"
  }
}
```

---

#### Cập nhật profile – `PUT /api/auth/me`

**Request body (tất cả optional – partial update):**

| Field | Type | Validation | Mô tả |
|-------|------|-------------|--------|
| `username` | string | alphanum, min 3, max 30 | Tên đăng nhập |
| `phone` | string | E.164 | Số điện thoại |
| `date_of_birth` | string | YYYY-MM-DD | Ngày sinh |

**Response (200):** Trả về object user (cùng format với GET /me).

---

#### Danh sách thiết bị – `GET /api/auth/devices`

**Response (200):**
```json
{
  "message": "Get devices successfully",
  "data": {
    "devices": [
      {
        "device_id": "uuid",
        "device_name": "iPhone 14 Pro",
        "user_agent": "...",
        "logged_in_at": "2024-01-01T00:00:00Z",
        "is_current": true
      }
    ],
    "total": 1
  }
}
```

`is_current: true` = thiết bị đang gọi request này.

---

#### Đăng xuất thiết bị hiện tại – `POST /api/auth/logout`

**Header:** Access token của thiết bị cần logout.

**Response (200):**
```json
{
  "message": "Logout successfully"
}
```

---

#### Đăng xuất tất cả thiết bị – `POST /api/auth/logout-all`

**Header:** Access token.

**Response (200):**
```json
{
  "message": "Logout on all devices successfully"
}
```

Sau khi gọi, **mọi** access/refresh token của user đó bị vô hiệu; các thiết bị khác khi gọi API sẽ nhận 401 và cần đăng nhập lại.

---

#### Đổi mật khẩu (khi đã đăng nhập) – `PUT /api/auth/change-password`

**Request body:**

| Field | Type | Bắt buộc | Validation | Mô tả |
|-------|------|----------|------------|--------|
| `old_password` | string | ✅ | min 8, max 72 | Mật khẩu hiện tại |
| `new_password` | string | ✅ | min 8, max 72, khác old, chứa ít nhất 1 ký tự đặc biệt !@#$%^&*() | Mật khẩu mới |
| `confirm_password` | string | ✅ | phải bằng new_password | Xác nhận mật khẩu mới |
| `device_info` | object | ✅ | Giống login | Thông tin thiết bị hiện tại |
| `revoke_others` | boolean | ❌ | - | `true` = đăng xuất tất cả thiết bị khác sau khi đổi mật khẩu |

**Response (200):**
```json
{
  "message": "Change password successfully"
}
```

---

## 4. Luồng hoạt động tổng quan

### 4.1. Luồng đăng ký

```
[FE] Gửi form đăng ký (email, password, user_name, ...)
  → POST /api/auth/register/request
  ← 200 "OTP sent to your email..."

[FE] User nhập OTP từ email
  → POST /api/auth/register  { email, otp }
  ← 201 { data: { id, email, user_name, full_name, role_ids } }

[FE] Chuyển user sang màn Login (hoặc tự động gọi login).
```

### 4.2. Luồng đăng nhập (multi-step)

```
[FE] Gửi email + password + device_info
  → POST /api/auth/login

Nếu data.completed === true:
  → Lưu access_token, refresh_token; lưu user, active_role, active_org, entry_context
  → Điều hướng vào app (có thể dùng entry_context.primary_role, requires_setup, setup_endpoint)
  → KẾT THÚC

Nếu data.completed === false và có data.system_roles:
  → Hiển thị màn chọn role (data.system_roles)
  → User chọn 1 role
  → POST /api/auth/select-profile  { session_token: data.session_token, system_role_id }
  → Xử lý response select-profile (xem dưới)

Nếu data.completed === false và data.requires_org_selection:
  → Hiển thị màn chọn org (data.organizations + option "Độc lập")
  → User chọn 1 org hoặc "Độc lập"
  → POST /api/auth/select-org  { session_token, organization_id? }
  ← data.completed === true, có token + user + role + org
  → Lưu token, vào app
  → KẾT THÚC
```

**Xử lý response select-profile:**

- Nếu `data.completed === true` → Lưu token, vào app, kết thúc.
- Nếu `data.requires_org_selection === true` → Hiển thị chọn org, gọi select-org như trên.

### 4.3. Luồng refresh token

Khi access token hết hạn (401), FE gọi:

```
  → POST /api/auth/refresh-token  (cookie rfToken hoặc body refresh_token)
  ← 200 { data: { access_token, refresh_token } }
  → Lưu token mới, retry request ban đầu
```

Nếu refresh trả 401 → Coi như hết phiên, chuyển user về màn login.

### 4.4. Luồng quên mật khẩu

```
[FE] User nhập email
  → POST /api/auth/reset-password/request  { email }
  ← 200 "OTP has been sent"

[FE] User nhập OTP + mật khẩu mới
  → POST /api/auth/reset-password  { email, otp, new_password, confirm_password }
  ← 200 "Password reset successfully"
  → Chuyển về màn Login
```

### 4.5. Cookie backend set khi login/refresh

Khi login hoặc select-org/select-profile/switch-org trả về token, backend có thể set cookie:

| Cookie | Mô tả | Thời hạn (tham khảo) |
|--------|--------|------------------------|
| `accessToken` | JWT access token | ~15 phút |
| `rfToken` | JWT refresh token | ~24 giờ |

FE có thể chỉ dùng cookie (không cần lưu token vào state/localStorage) nếu mọi request gửi cookie; nếu dùng SPA + API riêng thì thường vẫn lưu token và gửi header `Authorization: Bearer <access_token>`.

---

## 5. Lỗi thường gặp

| HTTP | message / error | Cách xử lý FE |
|------|------------------|----------------|
| 400 | Validation failed, errors: [...] | Hiển thị lỗi theo từng field trong `errors` |
| 400 | Request register failed / Register failed | Hiển thị `error` (vd: email đã tồn tại, OTP sai) |
| 401 | Login failed / Invalid email or password | Thông báo sai email hoặc mật khẩu |
| 401 | Missing access token / Invalid or expired token | Chuyển về login hoặc gọi refresh-token |
| 401 | User session not found / All sessions revoked | Đăng xuất local, chuyển về màn login |
| 401 | Refresh token failed / ... | Xóa token, chuyển về login |

---

## 6. Tóm tắt trường quan trọng cho FE

- **Login request:** `email`, `password`, `device_info` (trong đó `device_id` UUID, `device_name`, `os` bắt buộc).
- **Login response:** Luôn kiểm tra `data.completed`; nếu `false` thì dựa vào `session_token`, `system_roles`, `requires_org_selection`, `organizations` để gọi tiếp select-profile / select-org.
- **Sau khi completed:** Lưu `access_token`, `refresh_token`, `user`, `active_role`, `active_org`, `entry_context`; dùng `entry_context` để điều hướng/setup.
- **Protected request:** Gửi `Authorization: Bearer <access_token>` hoặc cookie `accessToken`.
- **Refresh:** Gửi cookie `rfToken` hoặc body `refresh_token`; cập nhật token mới sau khi thành công.

Nếu cần thêm ví dụ cho từng màn hình (Register, Login, Chọn role, Chọn org, Profile, Đổi mật khẩu), có thể mở rộng từ tài liệu này theo từng flow cụ thể.
