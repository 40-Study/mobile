import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/auth/bloc/auth/auth_bloc.dart';
import 'package:study/features/teacher/data/teacher_preview_api.dart';
import 'package:study/features/teacher/data/teacher_preview_workplace.dart';
import 'package:flutter/services.dart';
import 'package:study/features/auth/data/models/organization_model.dart';
import 'package:study/features/teacher/data/teacher_api.dart';
import 'package:study/features/teacher/data/teacher_workplace_controller.dart';
import 'package:study/features/teacher/presentation/classes/teacher_classes_screen.dart';
import 'package:study/features/teacher/presentation/courses/teacher_courses_screen.dart';
import 'package:study/features/teacher/presentation/home/teacher_home_screen.dart';
import 'package:study/features/teacher/presentation/profile/teacher_profile_screen.dart';
import 'package:study/features/teacher/presentation/schedule/teacher_schedule_screen.dart';
import 'package:study/features/teacher/presentation/widgets/teacher_widgets.dart';
import 'package:study/theme/theme.dart';
import 'package:study/widgets/role_app_header.dart';

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
  static const _labels = [
    'Hôm nay',
    'Lịch dạy',
    'Lớp học',
    'Khóa học',
    'Tài khoản',
  ];
  static const _icons = [
    Icons.today_outlined,
    Icons.calendar_month_outlined,
    Icons.groups_outlined,
    Icons.menu_book_outlined,
    Icons.person_outline,
  ];
  static const _selectedIcons = [
    Icons.today_rounded,
    Icons.calendar_month_rounded,
    Icons.groups_rounded,
    Icons.menu_book_rounded,
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
  }

  @override
  void dispose() {
    if (widget.workplace == null) _workplace.dispose();
    super.dispose();
  }

  void _tab(int value) => setState(() {
    _index = value;
    _visited.add(value);
  });

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
                          trailing: _workplace.activeOrg?.id == org.id
                              ? const Icon(Icons.check)
                              : null,
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

  Widget _scopeBody(String label, String? organizationId) {
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
            'Bạn vẫn có thể quản lý thông tin cá nhân, đổi vai trò hoặc đăng xuất trong Tài khoản.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    if (_seenRevision != _workplace.revision) {
      _seenRevision = _workplace.revision;
      _visited.removeWhere((tab) => tab < 4);
      _visited.add(_index < 4 ? _index : 0);
    }
    return KeyedSubtree(
      key: ValueKey(_workplace.revision),
      child: IndexedStack(
        index: _index < 4 ? _index : 0,
        children: [
          if (_visited.contains(0))
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, auth) => TeacherHomeScreen(
                api: _api,
                organizationId: organizationId,
                workplaceLabel: label,
                greetingName: auth is AuthAuthenticated
                    ? auth.user.fullName ?? auth.user.username
                    : null,
                onSchedule: () => _tab(1),
                onClasses: () => _tab(2),
                onCourses: () => _tab(3),
              ),
            )
          else
            const SizedBox.shrink(),
          if (_visited.contains(1))
            TeacherScheduleScreen(
              api: _api,
              organizationId: organizationId,
              workplaceLabel: label,
            )
          else
            const SizedBox.shrink(),
          if (_visited.contains(2))
            TeacherClassesScreen(
              api: _api,
              organizationId: organizationId,
              workplaceLabel: label,
            )
          else
            const SizedBox.shrink(),
          if (_visited.contains(3))
            TeacherCoursesScreen(api: _api)
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _workplace,
    builder: (context, _) {
      final label = _workplace.activeOrg?.name ?? 'Cá nhân';
      // The account subtree has a stable position outside organization revision:
      // scope changes never recreate ProfileCubit or reset account scroll.
      final content = IndexedStack(
        index: _index == 4 ? 1 : 0,
        children: [
          Column(
            children: [
              if (_workplace.busy) const LinearProgressIndicator(),
              Expanded(
                child: AbsorbPointer(
                  absorbing: _workplace.busy,
                  child: _scopeBody(label, _workplace.activeOrg?.id),
                ),
              ),
            ],
          ),
          if (_visited.contains(4))
            const TeacherProfileScreen()
          else
            const SizedBox.shrink(),
        ],
      );
      final wide = MediaQuery.sizeOf(context).width >= 840;
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Scaffold(
          body: SafeArea(
            bottom: wide,
            child: Column(
              children: [
                RoleAppHeader(
                  icon: _selectedIcons[_index],
                  categoryLabel: 'GIÁO VIÊN 40STUDY',
                  title: _labels[_index],
                  showNotification: false,
                  onAvatarTap: () => _tab(4),
                ),
                if (_api is TeacherPreviewApi && _index != 4)
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
                                5,
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
                    5,
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
