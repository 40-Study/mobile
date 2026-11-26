import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study/features/teacher/data/teacher_preview_api.dart';
import 'package:study/features/teacher/data/teacher_preview_workplace.dart';
import 'package:study/theme/theme.dart';
import 'package:study/features/auth/data/models/organization_model.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_workplace_controller.dart';
import 'package:study/features/teacher/presentation/classes/teacher_classes_screen.dart';
import 'package:study/features/teacher/presentation/profile/teacher_profile_screen.dart';
import 'package:study/features/teacher/presentation/report/teacher_report_screen.dart';
import 'package:study/features/teacher/presentation/notifications/teacher_notifications_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_schedule_screen.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_app_header.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';

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
  late final TeacherWorkplaceController _workplace =
      widget.workplace ??
      (_api is TeacherPreviewApi
          ? TeacherPreviewWorkplace(_api)
          : TeacherWorkplaceController(api: _api));
  int _index = 0;
  final Set<int> _visited = {0};
  int _seenRevision = 0;
  bool _scopeLoaded = false;
  int _unreadNotifications = 0;

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
    await _workplace.initialize();
    if (mounted && _workplace.error == null) {
      setState(() => _scopeLoaded = true);
    }
    _loadUnreadNotifications();
  }

  Future<void> _loadUnreadNotifications() async {
    try {
      final raw = await _api.get('/me/notifications/unread-count');
      final count = (raw['data']?['count'] ?? 0) as int;
      if (mounted) setState(() => _unreadNotifications = count);
    } catch (_) {
      // API không hỗ trợ hoặc lỗi - bỏ qua
    }
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TeacherNotificationsScreen(api: _api),
      ),
    );
    // Reload unread count sau khi quay lại
    _loadUnreadNotifications();
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
      if (_pageController.hasClients && _pageController.page?.round() != _index) {
        _pageController.jumpToPage(_index);
      }
    });
  }

  Future<void> _selectWorkplace() async {
    if (_workplace.busy) return;
    var search = '';
    final selection = await showModalBottomSheet<(OrganizationModel?,)>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .65,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Nơi làm việc',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Text(
                        'Lớp và lịch dạy theo nơi làm việc. Khóa học và thu nhập luôn thuộc cá nhân.',
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
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      if ('cá nhân'.contains(search.toLowerCase()))
                        ListTile(
                          title: const Text('Cá nhân'),
                          leading: const Icon(Icons.person_outline),
                          trailing: _workplace.activeOrg == null
                              ? const Icon(Icons.check)
                              : null,
                          onTap: () => Navigator.pop(context, (null,)),
                        ),
                      for (final org in _workplace.organizations.where(
                        (org) => org.name.toLowerCase().contains(
                          search.toLowerCase(),
                        ),
                      ))
                        ListTile(
                          title: Text(org.name),
                          leading: const Icon(Icons.business_outlined),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Badge số buổi cần xử lý cho từng trung tâm
                              if (_workplace.needsAttentionCounts[org.id] != null &&
                                  _workplace.needsAttentionCounts[org.id]! > 0)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _NeedsAttentionBadge(
                                    count: _workplace.needsAttentionCounts[org.id]!,
                                  ),
                                ),
                              if (_workplace.activeOrg?.id == org.id)
                                const Icon(Icons.check),
                            ],
                          ),
                          onTap: () => Navigator.pop(context, (org,)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
  List<Widget> _buildScreens(String label, String? organizationId) {
    // Check revision change để reset visited và sync PageController
    if (_seenRevision != _workplace.revision) {
      _seenRevision = _workplace.revision;
      _visited.removeWhere((tab) => tab < 3);
      _visited.add(_index < 3 ? _index : 0);
      _syncPageController();
    }

    return [
      // Tab 0: Lịch
      KeyedSubtree(
        key: ValueKey('schedule_${_workplace.revision}'),
        child: _visited.contains(0)
            ? TeacherScheduleScreen(
                api: _api,
                organizationId: organizationId,
                workplaceLabel: label,
                onNavigateToReport: () => _tab(2),
                onNeedsAttentionCountChanged: (count) {
                  _workplace.updateNeedsAttentionCount(organizationId, count);
                },
              )
            : const SizedBox.shrink(),
      ),
      // Tab 1: Lớp
      KeyedSubtree(
        key: ValueKey('classes_${_workplace.revision}'),
        child: _visited.contains(1)
            ? TeacherClassesScreen(
                api: _api,
                organizationId: organizationId,
                workplaceLabel: label,
              )
            : const SizedBox.shrink(),
      ),
      // Tab 2: Báo cáo
      KeyedSubtree(
        key: ValueKey('report_${_workplace.revision}'),
        child: _visited.contains(2)
            ? TeacherReportScreen(
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
      final content = errorOrLoading != null
          ? errorOrLoading
          : Column(
              children: [
                if (_workplace.busy) const LinearProgressIndicator(),
                Expanded(
                  child: AbsorbPointer(
                    absorbing: _workplace.busy,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      children: _buildScreens(label, organizationId),
                    ),
                  ),
                ),
              ],
            );

      final wide = MediaQuery.sizeOf(context).width >= 840;
      final cs = Theme.of(context).colorScheme;
      // Tinted surface cho body background - tạo depth
      final surfaceBg = Color.alphaBlend(
        RoleColors.teacherPrimary.withValues(alpha: 0.045),
        cs.surfaceContainer,
      );
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: surfaceBg,
          body: SafeArea(
            bottom: wide,
            child: Column(
              children: [
                TeacherAppHeader(
                  icon: _selectedIcons[_index],
                  title: _labels[_index],
                  onAvatarTap: () => _tab(3),
                  onNotificationTap: _openNotifications,
                  showNotification: _unreadNotifications > 0,
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
                // Workplace selector: show on tabs 0-2 (Lịch, Lớp, Báo cáo)
                if (_index < 3)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Material(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: AppRadius.borderMd,
                      child: InkWell(
                        borderRadius: AppRadius.borderMd,
                        onTap: !_workplace.initialized || _workplace.busy
                            ? null
                            : _selectWorkplace,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
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
                                  style: Theme.of(context).textTheme.labelLarge,
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
