import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';

class VideoDialog extends StatefulWidget {
  const VideoDialog({required this.url});

  final String url;

  @override
  State<VideoDialog> createState() => _VideoDialogState();
}

class _VideoDialogState extends State<VideoDialog> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      _controller = VideoPlayerController.network(widget.url);
      await _controller?.initialize();
      if (!mounted) return;
      setState(() => _isInitialized = true);
      // listen for playback errors (network/404 etc.)
      _controller?.addListener(_onPlayerUpdate);
      try {
        await _controller?.play();
      } catch (_) {
        if (!mounted) return;
        setState(() => _hasError = true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  void _onPlayerUpdate() {
    final value = _controller?.value;
    if (value == null) return;
    // VideoPlayerValue.hasError is set when playback error occurs
    if (value.hasError) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onPlayerUpdate);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.9;

    if (_hasError) {
      return SizedBox(
        width: maxWidth,
        child: Container(
          color: AppColors.onSurface.withValues(alpha: 0.04),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 56, color: Colors.red),
              const SizedBox(height: 12),
              Text('تعذر تشغيل الفيديو داخل التطبيق', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('يمكنك فتح الفيديو بتطبيق خارجي أو نسخ الرابط.', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri.tryParse(widget.url);
                        if (uri != null && await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر فتح الرابط: لا يوجد تطبيق مناسب')));
                        }
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('فتح في تطبيق خارجي'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: widget.url));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ الرابط')));
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('نسخ الرابط'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('إغلاق')),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: maxWidth,
      child: AspectRatio(
        aspectRatio: _controller?.value.aspectRatio ?? 16 / 9,
        child: Stack(
          children: [
            if (_isInitialized && _controller != null)
              VideoPlayer(_controller!)
            else
              Container(color: AppColors.onSurface.withValues(alpha: 0.04)),
            Positioned(
              left: 8,
              top: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            if (_isInitialized)
              Center(
                child: IconButton(
                  iconSize: 56,
                  icon: Icon(
                    _controller!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_controller!.value.isPlaying) {
                        _controller!.pause();
                      } else {
                        _controller!.play();
                      }
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
