import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/teacher/bloc/courses/create_course_cubit.dart';
import 'package:study/features/teacher/data/models/create_course_model.dart';

class CreateCourseScreen extends StatelessWidget {
  const CreateCourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateCourseCubit(),
      child: const _CreateCourseView(),
    );
  }
}

class _CreateCourseView extends StatefulWidget {
  const _CreateCourseView();

  @override
  State<_CreateCourseView> createState() => _CreateCourseViewState();
}

class _CreateCourseViewState extends State<_CreateCourseView> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: BlocConsumer<CreateCourseCubit, CreateCourseState>(
        listenWhen: (prev, curr) =>
            prev.currentStep != curr.currentStep ||
            prev.isCompleted != curr.isCompleted ||
            prev.error != curr.error,
        listener: (context, state) {
          if (state.isCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Tạo khóa học thành công!'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            Navigator.pop(context, true);
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: cs.error,
              ),
            );
          }
          _animateToPage(state.currentStep);
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                // Header
                _Header(currentStep: state.currentStep),
                // Progress
                _ProgressBar(currentStep: state.currentStep),
                // Content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _BasicInfoStep(data: state.courseData),
                      _MediaDescriptionStep(data: state.courseData),
                      _PricingStep(data: state.courseData),
                      _CompleteStep(data: state.courseData),
                    ],
                  ),
                ),
                // Bottom
                _BottomBar(
                  currentStep: state.currentStep,
                  isSubmitting: state.isSubmitting,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// Header
// =============================================================================

class _Header extends StatelessWidget {
  const _Header({required this.currentStep});

  final int currentStep;

  String get _title {
    return switch (currentStep) {
      0 => 'Thông tin cơ bản',
      1 => 'Hình ảnh & Mô tả',
      2 => 'Thiết lập giá',
      3 => 'Xác nhận',
      _ => '',
    };
  }

  String get _subtitle {
    return switch (currentStep) {
      0 => 'Nhập thông tin chung về khóa học',
      1 => 'Thêm hình ảnh và mô tả chi tiết',
      2 => 'Cài đặt giá cho khóa học',
      3 => 'Kiểm tra và hoàn tất',
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  backgroundColor: cs.surfaceContainerHighest,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Bước ${currentStep + 1}/4',
                  style: tt.labelMedium?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: tt.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _subtitle,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Progress Bar
// =============================================================================

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(4, (index) {
          final isCompleted = index < currentStep;
          final isActive = index == currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: isCompleted || isActive
                    ? cs.primary
                    : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// =============================================================================
// Bottom Bar
// =============================================================================

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.currentStep, required this.isSubmitting});

  final int currentStep;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cubit = context.read<CreateCourseCubit>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isSubmitting ? null : cubit.previousStep,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Quay lại'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          if (currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: currentStep == 0 ? 1 : 1,
            child: FilledButton.icon(
              onPressed: isSubmitting
                  ? null
                  : () {
                      if (currentStep < 3) {
                        cubit.nextStep();
                      } else {
                        cubit.submitCourse();
                      }
                    },
              icon: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      currentStep < 3 ? Icons.arrow_forward : Icons.check,
                      size: 18,
                    ),
              label: Text(currentStep < 3 ? 'Tiếp tục' : 'Tạo khóa học'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Step 1: Basic Info
// =============================================================================

class _BasicInfoStep extends StatelessWidget {
  const _BasicInfoStep({required this.data});

  final CreateCourseModel data;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CreateCourseCubit>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Course name
        _InputCard(
          icon: Icons.edit_outlined,
          title: 'Tên khóa học',
          required: true,
          child: TextFormField(
            initialValue: data.name,
            onChanged: cubit.updateCourseName,
            style: const TextStyle(fontSize: 16),
            decoration: const InputDecoration(
              hintText: 'VD: Thiết kế UI/UX từ cơ bản đến nâng cao',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Teaching format
        _SectionTitle(title: 'Định dạng giảng dạy', required: true),
        const SizedBox(height: 12),
        ...TeachingFormat.values.map((format) {
          final isSelected = data.teachingFormat == format;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _FormatCard(
              format: format,
              isSelected: isSelected,
              onTap: () => cubit.updateTeachingFormat(format),
            ),
          );
        }),
        const SizedBox(height: 16),
        // Category & Level
        Row(
          children: [
            Expanded(
              child: _InputCard(
                icon: Icons.category_outlined,
                title: 'Danh mục',
                child: DropdownButtonFormField<String>(
                  value: data.categoryId,
                  decoration: const InputDecoration(
                    hintText: 'Chọn',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: const [
                    DropdownMenuItem(value: '1', child: Text('Công nghệ')),
                    DropdownMenuItem(value: '2', child: Text('Kinh doanh')),
                    DropdownMenuItem(value: '3', child: Text('Thiết kế')),
                    DropdownMenuItem(value: '4', child: Text('Marketing')),
                  ],
                  onChanged: cubit.updateCategory,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InputCard(
                icon: Icons.signal_cellular_alt,
                title: 'Trình độ',
                child: DropdownButtonFormField<CourseLevel>(
                  value: data.level,
                  decoration: const InputDecoration(
                    hintText: 'Chọn',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: CourseLevel.values
                      .map((l) => DropdownMenuItem(value: l, child: Text(l.label)))
                      .toList(),
                  onChanged: (l) => l != null ? cubit.updateLevel(l) : null,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Short description
        _InputCard(
          icon: Icons.notes_outlined,
          title: 'Mô tả ngắn',
          trailing: Text(
            '${data.shortDescription.length}/200',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          child: TextFormField(
            initialValue: data.shortDescription,
            onChanged: cubit.updateShortDescription,
            maxLines: 3,
            maxLength: 200,
            buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
            style: const TextStyle(fontSize: 15),
            decoration: const InputDecoration(
              hintText: 'Mô tả ngắn gọn về khóa học của bạn...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _FormatCard extends StatelessWidget {
  const _FormatCard({
    required this.format,
    required this.isSelected,
    required this.onTap,
  });

  final TeachingFormat format;
  final bool isSelected;
  final VoidCallback onTap;

  IconData get _icon {
    return switch (format) {
      TeachingFormat.video => Icons.play_circle_filled,
      TeachingFormat.livestream => Icons.sensors,
      TeachingFormat.hybrid => Icons.auto_awesome,
    };
  }

  Color _getIconColor(ColorScheme cs) {
    if (isSelected) return cs.primary;
    return switch (format) {
      TeachingFormat.video => Colors.blue,
      TeachingFormat.livestream => Colors.red,
      TeachingFormat.hybrid => Colors.purple,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: isSelected ? cs.primaryContainer.withValues(alpha: 0.4) : cs.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? cs.primary : cs.outlineVariant.withValues(alpha: 0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getIconColor(cs).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_icon, size: 22, color: _getIconColor(cs)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      format.label,
                      style: tt.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      format.description,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? cs.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? cs.primary : cs.outlineVariant,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Step 2: Media & Description
// =============================================================================

class _MediaDescriptionStep extends StatelessWidget {
  const _MediaDescriptionStep({required this.data});

  final CreateCourseModel data;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cubit = context.read<CreateCourseCubit>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Thumbnail
        _SectionTitle(title: 'Ảnh bìa khóa học'),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Material(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () {
                // TODO: Pick image
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.5),
                    style: BorderStyle.solid,
                  ),
                ),
                child: data.thumbnailUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(data.thumbnailUrl!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 32,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Thêm ảnh bìa',
                            style: tt.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Kích thước đề xuất: 1280x720px',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Full description
        _InputCard(
          icon: Icons.description_outlined,
          title: 'Mô tả chi tiết',
          child: TextFormField(
            initialValue: data.fullDescription,
            onChanged: cubit.updateFullDescription,
            maxLines: 8,
            style: const TextStyle(fontSize: 15, height: 1.5),
            decoration: const InputDecoration(
              hintText: 'Mô tả chi tiết về nội dung khóa học, những gì học viên sẽ học được, yêu cầu tiên quyết...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// =============================================================================
// Step 3: Pricing
// =============================================================================

class _PricingStep extends StatelessWidget {
  const _PricingStep({required this.data});

  final CreateCourseModel data;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cubit = context.read<CreateCourseCubit>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Free toggle
        Material(
          color: data.isFree
              ? Colors.green.withValues(alpha: 0.1)
              : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => cubit.updateIsFree(!data.isFree),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: data.isFree ? Colors.green : cs.outlineVariant.withValues(alpha: 0.5),
                  width: data.isFree ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.card_giftcard,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Khóa học miễn phí',
                          style: tt.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Học viên có thể truy cập không giới hạn',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: data.isFree,
                    onChanged: cubit.updateIsFree,
                    activeTrackColor: Colors.green.shade300,
                    activeThumbColor: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!data.isFree) ...[
          const SizedBox(height: 24),
          _InputCard(
            icon: Icons.sell_outlined,
            title: 'Giá gốc',
            required: true,
            child: TextFormField(
              initialValue: data.price > 0 ? data.price.toStringAsFixed(0) : '',
              onChanged: (v) => cubit.updatePrice(double.tryParse(v) ?? 0),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: '0',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                suffixText: 'VNĐ',
                suffixStyle: TextStyle(
                  fontSize: 14,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _InputCard(
            icon: Icons.local_offer_outlined,
            title: 'Giá khuyến mãi',
            subtitle: 'Tùy chọn',
            child: TextFormField(
              initialValue: data.discountPrice?.toStringAsFixed(0) ?? '',
              onChanged: (v) => cubit.updateDiscountPrice(double.tryParse(v)),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Để trống nếu không có',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                suffixText: 'VNĐ',
                suffixStyle: TextStyle(
                  fontSize: 14,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Tip
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Đặt giá hợp lý để thu hút nhiều học viên hơn',
                    style: tt.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 80),
      ],
    );
  }
}

// =============================================================================
// Step 4: Complete
// =============================================================================

class _CompleteStep extends StatelessWidget {
  const _CompleteStep({required this.data});

  final CreateCourseModel data;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Success icon
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rocket_launch_outlined,
              size: 48,
              color: cs.primary,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Sẵn sàng tạo khóa học!',
          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Kiểm tra lại thông tin bên dưới',
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        // Summary card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              _SummaryRow(
                icon: Icons.school_outlined,
                label: 'Tên khóa học',
                value: data.name.isEmpty ? 'Chưa nhập' : data.name,
              ),
              _SummaryRow(
                icon: Icons.videocam_outlined,
                label: 'Định dạng',
                value: data.teachingFormat.label,
              ),
              _SummaryRow(
                icon: Icons.category_outlined,
                label: 'Danh mục',
                value: data.categoryId != null ? 'Đã chọn' : 'Chưa chọn',
              ),
              _SummaryRow(
                icon: Icons.signal_cellular_alt,
                label: 'Trình độ',
                value: data.level.label,
              ),
              _SummaryRow(
                icon: Icons.sell_outlined,
                label: 'Giá',
                value: data.isFree
                    ? 'Miễn phí'
                    : '${_formatPrice(data.price)} VNĐ',
                valueColor: data.isFree ? Colors.green : null,
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Note
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: cs.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sau khi tạo, bạn có thể thêm bài giảng và quản lý nội dung.',
                  style: tt.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    }
    return price.toStringAsFixed(0);
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      margin: EdgeInsets.only(bottom: isLast ? 0 : 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: cs.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: cs.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: tt.bodyMedium),
          ),
          Flexible(
            child: Text(
              value,
              style: tt.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Common Widgets
// =============================================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.required = false});

  final String title;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Text(
          title,
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (required)
          Text(' *', style: tt.titleSmall?.copyWith(color: cs.error)),
      ],
    );
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({
    required this.icon,
    required this.title,
    required this.child,
    this.required = false,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final bool required;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                title,
                style: tt.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (required)
                Text(' *', style: tt.labelMedium?.copyWith(color: cs.error)),
              if (subtitle != null) ...[
                const SizedBox(width: 4),
                Text(
                  '($subtitle)',
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
              if (trailing != null) ...[const Spacer(), trailing!],
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
