import 'package:flutter/material.dart';

import 'package:surdotv_app/features/catalog/models/video_item_model.dart';
import 'package:surdotv_app/widgets/video_card.dart';

class PagedVideoGrid extends StatefulWidget {
  const PagedVideoGrid({
    super.key,
    required this.videos,
    this.pageSize = 4,
  });

  final List<VideoItemModel> videos;
  final int pageSize;

  @override
  State<PagedVideoGrid> createState() => _PagedVideoGridState();
}

class _PagedVideoGridState extends State<PagedVideoGrid> {
  final PageController _pageController = PageController();
  int _activePage = 0;

  @override
  void didUpdateWidget(covariant PagedVideoGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldPageCount = _chunk(oldWidget.videos, oldWidget.pageSize).length;
    final newPageCount = _chunk(widget.videos, widget.pageSize).length;
    if (newPageCount == 0) {
      _activePage = 0;
      return;
    }
    if (_activePage >= newPageCount || oldPageCount != newPageCount) {
      _activePage = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videos.isEmpty) {
      return const SizedBox.shrink();
    }

    final pages = _chunk(widget.videos, widget.pageSize);
    final showIndicator = pages.isNotEmpty;
    final visibleIndicatorPages = _visibleIndicatorPageIndexes(pages.length);
    final width = MediaQuery.sizeOf(context).width;
    const horizontalPadding = 32.0;
    const crossAxisSpacing = 8.0;
    const mainAxisSpacing = 10.0;
    const aspectRatio = 100 / 80;

    final tileWidth = (width - horizontalPadding - crossAxisSpacing) / 2;
    final tileHeight = tileWidth / aspectRatio;
    final rowsPerPage = (widget.pageSize / 2).ceil();
    final gridHeight =
        (rowsPerPage * tileHeight) + ((rowsPerPage - 1) * mainAxisSpacing);

    return Column(
      children: [
        SizedBox(
          height: gridHeight,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _activePage = index;
              });
            },
            itemCount: pages.length,
            itemBuilder: (context, pageIndex) {
              final pageItems = pages[pageIndex];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  primary: false,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: crossAxisSpacing,
                    mainAxisSpacing: mainAxisSpacing,
                    childAspectRatio: aspectRatio,
                  ),
                  itemCount: pageItems.length,
                  itemBuilder: (context, index) =>
                      VideoCard(video: pageItems[index]),
                ),
              );
            },
          ),
        ),
        if (showIndicator) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: visibleIndicatorPages
                .map(
                  (pageIndex) => GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        pageIndex,
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _activePage == pageIndex
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  List<List<VideoItemModel>> _chunk(List<VideoItemModel> list, int size) {
    final result = <List<VideoItemModel>>[];
    for (var i = 0; i < list.length; i += size) {
      result.add(
          list.sublist(i, i + size > list.length ? list.length : i + size));
    }
    return result;
  }

  List<int> _visibleIndicatorPageIndexes(int totalPages) {
    if (totalPages <= 3) {
      return List<int>.generate(totalPages, (index) => index);
    }

    if (_activePage <= 1) {
      return const [0, 1, 2];
    }

    if (_activePage >= totalPages - 2) {
      return [totalPages - 3, totalPages - 2, totalPages - 1];
    }

    return [_activePage - 1, _activePage, _activePage + 1];
  }
}
