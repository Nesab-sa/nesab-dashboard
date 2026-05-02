import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nesab_dashboard/features/dashboard/data/repositories/categories_repository.dart';
import 'package:nesab_dashboard/features/dashboard/presentation/cubit/categories_cubit.dart';
import '../widgets/categories/categories_list_view.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CategoriesCubit(CategoriesRepository())..loadTopLevel(),
      child: const CategoriesListView(),
    );
  }
}
