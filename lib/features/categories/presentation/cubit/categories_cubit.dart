import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesab/features/categories/domain/repositories/categories_repository.dart';
import 'package:nesab/features/categories/presentation/cubit/categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit(this._repository) : super(const CategoriesInitial());

  final CategoriesRepository _repository;

  /// Loads top-level categories from Firestore only. No local fallback.
  Future<void> loadTopLevelCategories() async {
    emit(const CategoriesLoading());
    try {
      final list = await _repository.getTopLevelCategories();
      emit(CategoriesLoaded(list));
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }
}
