# Comment Rules

When writing or modifying code in this project:

* Keep comments **short and concise**.
* Comments should explain **why / purpose**, not repeat obvious code behavior.
* Use a natural **English + Vietnamese mix**.
* Prefer English technical keywords and Vietnamese explanation.
* Usually keep comments to **one short line**.
* Do not write long paragraph comments unless the logic is genuinely complex.
* Do not comment obvious declarations, assignments, imports, or standard framework code.
* Keep existing useful comments, but shorten them if they are unnecessarily verbose.

## Preferred style

```dart
// Cache data để tránh call API lại

// Check auth trước khi redirect

// Reset state khi logout

// Listen changes từ provider

// Validate input trước khi submit

// Fetch next page khi scroll cuối list

// Emit loading trước khi call API

// Prevent duplicate request

// Map response sang model

// Fallback về default value
```

## Avoid

```dart
// This function is used to fetch data from the server and then update the state
```

Prefer:

```dart
// Fetch data rồi update state
```

Avoid:

```dart
// Kiểm tra xem người dùng hiện tại đã đăng nhập vào hệ thống hay chưa
```

Prefer:

```dart
// Check user đã login chưa
```

## General principle

Comments should feel like quick notes from a developer to another developer:

```text
English technical term + Vietnamese context
```

Keep them simple, readable, and useful.
