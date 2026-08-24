import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:study/features/student/bloc/portfolio/portfolio_state.dart';

class PortfolioCubit extends Cubit<PortfolioState> {
  PortfolioCubit() : super(const PortfolioState());

  void initSections(List<PortfolioSection> sections) {
    if (state.sections.isNotEmpty) return;
    emit(state.copyWith(sections: sections));
  }

  void setProfile(PortfolioProfile profile) {
    emit(state.copyWith(profile: profile));
  }

  void toggleEditMode() {
    emit(state.copyWith(isEditMode: !state.isEditMode));
  }

  void setVisibility(String visibility) {
    emit(state.copyWith(visibility: visibility));
  }

  void toggleSectionVisibility(int index) {
    final sections = List<PortfolioSection>.from(state.sections);
    sections[index] = sections[index].copyWith(visible: !sections[index].visible);
    emit(state.copyWith(sections: sections));
  }

  void reorderSections(int oldIndex, int newIndex) {
    final sections = List<PortfolioSection>.from(state.sections);
    if (newIndex > oldIndex) newIndex--;
    final item = sections.removeAt(oldIndex);
    sections.insert(newIndex, item);
    emit(state.copyWith(sections: sections));
  }

  void updateProfile(PortfolioProfile profile) {
    emit(state.copyWith(profile: profile));
  }
}
