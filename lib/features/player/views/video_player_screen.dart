import 'package:flutter/material.dart';
import 'package:flutter_bunny_embed_player/flutter_bunny_embed_player.dart';

import 'package:surdotv_app/features/catalog/models/video_item_model.dart';

class BunnyEmbedPlayerScreen extends StatefulWidget {
  const BunnyEmbedPlayerScreen({
    super.key,
    required this.video,
  });

  final VideoItemModel video;

  @override
  State<BunnyEmbedPlayerScreen> createState() => _BunnyEmbedPlayerScreenState();
}

class _BunnyEmbedPlayerScreenState extends State<BunnyEmbedPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return BunnyEmbedPlayerPage(
      playerUrl: widget.video.playbackUrl,
      title: widget.video.title,
    );
  }
}
