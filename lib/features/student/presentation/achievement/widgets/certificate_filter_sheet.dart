import 'package:flutter/material.dart';
import 'package:study/l10n/app_localizations.dart';
import 'package:study/widgets/filter_sheet.dart';

/// Certificate filter - dùng FilterSheet
Future<({String status, String category})?> showCertificateFilterSheet(
  BuildContext context, {
  String initialStatus = 'all',
  String initialCategory = 'all',
}) {
  final l10n = AppLocalizations.of(context)!;
  return FilterSheet.show(
    context,
    statusOptions: {
      'all': l10n.all,
      'completed': l10n.completed,
      'inProgress': l10n.studying,
    },
    categoryOptions: {
      'all': l10n.all,
      'design': l10n.design,
      'programming': l10n.programming,
      'business': l10n.business,
      'language': l10n.language,
    },
    initialStatus: initialStatus,
    initialCategory: initialCategory,
  );
}

// ponytail: giữ class cũ cho backward compat, remove khi caller migrate sang function
/// @Deprecated('Use showCertificateFilterSheet instead')
class CertificateFilterSheet extends StatelessWidget {
  const CertificateFilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FilterSheet(
      statusOptions: {
        'all': l10n.all,
        'completed': l10n.completed,
        'inProgress': l10n.studying,
      },
      categoryOptions: {
        'all': l10n.all,
        'design': l10n.design,
        'programming': l10n.programming,
        'business': l10n.business,
        'language': l10n.language,
      },
    );
  }
}
