import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:surdotv_app/core/constants/layout_constants.dart';
import 'package:surdotv_app/features/catalog/viewmodels/catalog_viewmodel.dart';
import 'package:surdotv_app/widgets/common_widgets.dart';
import 'package:surdotv_app/widgets/video_card.dart';

class CategoryDetailScreen extends StatelessWidget {
  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
  });

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final catalogVm = context.watch<CatalogViewModel>();
    final category = catalogVm.categoryById(categoryId);
    final childCategories = catalogVm.childCategoriesOf(categoryId);
    final videos = catalogVm.videosForCategory(categoryId);

    if (category == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyStateView(message: 'Bölmə tapılmadı.'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const AppLogo(height: 24),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              category.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (childCategories.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: childCategories.map((child) {
                  return FilterChip(
                    label: Text(child.name),
                    selected: false,
                    onSelected: (_) {
                      context.pushReplacement(
                          '/main/categories/detail/${child.id}');
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),
          ],
          if (videos.isEmpty)
            const EmptyStateView(message: 'Bu bölmədə video tapılmadı.')
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 16,
                  childAspectRatio: LayoutConstants.thumbnailAspectRatio,
                ),
                itemCount: videos.length,
                itemBuilder: (context, index) =>
                    VideoCard(video: videos[index]),
              ),
            ),
        ],
      ),
    );
  }
}
