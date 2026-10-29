import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_models/shared_models.dart';

import 'load_status.dart';

/// State of the Categories tab (the list of medicine categories).
class CategoriesState extends Equatable {
  const CategoriesState({
    this.status = LoadStatus.initial,
    this.categories = const [],
    this.error,
  });

  final LoadStatus status;
  final List<Category> categories;
  final String? error;

  CategoriesState copyWith({
    LoadStatus? status,
    List<Category>? categories,
    String? error,
  }) =>
      CategoriesState(
        status: status ?? this.status,
        categories: categories ?? this.categories,
        error: error,
      );

  @override
  List<Object?> get props => [status, categories, error];
}

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit(this._catalog) : super(const CategoriesState());

  final CatalogRepository _catalog;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading));
    final result = await _catalog.getCategories();
    if (isClosed) return;
    result.when(
      onSuccess: (categories) => emit(
        state.copyWith(
          status: LoadStatus.loaded,
          categories: categories,
        ),
      ),
      onFailure: (message, _) =>
          emit(state.copyWith(status: LoadStatus.error, error: message)),
    );
  }
}
