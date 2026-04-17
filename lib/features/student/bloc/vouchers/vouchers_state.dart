import 'package:equatable/equatable.dart';
import 'package:study/features/student/data/models/models.dart';

sealed class VouchersState extends Equatable {
  const VouchersState();

  @override
  List<Object?> get props => [];
}

final class VouchersInitial extends VouchersState {
  const VouchersInitial();
}

final class VouchersLoading extends VouchersState {
  const VouchersLoading();
}

final class VouchersLoaded extends VouchersState {
  const VouchersLoaded({
    required this.publicVouchers,
    required this.savedVouchers,
    this.showSavedOnly = false,
  });

  final List<VoucherModel> publicVouchers;
  final List<VoucherModel> savedVouchers;
  final bool showSavedOnly;

  /// Voucher dang hien thi.
  List<VoucherModel> get displayedVouchers {
    if (showSavedOnly) return savedVouchers;

    // Merge public va saved, danh dau saved
    final savedIds = savedVouchers.map((v) => v.id).toSet();
    return publicVouchers.map((v) {
      if (savedIds.contains(v.id)) {
        return v.copyWith(isSaved: true);
      }
      return v;
    }).toList();
  }

  VouchersLoaded copyWith({
    List<VoucherModel>? publicVouchers,
    List<VoucherModel>? savedVouchers,
    bool? showSavedOnly,
  }) {
    return VouchersLoaded(
      publicVouchers: publicVouchers ?? this.publicVouchers,
      savedVouchers: savedVouchers ?? this.savedVouchers,
      showSavedOnly: showSavedOnly ?? this.showSavedOnly,
    );
  }

  @override
  List<Object?> get props => [publicVouchers, savedVouchers, showSavedOnly];
}

final class VouchersError extends VouchersState {
  const VouchersError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
