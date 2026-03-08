import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:surdotv_app/features/catalog/models/category_model.dart';
import 'package:surdotv_app/features/catalog/models/video_item_model.dart';
import 'package:surdotv_app/features/catalog/viewmodels/catalog_viewmodel.dart';
import 'package:surdotv_app/widgets/common_widgets.dart';
import 'package:surdotv_app/widgets/paged_video_grid.dart';
import 'package:surdotv_app/widgets/video_card.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({
    super.key,
    this.initialCategoryId,
  });

  final String? initialCategoryId;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedCategoryId = '';
  String _selectedSubCategoryId = '';
  int _visibleCount = 10;
  bool _showUpButton = false;
  bool _appliedInitialCategory = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<CatalogViewModel>();
      if (vm.categories.isEmpty && !vm.viewState.isLoading) {
        vm.fetchCatalog();
      }
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_selectedCategoryId.isEmpty || !_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    final max = position.maxScrollExtent;
    if (max <= 0) return;

    final showUp = position.pixels > max * 0.2;
    if (showUp != _showUpButton) {
      setState(() {
        _showUpButton = showUp;
      });
    }

    if (position.pixels >= max - 80) {
      setState(() {
        _visibleCount += 10;
      });
    }
  }

  void _selectCategory(String categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedSubCategoryId = '';
      _visibleCount = 10;
      _showUpButton = false;
    });
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedCategoryId = '';
      _selectedSubCategoryId = '';
      _visibleCount = 10;
      _showUpButton = false;
    });
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  List<VideoItemModel> _selectedVideos(CatalogViewModel vm) {
    if (_selectedCategoryId.isEmpty) {
      return const [];
    }
    var videos = vm.videosForCategory(_selectedCategoryId);
    if (_selectedSubCategoryId.isNotEmpty) {
      videos = videos
          .where((video) => video.categoryId == _selectedSubCategoryId)
          .toList();
    }
    return videos;
  }

  Widget _overview(CatalogViewModel vm) {
    final categories = vm.rootCategories;
    if (categories.isEmpty) {
      return const EmptyStateView(
          message: 'Hazırda göstəriləcək bölmə tapılmadı.');
    }

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: categories
                .map(
                  (category) => OutlinePillButton(
                    text: category.name,
                    onPressed: () => _selectCategory(category.id),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        ...categories.map((category) => _categoryBlock(vm, category)),
      ],
    );
  }

  Widget _categoryBlock(CatalogViewModel vm, CategoryModel category) {
    final allVideos = vm.videosForCategory(category.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: category.name,
          subtitle: '${allVideos.length} video',
          onActionTap: () => _selectCategory(category.id),
          actionLabel: 'Hamısına bax',
        ),
        if (allVideos.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Bu bölmədə video yoxdur.'),
          )
        else
          PagedVideoGrid(videos: allVideos),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _selectedCategoryView(CatalogViewModel vm) {
    final selectedCategory = vm.categoryById(_selectedCategoryId);
    if (selectedCategory == null) {
      return const EmptyStateView(message: 'Bölmə tapılmadı.');
    }

    final subCategories = vm.childCategoriesOf(_selectedCategoryId);
    final allVideos = _selectedVideos(vm);
    final visible = allVideos.take(_visibleCount).toList();

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        ListView(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                selectedCategory.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (subCategories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinePillButton(
                      text: 'Hamısı',
                      onPressed: () {
                        setState(() {
                          _selectedSubCategoryId = '';
                          _visibleCount = 10;
                        });
                      },
                    ),
                    ...subCategories.map(
                      (subcategory) => OutlinePillButton(
                        text: subcategory.name,
                        onPressed: () {
                          setState(() {
                            _selectedSubCategoryId = subcategory.id;
                            _visibleCount = 10;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            if (visible.isEmpty)
              const EmptyStateView(message: 'Bu bölmədə video tapılmadı.')
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  primary: false,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 10,
                    childAspectRatio: 100 / 80,
                  ),
                  itemCount: visible.length,
                  itemBuilder: (context, index) =>
                      VideoCard(video: visible[index]),
                ),
              ),
          ],
        ),
        if (_showUpButton)
          Padding(
            padding: const EdgeInsets.all(20),
            child: FloatingActionButton(
              onPressed: () {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                  );
                }
              },
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
              child: const Icon(Icons.arrow_upward),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogVm = context.watch<CatalogViewModel>();

    if (!_appliedInitialCategory &&
        widget.initialCategoryId != null &&
        widget.initialCategoryId!.isNotEmpty &&
        catalogVm.categories.isNotEmpty) {
      _appliedInitialCategory = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _selectCategory(widget.initialCategoryId!);
      });
    }

    return PopScope(
      canPop: _selectedCategoryId.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedCategoryId.isNotEmpty) {
          _clearSelection();
        }
      },
      child: Scaffold(
        appBar: SurdoLogoAppBar(
          leading: _selectedCategoryId.isEmpty
              ? null
              : IconButton(
                  onPressed: _clearSelection,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
        ),
        body: catalogVm.viewState.when(
          loading: () => const LoadingView(),
          error: (message) => ErrorStateView(
            message: message,
            onRetry: catalogVm.fetchCatalog,
          ),
          success: (_) => RefreshIndicator(
            onRefresh: catalogVm.fetchCatalog,
            child: _selectedCategoryId.isEmpty
                ? _overview(catalogVm)
                : _selectedCategoryView(catalogVm),
          ),
        ),
      ),
    );
  }
}
