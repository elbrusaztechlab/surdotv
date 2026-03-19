import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class BunnyEmbedPlayerPage extends StatefulWidget {
  const BunnyEmbedPlayerPage({
    super.key,
    required this.playerUrl,
    required this.title,
    this.aspectRatio = 16 / 9,
  });

  final String playerUrl;
  final String title;
  final double aspectRatio;

  @override
  State<BunnyEmbedPlayerPage> createState() => _BunnyEmbedPlayerPageState();
}

class _BunnyEmbedPlayerPageState extends State<BunnyEmbedPlayerPage> {
  late final WebViewController _controller;
  Uri? _playerUri;

  int _loadingProgress = 0;
  String? _errorMessage;
  bool _isClosing = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _playerUri = _parsePlayerUri(widget.playerUrl);
    _errorMessage = _playerUri == null ? 'Video linki tapilmadi.' : null;
    _controller = _createController();
    if (_playerUri != null) {
      _controller.loadRequest(_playerUri!);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(_stopPlayback());
    super.dispose();
  }

  WebViewController _createController() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted || _isDisposed) return;
            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageStarted: (_) {
            if (!mounted || _isDisposed) return;
            setState(() {
              _errorMessage = null;
            });
          },
          onPageFinished: (_) {
            if (!mounted || _isDisposed) return;
            setState(() {
              _loadingProgress = 100;
            });
          },
          onWebResourceError: (error) {
            final isMainFrame = error.isForMainFrame ?? true;
            if (!mounted || _isDisposed || !isMainFrame) return;
            setState(() {
              _errorMessage = error.description;
            });
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) {
              return NavigationDecision.prevent;
            }

            if (uri.scheme == 'http' || uri.scheme == 'https') {
              return NavigationDecision.navigate;
            }

            return NavigationDecision.prevent;
          },
        ),
      );

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(kDebugMode);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    return controller;
  }

  Uri? _parsePlayerUri(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasScheme) {
      return null;
    }

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return null;
    }

    return uri;
  }

  // Future<void> _reload() async {
  //   if (!mounted || _isDisposed || _playerUri == null) return;
  //   setState(() {
  //     _errorMessage = null;
  //     _loadingProgress = 0;
  //   });
  //   await _controller.loadRequest(_playerUri!);
  // }

  Future<void> _handleClose() async {
    if (_isClosing) return;
    _isClosing = true;
    await _stopPlayback();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _stopPlayback() async {
    try {
      await _controller.runJavaScript('''
        (async function() {
          try {
            if (document.fullscreenElement && document.exitFullscreen) {
              await document.exitFullscreen();
            }
          } catch (_) {}

          try {
            document.querySelectorAll('video').forEach(function(video) {
              try {
                video.pause();
                video.removeAttribute('src');
                video.load();
              } catch (_) {}
            });
          } catch (_) {}

          try {
            document.querySelectorAll('iframe').forEach(function(iframe) {
              try {
                iframe.src = 'about:blank';
              } catch (_) {}
            });
          } catch (_) {}

          try {
            document.body.innerHTML = '';
          } catch (_) {}
        })();
      ''').timeout(const Duration(milliseconds: 400));
    } catch (_) {}

    try {
      await _controller
          .loadHtmlString(
            '<html><body style="margin:0;background:#000;"></body></html>',
          )
          .timeout(const Duration(milliseconds: 400));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) return;
        unawaited(_stopPlayback());
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _handleClose,
                      icon: const Icon(Icons.close_rounded),
                      color: Colors.white,
                    ),
                    Expanded(
                      child: Text(
                        widget.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: widget.aspectRatio,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: DecoratedBox(
                        decoration: const BoxDecoration(color: Colors.black),
                        child: _buildPlayerBody(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerBody() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white54,
                size: 36,
              ),
              const SizedBox(height: 12),
              Text(
                'Video tapılmadı.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              // const SizedBox(height: 16),
              // FilledButton(
              //   onPressed: _reload,
              //   child: const Text('Yenidən Yüklə'),
              // ),
            ],
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        WebViewWidget(controller: _controller),
        if (_loadingProgress < 100) const ColoredBox(color: Colors.black),
        if (_loadingProgress < 100)
          Center(
            child: CircularProgressIndicator(
              value: _loadingProgress > 0 ? _loadingProgress / 100 : null,
              color: Colors.white,
            ),
          ),
      ],
    );
  }
}
