import 'package:flutter/material.dart';
import 'package:study/theme/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trung tâm hỗ trợ'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.primary.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              children: [
                Icon(Icons.support_agent_rounded, size: 48, color: cs.onPrimary),
                const SizedBox(height: 12),
                Text(
                  'Chúng tôi có thể giúp gì cho bạn?',
                  style: tt.titleMedium?.copyWith(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Contact options
          Text(
            'Liên hệ hỗ trợ',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _ContactCard(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: 'support@40study.com',
            onTap: () => _launchEmail(context),
          ),
          const SizedBox(height: 8),
          _ContactCard(
            icon: Icons.phone_outlined,
            title: 'Hotline',
            subtitle: '1900 xxxx xx',
            onTap: () => _launchPhone(context),
          ),
          const SizedBox(height: 8),
          _ContactCard(
            icon: Icons.chat_outlined,
            title: 'Chat trực tuyến',
            subtitle: 'Phản hồi trong vài phút',
            onTap: () {
              // TODO: Open chat
            },
          ),
          const SizedBox(height: 24),

          // FAQ
          Text(
            'Câu hỏi thường gặp',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const _FaqItem(
            question: 'Làm sao để đổi mật khẩu?',
            answer: 'Vào Tài khoản > Mật khẩu & Bảo mật > Đổi mật khẩu để thay đổi mật khẩu của bạn.',
          ),
          const _FaqItem(
            question: 'Tôi quên mật khẩu, phải làm sao?',
            answer: 'Tại màn hình đăng nhập, nhấn "Quên mật khẩu" và làm theo hướng dẫn để đặt lại mật khẩu qua email.',
          ),
          const _FaqItem(
            question: 'Làm sao để xem chứng chỉ đã nhận?',
            answer: 'Vào tab Thành tích để xem tất cả chứng chỉ bạn đã đạt được.',
          ),
          const _FaqItem(
            question: 'Tôi muốn hoàn tiền khóa học?',
            answer: 'Liên hệ với chúng tôi qua email hoặc hotline trong vòng 7 ngày kể từ ngày mua để được hỗ trợ hoàn tiền.',
          ),
          const SizedBox(height: 24),

          // App info
          Center(
            child: Text(
              'Phiên bản 1.2.0',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _launchEmail(BuildContext context) async {
    final uri = Uri(scheme: 'mailto', path: 'support@40study.com');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchPhone(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: '1900000000');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: cs.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: cs.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      subtitle,
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Text(
                widget.answer,
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
