part of 'voucher_cubit.dart';

@immutable
sealed class VoucherState extends Equatable {
  const VoucherState();

  @override
  List<Object?> get props => [];
}

final class VoucherInitial extends VoucherState {
  const VoucherInitial();
}

final class VoucherLoading extends VoucherState {
  const VoucherLoading();
}

final class VoucherLoaded extends VoucherState {
  const VoucherLoaded({
    required this.publicVouchers,
    required this.savedVouchers,
    this.isSearching = false,
    this.searchedVoucher,
    this.errorMessage,
  });

  final List<VoucherModel> publicVouchers;
  final List<VoucherModel> savedVouchers;
  final bool isSearching;
  final VoucherModel? searchedVoucher;
  final String? errorMessage;

  VoucherLoaded copyWith({
    List<VoucherModel>? publicVouchers,
    List<VoucherModel>? savedVouchers,
    bool? isSearching,
    VoucherModel? searchedVoucher,
    String? errorMessage,
  }) {
    return VoucherLoaded(
      publicVouchers: publicVouchers ?? this.publicVouchers,
      savedVouchers: savedVouchers ?? this.savedVouchers,
      isSearching: isSearching ?? this.isSearching,
      searchedVoucher: searchedVoucher,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        publicVouchers,
        savedVouchers,
        isSearching,
        searchedVoucher,
        errorMessage,
      ];
}

final class VoucherFailure extends VoucherState {
  const VoucherFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
