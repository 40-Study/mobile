// Bật dữ liệu mẫu (preview/mock) chỉ ở ENV=dev và không phải release build.
// Override bằng --dart-define=PREVIEW_DATA=true (vd QA cần demo)
const bool kPreviewDataEnabled = bool.fromEnvironment(
  'PREVIEW_DATA',
  defaultValue:
      String.fromEnvironment('ENV', defaultValue: 'dev') == 'dev' &&
      !bool.fromEnvironment('dart.vm.product'),
);
