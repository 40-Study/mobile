import 'package:flutter/material.dart';
import 'package:study/features/parent/data/models/family_scope_child.dart';
import 'package:study/features/parent/data/models/parent_homework_model.dart';
import 'package:study/features/parent/presentation/home/widgets/family_scope_selector.dart';
import 'package:study/features/parent/presentation/learning/homework/parent_homework_detail_screen.dart';
import 'package:study/features/parent/presentation/learning/homework/widgets/graded_homework_summary_card.dart';
import 'package:study/features/parent/presentation/learning/homework/widgets/homework_empty_all_clear_card.dart';
import 'package:study/features/parent/presentation/learning/homework/widgets/homework_filter_bar.dart';
import 'package:study/features/parent/presentation/learning/homework/widgets/homework_item_card.dart';
import 'package:study/features/parent/presentation/learning/homework/widgets/urgent_homework_banner.dart';
import 'package:study/features/parent/repository/parent_learning_repository.dart';
import 'package:study/features/parent/repository/parent_learning_repository_impl.dart';

/// Màn hình Danh sách Bài tập về nhà dành cho phụ huynh (View-only)
class ParentHomeworkScreen extends StatefulWidget {
  const ParentHomeworkScreen({
    super.key,
    this.initialChildId,
    this.initialFilterKey = 'all',
    this.repository,
  });

  final String? initialChildId;
  final String initialFilterKey;
  final ParentLearningRepository? repository;

  @override
  State<ParentHomeworkScreen> createState() => _ParentHomeworkScreenState();
}

class _ParentHomeworkScreenState extends State<ParentHomeworkScreen> {
  late final ParentLearningRepository _repo;

  bool _isLoading = true;
  List<FamilyScopeChild> _children = [];
  String? _selectedChildId;

  String _currentFilterKey = 'all';
  List<ParentHomeworkItem> _allHomework = [];
  ParentGradedSummaryModel? _gradedSummary;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? ParentLearningRepositoryImpl();
    _currentFilterKey = widget.initialFilterKey;
    _selectedChildId = widget.initialChildId;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final children = await _repo.getChildren();
      if (!mounted) return;

      _children = children;
      if (_selectedChildId == null && children.isNotEmpty) {
        _selectedChildId = children.first.id;
      }

      await _fetchHomeworkData();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchHomeworkData() async {
    final childId = _selectedChildId ?? '';
    final homeworkList = await _repo.getHomeworkList(childId);
    final summary = await _repo.getGradedSummary(childId);

    if (!mounted) return;
    setState(() {
      _allHomework = homeworkList;
      _gradedSummary = summary;
    });
  }

  void _onChildChanged(String? childId) {
    if (childId == null || childId == _selectedChildId) return;
    setState(() {
      _selectedChildId = childId;
      _isLoading = true;
    });
    _fetchHomeworkData().whenComplete(() {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  void _handleFilterChanged(String filterKey) {
    setState(() {
      _currentFilterKey = filterKey;
    });
  }

  void _navigateToDetail(String homeworkId) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => ParentHomeworkDetailScreen(
          homeworkId: homeworkId,
          childId: _selectedChildId,
          repository: _repo,
        ),
      ),
    );
  }

  void _showRemindNotification(ParentHomeworkItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Đã gửi thông báo nhắc con hoàn thành bài: ${item.title}',
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<ParentHomeworkItem> get _filteredHomework {
    switch (_currentFilterKey) {
      case 'urgent':
        return _allHomework.where((item) => item.isUrgent).toList();
      case 'inProgress':
        return _allHomework
            .where((item) => item.status == ParentHomeworkStatus.inProgress)
            .toList();
      case 'overdue':
        return _allHomework
            .where((item) => item.status == ParentHomeworkStatus.overdue)
            .toList();
      case 'graded':
        return _allHomework
            .where((item) => item.status == ParentHomeworkStatus.graded)
            .toList();
      case 'all':
      default:
        return _allHomework;
    }
  }

  List<HomeworkFilterOption> _buildFilterOptions() {
    final urgentCount = _allHomework.where((i) => i.isUrgent).length;
    final inProgressCount = _allHomework
        .where((i) => i.status == ParentHomeworkStatus.inProgress)
        .length;
    final overdueCount = _allHomework
        .where((i) => i.status == ParentHomeworkStatus.overdue)
        .length;

    return [
      HomeworkFilterOption(
        key: 'all',
        label: 'Tất cả',
        badgeCount: _allHomework.length,
      ),
      HomeworkFilterOption(
        key: 'urgent',
        label: 'Cần nộp gấp',
        badgeCount: urgentCount > 0 ? urgentCount : null,
      ),
      HomeworkFilterOption(
        key: 'inProgress',
        label: 'Đang làm',
        badgeCount: inProgressCount > 0 ? inProgressCount : null,
      ),
      HomeworkFilterOption(
        key: 'overdue',
        label: 'Quá hạn',
        badgeCount: overdueCount,
      ),
      const HomeworkFilterOption(
        key: 'graded',
        label: 'Đã chấm',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final currentChild = _children.firstWhere(
      (c) => c.id == _selectedChildId,
      orElse: () => _children.isNotEmpty
          ? _children.first
          : FamilyScopeChild.sample(
              id: 'sample',
              name: 'Minh',
              className: '10A1',
            ),
    );

    // Tìm bài tập khẩn cấp đầu tiên nếu có
    final urgentItem = _allHomework.where((i) => i.isUrgent).firstOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Bài tập về nhà',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FamilyScopeSelector(
              children: _children,
              selectedChildId: _selectedChildId,
              onSelected: _onChildChanged,
              showAllOption: false,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchHomeworkData,
              child: ListView(
                padding: const EdgeInsets.only(top: 8, bottom: 32),
                children: [
                  // Banner khẩn cấp nếu có và không ở filter quá hạn
                  if (urgentItem != null && _currentFilterKey != 'overdue')
                    UrgentHomeworkBanner(
                      urgentItem: urgentItem,
                      onTapDetail: () => _navigateToDetail(urgentItem.id),
                    ),

                  // Thanh chọn bộ lọc trạng thái
                  HomeworkFilterBar(
                    options: _buildFilterOptions(),
                    selectedKey: _currentFilterKey,
                    onSelectKey: _handleFilterChanged,
                  ),

                  // Nếu đang ở filter quá hạn và không có bài
                  // quá hạn (Ảnh 4 & 5)
                  if (_currentFilterKey == 'overdue' &&
                      _filteredHomework.isEmpty) ...[
                    HomeworkEmptyAllClearCard(
                      childName: currentChild.name,
                      onTapViewAll: () => _handleFilterChanged('all'),
                    ),
                    if (_gradedSummary != null)
                      GradedHomeworkSummaryCard(
                        summary: _gradedSummary!,
                        onTapViewAllGraded: () =>
                            _handleFilterChanged('graded'),
                        onTapItem: (item) => _navigateToDetail(item.id),
                      ),
                  ] else if (_filteredHomework.isEmpty) ...[
                    // Empty state chung cho các tab khác nếu không có bài
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 40,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_turned_in_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Không có bài tập nào trong mục này',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Danh sách bài tập thông thường (Ảnh 0 & 1)
                    ..._filteredHomework.map((item) {
                      return HomeworkItemCard(
                        item: item,
                        onTapDetail: () => _navigateToDetail(item.id),
                        onTapRemindChild: item.isUrgent
                            ? () => _showRemindNotification(item)
                            : null,
                      );
                    }),

                    // Hiển thị khối Kết quả tuần gần nhất ở phía dưới danh sách
                    if (_gradedSummary != null &&
                        _currentFilterKey != 'urgent') ...[
                      const SizedBox(height: 12),
                      GradedHomeworkSummaryCard(
                        summary: _gradedSummary!,
                        onTapViewAllGraded: () =>
                            _handleFilterChanged('graded'),
                        onTapItem: (item) => _navigateToDetail(item.id),
                      ),
                    ],
                  ],
                ],
              ),
            ),
    );
  }
}
