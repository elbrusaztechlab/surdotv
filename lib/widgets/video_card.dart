import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:surdotv_app/core/constants/layout_constants.dart';
import 'package:surdotv_app/core/router/route_constants.dart';
import 'package:surdotv_app/features/catalog/models/video_item_model.dart';
import 'package:surdotv_app/widgets/common_widgets.dart';

class VideoCard extends StatelessWidget {
  const VideoCard({
    super.key,
    required this.video,
  });

  final VideoItemModel video;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(LayoutConstants.cardRadius),
      onTap: () => context.push('${AppRoutes.videoDetail.path}/${video.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                AppNetworkImage(
                  imageUrl: video.imageUrl,
                  fit: BoxFit.fill,
                ),
                Center(
                  child: Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.16),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 34,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            video.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 15,
                ),
          ),
          if (video.duration.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              video.duration,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
