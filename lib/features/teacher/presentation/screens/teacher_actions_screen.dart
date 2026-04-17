import 'package:flutter/material.dart';
import 'package:study/constants/dimens.dart';

class TeacherActionsScreen extends StatefulWidget {
  const TeacherActionsScreen({super.key});

  @override
  State<TeacherActionsScreen> createState() => _TeacherActionsScreenState();
}

class _TeacherActionsScreenState extends State<TeacherActionsScreen> {
  int _selectedTab = 0; // 0 = Livestream, 1 = Chấm bài, 2 = Lịch dạy

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildTitle(context),
            _buildTabSwitcher(context),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: _buildContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textColor = cs.onSurface;
    final secondaryColor = cs.onSurface.withValues(alpha: 0.6);
    final iconBgColor = cs.surfaceContainerHighest;

    return Padding(
      padding: const EdgeInsets.all(AppLayout.screenMargin),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.flash_on,
              color: textColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            'Hành động nhanh',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          CircleAvatar(
            radius: 18,
            backgroundColor: iconBgColor,
            child: Icon(Icons.person, color: secondaryColor, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textColor = cs.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.screenMargin),
      child: Text(
        'Hành động',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
      ),
    );
  }

  Widget _buildTabSwitcher(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppLayout.screenMargin),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TabButton(
              label: 'Livestream',
              isSelected: _selectedTab == 0,
              onTap: () => setState(() => _selectedTab = 0),
            ),
            _TabButton(
              label: 'Chấm bài',
              isSelected: _selectedTab == 1,
              onTap: () => setState(() => _selectedTab = 1),
            ),
            _TabButton(
              label: 'Lịch dạy',
              isSelected: _selectedTab == 2,
              onTap: () => setState(() => _selectedTab = 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return switch (_selectedTab) {
      0 => const _LivestreamTab(),
      1 => const _GradingTab(),
      2 => const _ScheduleTab(),
      _ => const SizedBox.shrink(),
    };
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? cs.onPrimary
                : isDark
                    ? Colors.white.withValues(alpha: 0.8)
                    : cs.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ============ LIVESTREAM TAB ============

class _LivestreamTab extends StatelessWidget {
  const _LivestreamTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(
        left: AppLayout.screenMargin,
        right: AppLayout.screenMargin,
        bottom: 100,
      ),
      children: [
        // Start Livestream Card
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade400, Colors.red.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.wifi_tethering,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Bắt đầu Livestream',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Phát trực tiếp buổi học với học viên',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    _showStartLivestreamDialog(context);
                  },
                  icon: const Icon(Icons.videocam),
                  label: const Text('Phát ngay'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Scheduled Livestreams
        Text(
          'Lịch phát sắp tới',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: AppSpacing.md),

        _ScheduledLivestreamCard(
          title: 'Toán cao cấp - Chương 5',
          className: 'Lớp A1',
          time: '14:00 - Hôm nay',
          isUpcoming: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        _ScheduledLivestreamCard(
          title: 'Lập trình Flutter nâng cao',
          className: 'Lớp K2',
          time: '09:00 - Ngày mai',
          isUpcoming: false,
        ),
        const SizedBox(height: AppSpacing.sm),
        _ScheduledLivestreamCard(
          title: 'Tiếng Anh giao tiếp',
          className: 'Lớp B3',
          time: '15:30 - 31/03',
          isUpcoming: false,
        ),
      ],
    );
  }

  void _showStartLivestreamDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _StartLivestreamSheet(),
    );
  }
}

class _ScheduledLivestreamCard extends StatelessWidget {
  const _ScheduledLivestreamCard({
    required this.title,
    required this.className,
    required this.time,
    required this.isUpcoming,
  });

  final String title;
  final String className;
  final String time;
  final bool isUpcoming;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUpcoming
              ? Colors.red.withValues(alpha: 0.5)
              : cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.videocam, color: Colors.red),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      className,
                      style: TextStyle(
                        color: cs.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isUpcoming)
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
              ),
              child: const Text('Vào'),
            )
          else
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
              ),
              child: const Text('Chi tiết'),
            ),
        ],
      ),
    );
  }
}

class _StartLivestreamSheet extends StatelessWidget {
  const _StartLivestreamSheet();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppLayout.screenMargin),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Chọn lớp để phát',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _ClassOption(title: 'Toán cao cấp - Lớp A1', students: 25),
          const SizedBox(height: AppSpacing.sm),
          _ClassOption(title: 'Lập trình Flutter - K2', students: 18),
          const SizedBox(height: AppSpacing.sm),
          _ClassOption(title: 'Tiếng Anh giao tiếp - B3', students: 20),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đang khởi tạo livestream...')),
                );
              },
              icon: const Icon(Icons.wifi_tethering),
              label: const Text('Bắt đầu Livestream'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

class _ClassOption extends StatefulWidget {
  const _ClassOption({required this.title, required this.students});

  final String title;
  final int students;

  @override
  State<_ClassOption> createState() => _ClassOptionState();
}

class _ClassOptionState extends State<_ClassOption> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => setState(() => _selected = !_selected),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: _selected ? cs.primaryContainer : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selected ? cs.primary : cs.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _selected ? Icons.check_circle : Icons.circle_outlined,
              color: _selected ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(
                  fontWeight: _selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            Text(
              '${widget.students} học viên',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ GRADING TAB ============

class _GradingTab extends StatefulWidget {
  const _GradingTab();

  @override
  State<_GradingTab> createState() => _GradingTabState();
}

class _GradingTabState extends State<_GradingTab> {
  String _selectedCourse = 'Tất cả';
  final List<String> _courses = [
    'Tất cả',
    'Toán cao cấp',
    'Lập trình Flutter',
    'Tiếng Anh giao tiếp',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textColor = cs.onSurface;
    final secondaryColor = cs.onSurface.withValues(alpha: 0.6);

    return ListView(
      padding: const EdgeInsets.only(
        left: AppLayout.screenMargin,
        right: AppLayout.screenMargin,
        bottom: 100,
      ),
      children: [
        // Summary Card
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.assignment_late, color: Colors.orange),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '5 bài tập chờ chấm',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'Từ 3 lớp học khác nhau',
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Course Filter
        Row(
          children: [
            Text(
              'Bài tập cần chấm',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
            ),
            const Spacer(),
            _CourseFilterDropdown(
              selectedCourse: _selectedCourse,
              courses: _courses,
              onChanged: (value) => setState(() => _selectedCourse = value),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Pending assignments list
        ..._buildGradingItems(),
      ],
    );
  }

  List<Widget> _buildGradingItems() {
    final data = [
      ('Nguyễn Văn An', 'Bài tập chương 3', 'Toán cao cấp', 'Lớp A1', '1 giờ trước'),
      ('Trần Thị Bình', 'Đồ án cuối kỳ', 'Lập trình Flutter', 'Lớp K2', '2 giờ trước'),
      ('Lê Hoàng Minh', 'Bài kiểm tra 15 phút', 'Toán cao cấp', 'Lớp A1', '3 giờ trước'),
      ('Phạm Thùy Dương', 'Thực hành số 5', 'Tiếng Anh giao tiếp', 'Lớp B3', '5 giờ trước'),
      ('Hoàng Quốc Việt', 'Báo cáo thí nghiệm', 'Lập trình Flutter', 'Lớp K2', '1 ngày trước'),
    ];

    final filtered = _selectedCourse == 'Tất cả'
        ? data
        : data.where((item) => item.$3 == _selectedCourse).toList();

    return filtered.map((item) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: _GradingItemCard(
          studentName: item.$1,
          assignmentTitle: item.$2,
          courseName: item.$3,
          className: item.$4,
          submittedAt: item.$5,
        ),
      );
    }).toList();
  }
}

class _CourseFilterDropdown extends StatelessWidget {
  const _CourseFilterDropdown({
    required this.selectedCourse,
    required this.courses,
    required this.onChanged,
  });

  final String selectedCourse;
  final List<String> courses;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: DropdownButton<String>(
        value: selectedCourse,
        isDense: true,
        underline: const SizedBox(),
        icon: Icon(Icons.keyboard_arrow_down, size: 18, color: cs.onSurface),
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        items: courses
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => onChanged(v!),
      ),
    );
  }
}

class _GradingItemCard extends StatelessWidget {
  const _GradingItemCard({
    required this.studentName,
    required this.assignmentTitle,
    required this.courseName,
    required this.className,
    required this.submittedAt,
  });

  final String studentName;
  final String assignmentTitle;
  final String courseName;
  final String className;
  final String submittedAt;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: cs.primaryContainer,
            child: Text(
              studentName[0],
              style: TextStyle(
                color: cs.primary,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  assignmentTitle,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        courseName,
                        style: TextStyle(
                          color: cs.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '$className • $submittedAt',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
            ),
            child: const Text('Chấm'),
          ),
        ],
      ),
    );
  }
}

// ============ SCHEDULE TAB ============

class _ScheduleTab extends StatefulWidget {
  const _ScheduleTab();

  @override
  State<_ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<_ScheduleTab> {
  DateTime _selectedDate = DateTime.now();
  String _selectedCourse = 'Tất cả';
  final List<String> _courses = [
    'Tất cả',
    'Toán cao cấp',
    'Lập trình Flutter',
    'Tiếng Anh giao tiếp',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textColor = cs.onSurface;

    return ListView(
      padding: const EdgeInsets.only(
        left: AppLayout.screenMargin,
        right: AppLayout.screenMargin,
        bottom: 100,
      ),
      children: [
        // Calendar Strip
        _buildCalendarStrip(context),
        const SizedBox(height: AppSpacing.lg),

        // Filter Row
        Row(
          children: [
            Text(
              'Lịch dạy',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
            ),
            const Spacer(),
            _CourseFilterDropdown(
              selectedCourse: _selectedCourse,
              courses: _courses,
              onChanged: (value) => setState(() => _selectedCourse = value),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Schedule list based on selected date
        ..._buildScheduleForDate(),
      ],
    );
  }

  Widget _buildCalendarStrip(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();

    // Generate 7 days starting from today
    final days = List.generate(7, (index) {
      return now.add(Duration(days: index));
    });

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Month & Year header with calendar button
          Row(
            children: [
              Text(
                _formatMonthYear(_selectedDate),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showDatePicker(context),
                icon: Icon(Icons.calendar_month, color: cs.primary),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Day strip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.map((date) {
              final isSelected = _isSameDay(date, _selectedDate);
              final isToday = _isSameDay(date, now);

              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? cs.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _getDayName(date),
                        style: TextStyle(
                          color: isSelected
                              ? cs.onPrimary
                              : cs.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          color: isSelected
                              ? cs.onPrimary
                              : isToday
                                  ? cs.primary
                                  : cs.onSurface,
                          fontSize: 16,
                          fontWeight: isSelected || isToday
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      if (isToday && !isSelected) ...[
                        const SizedBox(height: 2),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: cs,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
      'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
      'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
    ];
    return '${months[date.month - 1]}, ${date.year}';
  }

  String _getDayName(DateTime date) {
    const days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return days[date.weekday % 7];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<Widget> _buildScheduleForDate() {
    final cs = Theme.of(context).colorScheme;
    final secondaryColor = cs.onSurface.withValues(alpha: 0.6);
    final now = DateTime.now();
    final isToday = _isSameDay(_selectedDate, now);
    final isTomorrow = _isSameDay(_selectedDate, now.add(const Duration(days: 1)));

    String dayLabel;
    if (isToday) {
      dayLabel = 'Hôm nay';
    } else if (isTomorrow) {
      dayLabel = 'Ngày mai';
    } else {
      const weekdays = ['Chủ nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
      dayLabel = '${weekdays[_selectedDate.weekday % 7]}, ${_selectedDate.day}/${_selectedDate.month}';
    }

    // Mock schedules - filter by course
    final allSchedules = [
      _ScheduleData(
        time: '09:00',
        title: 'Toán cao cấp',
        className: 'Lớp A1',
        students: 25,
        isLive: isToday,
      ),
      _ScheduleData(
        time: '14:00',
        title: 'Lập trình Flutter',
        className: 'K2',
        students: 18,
      ),
      _ScheduleData(
        time: '15:30',
        title: 'Tiếng Anh giao tiếp',
        className: 'B3',
        students: 20,
      ),
    ];

    final filtered = _selectedCourse == 'Tất cả'
        ? allSchedules
        : allSchedules.where((s) => s.title == _selectedCourse).toList();

    if (filtered.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: [
              Icon(
                Icons.event_busy,
                size: 48,
                color: secondaryColor.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Không có lịch dạy',
                style: TextStyle(
                  color: secondaryColor,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return [
      Text(
        dayLabel,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: secondaryColor,
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      ...filtered.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _ScheduleCard(schedule: s),
          )),
    ];
  }
}

class _ScheduleData {
  const _ScheduleData({
    required this.time,
    required this.title,
    required this.className,
    required this.students,
    this.isLive = false,
  });

  final String time;
  final String title;
  final String className;
  final int students;
  final bool isLive;
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.schedule});

  final _ScheduleData schedule;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = schedule;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: s.isLive
              ? cs.primary.withValues(alpha: 0.5)
              : cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                s.time,
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (s.isLive)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Container(
            width: 1,
            height: 40,
            color: cs.outlineVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${s.title} - ${s.className}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${s.students} Học viên',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: s.isLive ? cs.primary : cs.primaryContainer,
              foregroundColor: s.isLive ? cs.onPrimary : cs.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
            ),
            child: Text(s.isLive ? 'Vào lớp' : 'Chuẩn bị'),
          ),
        ],
      ),
    );
  }
}
