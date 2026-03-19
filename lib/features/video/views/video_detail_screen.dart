import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:surdotv_app/core/router/route_constants.dart';
import 'package:surdotv_app/features/catalog/models/video_item_model.dart';
import 'package:surdotv_app/features/catalog/viewmodels/catalog_viewmodel.dart';
import 'package:surdotv_app/features/video/viewmodels/video_detail_viewmodel.dart';
import 'package:surdotv_app/widgets/common_widgets.dart';

class VideoDetailScreen extends StatefulWidget {
  const VideoDetailScreen({
    super.key,
    required this.videoId,
  });

  final String videoId;

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  final ScrollController _listScrollController = ScrollController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VideoDetailViewModel>().fetchVideo(widget.videoId);
    });
  }

  void _goNext(List<VideoItemModel> items) {
    if (items.length <= 1) return;
    _carouselController.nextPage();
  }

  @override
  Widget build(BuildContext context) {
    final catalogVm = context.watch<CatalogViewModel>();
    final detailVm = context.watch<VideoDetailViewModel>();

    return detailVm.viewState.when(
      loading: () => Scaffold(
        appBar: SurdoLogoAppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: const LoadingView(),
      ),
      success: (video) => _DetailBody(
        key: ValueKey('loaded-${video.id}'),
        primaryVideo: video,
        similarVideos: catalogVm.similarVideos(video.id, limit: 8),
        selectedIndex: _selectedIndex,
        onSelectedIndexChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        onGoNext: _goNext,
        carouselController: _carouselController,
        listScrollController: _listScrollController,
      ),
      error: (message) => Scaffold(
        appBar: SurdoLogoAppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: ErrorStateView(
          message: 'Video tapılmadı.',
          onRetry: () => detailVm.fetchVideo(widget.videoId),
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    super.key,
    required this.primaryVideo,
    required this.similarVideos,
    required this.selectedIndex,
    required this.onSelectedIndexChanged,
    required this.onGoNext,
    required this.carouselController,
    required this.listScrollController,
  });

  final VideoItemModel primaryVideo;
  final List<VideoItemModel> similarVideos;
  final int selectedIndex;
  final ValueChanged<int> onSelectedIndexChanged;
  final void Function(List<VideoItemModel>) onGoNext;
  final CarouselSliderController carouselController;
  final ScrollController listScrollController;

  @override
  Widget build(BuildContext context) {
    final allItems = <VideoItemModel>[
      primaryVideo,
      ...similarVideos.where((item) => item.id != primaryVideo.id),
    ];
    final currentIndex = allItems.isEmpty
        ? 0
        : selectedIndex.clamp(0, allItems.length - 1).toInt();
    final current = allItems[currentIndex];

    return Scaffold(
      appBar: SurdoLogoAppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 150,
                color: Theme.of(context).colorScheme.primary,
              ),
              CarouselSlider(
                carouselController: carouselController,
                options: CarouselOptions(
                  height: 200,
                  enlargeCenterPage: true,
                  onPageChanged: (index, reason) {
                    onSelectedIndexChanged(index);
                    if (listScrollController.hasClients) {
                      listScrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                ),
                items: allItems.map((item) {
                  return Stack(
                    children: [
                      Center(
                        child: SizedBox(
                          height: 200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: AppNetworkImage(
                              imageUrl: item.imageUrl,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: InkWell(
                            onTap: () {
                              context.push(AppRoutes.videoPlayer.path,
                                  extra: item);
                            },
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 52,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              controller: listScrollController,
              children: [
                const SizedBox(height: 10),
                ListTile(
                  title: Text(
                    current.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      children: [
                        _meta(
                            context, Icons.calendar_today, current.publishedAt),
                        _meta(
                          context,
                          Icons.remove_red_eye_outlined,
                          '${current.viewCount} baxış',
                        ),
                      ],
                    ),
                  ),
                  trailing: InkWell(
                    onTap: () => onGoNext(allItems),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Digər',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 17,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                if (current.plainDescription.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      current.plainDescription,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.justify,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _meta(BuildContext context, IconData icon, String value) {
    if (value.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.black45),
        const SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
        ),
      ],
    );
  }
}
