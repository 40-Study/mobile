/// Backend pricing contract: discounts are optional, positive and below price.
String? teacherCoursePriceError(String value, {double? below}) {
  final number = double.tryParse(value.trim());
  if (number == null || !number.isFinite || number < 0) {
    return 'Nhập số tiền hợp lệ, không âm';
  }
  if (below != null && (number <= 0 || number >= below)) {
    return 'Giá giảm phải lớn hơn 0 và nhỏ hơn giá gốc';
  }
  return null;
}

String teacherCourseStatus(dynamic value) =>
    const {
      'draft': 'Nháp',
      'pending_review': 'Chờ duyệt',
      'published': 'Đã xuất bản',
      'rejected': 'Bị từ chối',
      'archived': 'Lưu trữ',
    }[value] ??
    '$value';

bool teacherCourseWritable(Map<String, dynamic> course) =>
    course['status'] != 'pending_review' && course['status'] != 'archived';

Map<String, dynamic> teacherCourseReorder(List<Map<String, dynamic>> items) => {
  'items': [
    for (var index = 0; index < items.length; index++)
      {'id': items[index]['id'], 'display_order': index},
  ],
};
