String contestStatus(dynamic value) => switch ('$value') {
  'DRAFT' => 'Bản nháp',
  'PENDING_REVIEW' => 'Đang duyệt',
  'PUBLISHED' => 'Đã công bố',
  'REJECTED' => 'Cần chỉnh sửa',
  'CANCELLED' => 'Đã hủy',
  _ => '$value',
};
