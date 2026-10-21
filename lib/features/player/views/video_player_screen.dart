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
    if (!widget.video.hasVideo) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(widget.video.title),
        ),
        body: const Center(
          child: Text(
            'Video mövcud deyil.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    // `playbackUrl` prefers `video_url2` (video.eee.az/play/<uuid>). That page
    // plays HLS from cdn.eee.az and falls back to the Bunny embed by itself.
    return BunnyEmbedPlayerPage(
      playerUrl: widget.video.playbackUrl,
      title: widget.video.title,
    );
  }
}
