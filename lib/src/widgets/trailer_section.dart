import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'package:ytsmovies/src/utils/constants.dart';

/// Inline YouTube trailer player. Caller is responsible for deciding when to
/// render this (e.g. only on mobile, where the iframe embed works reliably).
class TrailerSection extends StatefulWidget {
  /// Raw YouTube video ID (e.g. `dQw4w9WgXcQ`), not a full URL.
  final String videoId;

  const TrailerSection({super.key, required this.videoId});

  @override
  State<TrailerSection> createState() => _TrailerSectionState();
}

class _TrailerSectionState extends State<TrailerSection> with RouteAware {
  late final YoutubePlayerController _controller;
  bool _wasPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        mute: false,
        loop: false,
        enableCaption: true,
        showFullscreenButton: true,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) routeObserver.subscribe(this, route);
  }

  @override
  void deactivate() {
    _controller.pauseVideo();
    super.deactivate();
  }

  @override
  void reassemble() {
    _controller.pauseVideo();
    super.reassemble();
  }

  @override
  void didPushNext() {
    if (_controller.value.playerState.code == PlayerState.playing.code) {
      _wasPlaying = true;
      _controller.pauseVideo();
    }
  }

  @override
  void didPopNext() {
    if (_wasPlaying) _controller.playVideo();
  }

  @override
  void dispose() {
    _controller.close();
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Trailer', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: YoutubePlayer(
            controller: _controller,
            aspectRatio: 16 / 9,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

/// External-launch button for the trailer. Used on platforms where the inline
/// YouTube iframe embed is unreliable (e.g. Windows desktop / WebView2).
class TrailerLauncherButton extends StatelessWidget {
  /// Raw YouTube video ID (e.g. `dQw4w9WgXcQ`), not a full URL.
  final String videoId;

  const TrailerLauncherButton({super.key, required this.videoId});

  Future<void> _open() async {
    final uri = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      log('Could not launch trailer URL: $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Trailer', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: _open,
            icon: const Icon(Icons.play_circle_outline),
            label: const Text('Watch trailer on YouTube'),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
