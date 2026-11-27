import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study/features/auth/data/models/organization_model.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_leave_api.dart';
import 'package:study/features/teacher/data/teacher_notification_api.dart';
import 'package:study/features/teacher/data/teacher_preview_api.dart';
import 'package:study/features/teacher/data/teacher_preview_workplace.dart';
import 'package:study/features/teacher/data/teacher_workplace_controller.dart';
import 'package:study/features/teacher/presentation/classes/teacher_classes_screen.dart';
import 'package:study/features/teacher/presentation/notifications/teacher_notifications_screen.dart';
import 'package:study/features/teacher/presentation/profile/teacher_profile_screen.dart';
import 'package:study/features/teacher/presentation/report/teacher_report_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_schedule_screen.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_app_header.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';

class TeacherShell extends StatefulWidget {
  const TeacherShell({super.key, this.api, this.workplace, this.onAdvanced});
  final TeacherApi? api;
  final TeacherWorkplaceController? workplace;
  final VoidCallback? onAdvanced;
  @override
  State<TeacherShell> createState() => _TeacherShellState();
}

class _TeacherShellState extends State<TeacherShell> {
  late final TeacherApi _api =
      widget.api ??
      (TeacherPreviewApi.enabled ? TeacherPreviewApi() : TeacherApi());
  late final TeacherApi _leaveApi = _api is TeacherPreviewApi
      ? _api
      : TeacherLeaveApi(_api);
  late final TeacherWorkplaceController _workplace =
      widget.workplace ??
      (_api is TeacherPreviewApi
          ? TeacherPreviewWorkplace(_api)
          : TeacherWorkplaceController(api: _api));
  DateTime? _reportMonth;
  int _reportMonthRequest = 0;
  int _reportRevision = 0;
  int _index = 0;
  final Set<int> _visited = {0};
  int _seenRevision = 0;
  bool _scopeLoaded = false;
  int _unreadNotifications = 0;
  int _notificationCountRequest = 0;

  // PageController cho swipe navigation
  late final PageController _pageController = PageController();

  // Spec mốc 1a: 4 tabs - Lịch, Lớp, Báo cáo, Hồ sơ
  static const _labels = ['Lịch', 'Lớp', 'Báo cáo', 'Hồ sơ'];
  static const _icons = [
    Icons.calendar_today_outlined,
    Icons.school_outlined,
    Icons.bar_chart_outlined,
    Icons.person_outline,
  ];
  static const _selectedIcons = [
    Icons.calendar_today_rounded,
    Icons.school_rounded,
    Icons.bar_chart_rounded,
    Icons.person_rounded,
  ];
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    unawaited(_loadUnreadNotifications());
    await _workplace.initialize();
    if (mounted && _workplace.error == null) {
      setState(() => _scopeLoaded = true);
    }
  }

  Future<void> _loadUnreadNotifications() async {
    final request = ++_notificationCountRequest;
    try {
      final count = await TeacherNotificationApi(_api).unreadCount();
      if (mounted && request == _notificationCountRequest) {
        setState(() => _unreadNotifications = count);
      }
    } catch (_) {
      // API không hỗ trợ hoặc lỗi - bỏ qua
    }
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TeacherNotificationsScreen(
          api: _api,
          leaveApi: _leaveApi,
          confirmWorkplace: _confirmNotificationWorkplace,
        ),
      ),
    );
    if (mounted) await _loadUnreadNotifications();
  }

  Future<String?> _confirmNotificationWorkplace(String? organizationId) async {
    if (!mounted ||
        !_workplace.initialized ||
        _workplace.busy ||
        !_scopeLoaded) {
      throw const FormatException(
        'Chưa xác định được nơi làm việc của thông báo.',
      );
    }
    final target = _workplace.organizations
        .where((organization) => organization.id == organizationId)
        .firstOrNull;
    if (organizationId != null && target == null) {
      throw const FormatException(
        'Bạn không còn quyền truy cập nơi làm việc này.',
      );
    }
    final label = target?.name ?? 'Cá nhân';
    if (_workplace.activeOrg?.id == organizationId) return label;

    final approve = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chuyển nơi làm việc?'),
        content: Text('Mở thông báo này trong $label.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Ở lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Chuyển và mở'),
          ),
        ],
      ),
    );
    if (approve != true || !mounted) return null;
    await _workplace.select(target);
    if (!mounted || _workplace.activeOrg?.id != organizationId) return null;
    return label;
  }

  @override
  void dispose() {
    _pageController.dispose();
    if (widget.workplace == null) _workplace.dispose();
    super.dispose();
  }

  void _tab(int value) {
    setState(() {
      _index = value;
      _visited.add(value);
    });
    // Animate PageView khi tap tab
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        value,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int page) {
    if (_index != page) {
      setState(() {
        _index = page;
        _visited.add(page);
      });
    }
  }

  /// Sync PageController khi workplace thay đổi
  void _syncPageController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients &&
          _pageController.page?.round() != _index) {
        _pageController.jumpToPage(_index);
      }
    });
  }

  Future<void> _selectWorkplace() async {
    if (_workplace.busy) return;
    var search = '';
    final colorScheme = Theme.of(context).colorScheme;
    final selection = await showModalBottomSheet<(OrganizationModel?,)>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      backgroundColor: teacherScheduleCardColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (context) => StatefulBuilder(
        builder: (context, update) {
          final theme = Theme.of(context);
          final dark = theme.brightness == Brightness.dark;
          final query = search.toLowerCase();
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: dark
                              ? colorScheme.outline
                              : const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Nơi làm việc', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: dark
                            ? colorScheme.surfaceContainer
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: teacherScheduleBorder(context),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Lớp và lịch dạy theo nơi làm việc. Khóa học và thu nhập luôn thuộc cá nhân.',
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_workplace.organizations.length > 5)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Tìm tổ chức',
                          ),
                          onChanged: (text) => update(() => search = text),
                        ),
                      ),
                    const SizedBox(height: 12),
                    if ('cá nhân'.contains(query))
                      _WorkplaceChoice(
                        name: 'Cá nhân',
                        subtitle: 'Lớp và lịch dạy cá nhân',
                        icon: Icons.person_outline,
                        selected: _workplace.activeOrg == null,
                        onTap: () => Navigator.pop(context, (null,)),
                      ),
                    for (final org in _workplace.organizations.where(
                      (org) => org.name.toLowerCase().contains(query),
                    ))
                      _WorkplaceChoice(
                        name: org.name,
                        subtitle: 'Lớp và lịch dạy của tổ chức',
                        icon: Icons.business_outlined,
                        selected: _workplace.activeOrg?.id == org.id,
                        attentionCount:
                            _workplace.needsAttentionCounts[org.id] ?? 0,
                        onTap: () => Navigator.pop(context, (org,)),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    if (selection == null || !mounted) return;
    try {
      await _workplace.select(selection.$1);
      if (mounted && _workplace.error == null) {
        setState(() => _scopeLoaded = true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Chưa chuyển được nơi làm việc. ${teacherErrorMessage(error)}',
            ),
          ),
        );
      }
    }
  }

  Widget _workplacePill(BuildContext context, String label) {
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.onSurface;
    final attention = _workplace.otherOrgNeedsAttention;
    return Semantics(
      label:
          'Nơi làm việc: $label${attention > 0 ? ', $attention buổi cần xử lý ở nơi khác' : ''}',
      button: true,
      child: Tooltip(
        message: 'Nơi làm việc: $label',
        excludeFromSemantics: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: !_workplace.initialized || _workplace.busy
                ? null
                : _selectWorkplace,
            borderRadius: BorderRadius.circular(999),
            child: ExcludeSemantics(
              child: SizedBox(
                height: 48,
                child: Center(
                  widthFactor: 1,
                  child: Ink(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.light
                          ? const Color(0xFFF1F5F9)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: foreground,
                            ),
                          ),
                        ),
                        if (attention > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Badge(
                              backgroundColor: AchievementColors.red,
                            ),
                          ),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 16,
                          color: foreground,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Trả về error/loading state nếu chưa load xong workplace
  Widget? _scopeErrorOrLoading() {
    if (!_workplace.initialized) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_scopeLoaded) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TeacherErrorView(
            error: FormatException(
              _workplace.error ?? 'Chưa tải được nơi làm việc.',
            ),
            onRetry: _initialize,
          ),
          if (_workplace.activeOrg != null)
            OutlinedButton(
              onPressed: _workplace.busy ? null : _selectWorkplace,
              child: const Text('Chọn lại nơi làm việc'),
            ),
          const Text(
            'Bạn vẫn có thể quản lý thông tin cá nhân, đổi vai trò hoặc đăng xuất trong Hồ sơ.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    return null;
  }

  /// Build các screens cho PageView
  List<Widget> _buildScreens(
    String label,
    String? organizationId,
    Widget? scopeState,
  ) {
    // Check revision change để reset visited và sync PageController
    if (_seenRevision != _workplace.revision) {
      _seenRevision = _workplace.revision;
      _reportMonth = null;
      _visited.removeWhere((tab) => tab < 3);
      _visited.add(_index < 3 ? _index : 0);
      _syncPageController();
    }

    return [
      // Tab 0: Lịch
      scopeState ??
          KeyedSubtree(
            key: ValueKey('schedule_${_workplace.revision}'),
            child: _visited.contains(0)
                ? TeacherScheduleScreen(
                    api: _api,
                    leaveApi: _leaveApi,
                    organizationId: organizationId,
                    workplaceLabel: label,
                    onNavigateToReport: (month) {
                      _reportMonth = month;
                      _reportMonthRequest++;
                      _tab(2);
                    },
                    onSessionChanged: () => setState(() => _reportRevision++),
                    onNeedsAttentionCountChanged: (count) {
                      _workplace.updateNeedsAttentionCount(
                        organizationId,
                        count,
                      );
                    },
                  )
                : const SizedBox.shrink(),
          ),
      // Tab 1: Lớp
      scopeState ??
          KeyedSubtree(
            key: ValueKey('classes_${_workplace.revision}'),
            child: _visited.contains(1)
                ? TeacherClassesScreen(
                    api: _api,
                    organizationId: organizationId,
                    workplaceLabel: label,
                    onChanged: () => setState(() => _reportRevision++),
                  )
                : const SizedBox.shrink(),
          ),
      // Tab 2: Báo cáo
      scopeState ??
          KeyedSubtree(
            key: ValueKey('report_${_workplace.revision}'),
            child: _visited.contains(2)
                ? TeacherReportScreen(
                    initialMonth: _reportMonth,
                    monthRequestRevision: _reportMonthRequest,
                    refreshRevision: _reportRevision,
                    api: _api,
                    organizationId: organizationId,
                    workplaceLabel: label,
                  )
                : const SizedBox.shrink(),
          ),
      // Tab 3: Hồ sơ (không phụ thuộc workplace revision)
      _visited.contains(3)
          ? const TeacherProfileScreen()
          : const SizedBox.shrink(),
    ];
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _workplace,
    builder: (context, _) {
      final label = _workplace.activeOrg?.name ?? 'Cá nhân';
      final organizationId = _workplace.activeOrg?.id;

      // Check error/loading state
      final errorOrLoading = _scopeErrorOrLoading();

      // Build PageView content với swipe navigation
      final content = Column(
        children: [
          if (_workplace.busy) const LinearProgressIndicator(),
          Expanded(
            child: AbsorbPointer(
              absorbing: _workplace.busy,
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: _buildScreens(label, organizationId, errorOrLoading),
              ),
            ),
          ),
        ],
      );

      final wide = MediaQuery.sizeOf(context).width >= 840;
      final cs = Theme.of(context).colorScheme;
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: _index == 0
              ? teacherScheduleBackground(context)
              : cs.surface,
          body: SafeArea(
            bottom: wide,
            child: Column(
              children: [
                TeacherAppHeader(
                  icon: _selectedIcons[_index],
                  title: _labels[_index],
                  titleSuffix: _index == 0
                      ? _workplacePill(context, label)
                      : null,
                  onAvatarTap: () => _tab(3),
                  onNotificationTap: _openNotifications,
                  hasUnreadNotifications: _unreadNotifications > 0,
                ),
                if (_api is TeacherPreviewApi && _index != 3)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.science_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        AppSpacing.hGap8,
                        Flexible(
                          child: Text(
                            'Dữ liệu mẫu · Chỉ xem giao diện',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_index == 1 || _index == 2)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Material(
                      color: cs.surfaceContainerLow,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.borderMd,
                        side: BorderSide(color: cs.outlineVariant),
                      ),
                      child: InkWell(
                        borderRadius: AppRadius.borderMd,
                        onTap: !_workplace.initialized || _workplace.busy
                            ? null
                            : _selectWorkplace,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 48),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _workplace.activeOrg == null
                                      ? Icons.person_outline_rounded
                                      : Icons.business_outlined,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                AppSpacing.hGap8,
                                Expanded(
                                  child: Text(
                                    'Nơi làm việc · $label',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelLarge,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Badge số buổi "Cần xử lý" ở các nơi khác
                                if (_workplace.otherOrgNeedsAttention > 0) ...[
                                  AppSpacing.hGap8,
                                  _NeedsAttentionBadge(
                                    count: _workplace.otherOrgNeedsAttention,
                                  ),
                                ],
                                AppSpacing.hGap8,
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: wide
                      ? Row(
                          children: [
                            NavigationRail(
                              selectedIndex: _index,
                              labelType: NavigationRailLabelType.all,
                              onDestinationSelected: _tab,
                              destinations: List.generate(
                                4,
                                (i) => NavigationRailDestination(
                                  icon: Icon(_icons[i]),
                                  selectedIcon: Icon(_selectedIcons[i]),
                                  label: Text(_labels[i]),
                                ),
                              ),
                            ),
                            const VerticalDivider(width: 1),
                            Expanded(child: content),
                          ],
                        )
                      : content,
                ),
              ],
            ),
          ),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: _tab,
                  destinations: List.generate(
                    4,
                    (i) => NavigationDestination(
                      icon: Icon(_icons[i]),
                      selectedIcon: Icon(_selectedIcons[i]),
                      label: _labels[i],
                    ),
                  ),
                ),
        ),
      );
    },
  );
}

class _WorkplaceChoice extends StatelessWidget {
  const _WorkplaceChoice({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.attentionCount = 0,
  });

  final String name;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final int attentionCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final blue = dark ? theme.colorScheme.primary : teacherScheduleBlue;
    final tint = dark
        ? theme.colorScheme.primaryContainer
        : teacherSchedulePaleBlue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: selected ? tint : teacherScheduleCardColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: selected ? blue : teacherScheduleBorder(context),
              width: selected ? 1.2 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? teacherScheduleCardColor(context)
                          : tint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: blue, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: theme.textTheme.titleSmall),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (attentionCount > 0) ...[
                    const SizedBox(width: 8),
                    _NeedsAttentionBadge(count: attentionCount),
                  ],
                  if (selected) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.check_circle_rounded, color: blue, size: 20),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Badge đỏ hiển thị số buổi "Cần xử lý"
class _NeedsAttentionBadge extends StatelessWidget {
  const _NeedsAttentionBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AchievementColors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
