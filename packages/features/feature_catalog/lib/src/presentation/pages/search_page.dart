import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_models/shared_models.dart';

import '../state/load_status.dart';
import '../state/search_cubit.dart';
import '../widgets/product_grid.dart';
import '../widgets/product_list_skeleton.dart';

/// Debounced search over brand, generic name and salt composition.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchCubit(
        GetIt.instance<CatalogRepository>(),
        GetIt.instance<CartRepository>(),
      ),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _controller = TextEditingController();
  bool _prefilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    final query = GoRouterState.of(
      context,
    ).uri.queryParameters[RoutePaths.searchQueryParam];
    if (query != null && query.isNotEmpty) {
      _controller.text = query;
      context.read<SearchCubit>().onQueryChanged(query);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search medicines')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _controller,
              autofocus: _controller.text.isEmpty,
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                context.read<SearchCubit>().onQueryChanged(value);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Try “dolo” or “paracetamol”',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          context.read<SearchCubit>().onQueryChanged('');
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                if (state.query.trim().isEmpty) {
                  return const EmptyState(
                    icon: Icons.search,
                    title: 'Search medicines',
                    message: 'Find by brand, generic name or salt composition.',
                  );
                }
                switch (state.status) {
                  case LoadStatus.initial:
                  case LoadStatus.loading:
                    return const ProductListSkeleton(count: 4);
                  case LoadStatus.error:
                    return EmptyState(
                      icon: Icons.error_outline,
                      title: 'Search failed',
                      message: state.error,
                    );
                  case LoadStatus.loaded:
                    if (state.results.isEmpty) {
                      return EmptyState(
                        icon: Icons.search_off,
                        title: 'No medicines match “${state.query}”',
                        message: 'Check the spelling or try a salt name.',
                      );
                    }
                    final cubit = context.read<SearchCubit>();
                    return ProductGrid(
                      products: state.results,
                      cartQty: state.cartQty,
                      onAdd: cubit.add,
                      onQtyChanged: cubit.setQty,
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
