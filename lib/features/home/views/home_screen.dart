import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:surdotv_app/core/constants/layout_constants.dart';
import 'package:surdotv_app/core/router/route_constants.dart';
import 'package:surdotv_app/features/catalog/models/category_model.dart';
import 'package:surdotv_app/features/home/viewmodels/home_viewmodel.dart';
import 'package:surdotv_app/widgets/common_widgets.dart';
import 'package:surdotv_app/widgets/paged_video_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<HomeViewModel>();
      if (vm.viewState.valueOrNull == null && !vm.viewState.isLoading) {
        vm.fetchHome();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeVm = context.watch<HomeViewModel>();

    return Scaffold(
      appBar: const SurdoLogoAppBar(),
      body: homeVm.viewState.when(
        loading: () => const LoadingView(),
        error: (message) => ErrorStateView(
          message: message,
          onRetry: homeVm.fetchHome,
        ),
        success: (_) => RefreshIndicator(
          onRefresh: homeVm.fetchHome,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              if (homeVm.sliderItems.isNotEmpty) ...[
                _HeroCarousel(),
                const SizedBox(height: LayoutConstants.sectionSpacing),
              ],
              if (homeVm.featuredCategories.isNotEmpty) ...[
                SectionHeader(
                  title: homeVm.featuredCategories.first.name,
                  subtitle:
                      '${homeVm.featuredCategories.first.videos.length} video',
                  onActionTap: () {
                    final category = homeVm.featuredCategories.first;
                    context.push(
                        '${AppRoutes.mainCategories.path}/detail/${category.id}');
                  },
                ),
                _CategoryPreviewGrid(category: homeVm.featuredCategories.first),
                if (homeVm.featuredCategories.length > 1) ...[
                  const SizedBox(height: LayoutConstants.sectionSpacing),
                  const SponsorStrip(),
                  const SizedBox(height: LayoutConstants.sectionSpacing),
                  SectionHeader(
                    title: homeVm.featuredCategories[1].name,
                    subtitle:
                        '${homeVm.featuredCategories[1].videos.length} video',
                    onActionTap: () {
                      final category = homeVm.featuredCategories[1];
                      context.push(
                          '${AppRoutes.mainCategories.path}/detail/${category.id}');
                    },
                  ),
                  _CategoryPreviewGrid(category: homeVm.featuredCategories[1]),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = context.watch<HomeViewModel>().sliderItems;
    final isTablet =
        MediaQuery.sizeOf(context).width >= LayoutConstants.breakpointTablet;

    return CarouselSlider(
      options: CarouselOptions(
        height: isTablet
            ? LayoutConstants.heroCarouselHeightTablet
            : LayoutConstants.heroCarouselHeightPhone,
        viewportFraction: isTablet ? 0.7 : 0.82,
        autoPlay: items.length > 1,
        enlargeCenterPage: true,
      ),
      items: items.map((video) {
        return InkWell(
          borderRadius: BorderRadius.circular(LayoutConstants.cardRadius),
          onTap: () =>
              context.push('${AppRoutes.videoDetail.path}/${video.id}'),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppNetworkImage(imageUrl: video.imageUrl),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(LayoutConstants.cardRadius),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.18),
                      Colors.black.withValues(alpha: 0.72),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _CategoryPreviewGrid extends StatelessWidget {
  const _CategoryPreviewGrid({
    required this.category,
  });

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final items = category.videos;
    if (items.isEmpty) {
      return const EmptyStateView(message: 'Bu bölmədə hələ video yoxdur.');
    }

    return PagedVideoGrid(videos: items);
  }
}
