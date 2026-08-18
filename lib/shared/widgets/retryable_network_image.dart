import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tourify/shared/services/image_load_queue.dart';

// بديل عن Image.network بيمرّ بطابور تحميل (ImageLoadQueue).
// عند الفشل: محاولتين تلقائيتين بصمت أول شي (بمؤشر تحميل بس)،
// وبعدين لو لسا فاشلة، بيظهر زر إعادة تحميل يدوي بحد أقصى 3 مرات،
// وبعد هيك بيثبت على أيقونة "صورة مكسورة".
class RetryableNetworkImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;

  const RetryableNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  State<RetryableNetworkImage> createState() => _RetryableNetworkImageState();
}

class _RetryableNetworkImageState extends State<RetryableNetworkImage> {
  static const int _maxAutoRetries = 4;
  static const int _maxManualRetries = 5;
  static const Duration _autoRetryDelay = Duration(seconds: 2);

  int _autoRetryCount = 0;
  int _manualRetryCount = 0;
  late Future<Uint8List> _future;

  @override
  void initState() {
    super.initState();
    _future = ImageLoadQueue.instance.fetchBytes(widget.url);
  }

  @override
void didUpdateWidget(covariant RetryableNetworkImage oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (oldWidget.url != widget.url) {
    setState(() {
      _future = ImageLoadQueue.instance.fetchBytes(widget.url);
    });
  }
}

  void _reload() {
    setState(() {
      _future = ImageLoadQueue.instance.fetchBytes(widget.url);
    });
  }

  void _manualRetry() {
    _manualRetryCount++;
    _reload();
  }

  Widget _placeholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[300],
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _placeholder();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          // ١. لسا في محاولات تلقائية متبقية؟ جدولها بصمت.
          if (_autoRetryCount < _maxAutoRetries) {
            _autoRetryCount++;
            Future.delayed(_autoRetryDelay, () {
              if (mounted) _reload();
            });
            return _placeholder();
          }

          // ٢. خلصت المحاولات التلقائية — اعرض زر يدوي إذا لسا في فرصة.
          final canRetryManually = _manualRetryCount < _maxManualRetries;
          return Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[300],
            child: Center(
              child: canRetryManually
                  ? GestureDetector(
                      onTap: _manualRetry,
                      child: const Icon(Icons.refresh, color: Colors.black54),
                    )
                  : const Icon(Icons.broken_image, color: Colors.black45),
            ),
          );
        }

        return Image.memory(
          snapshot.data!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
        );
      },
    );
  }
}
