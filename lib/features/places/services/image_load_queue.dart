import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';

// طابور تحميل بسيط بيحدد كم صورة نطلبها بنفس الوقت من السيرفر.
// سيرفر التطوير المحلي (php artisan serve) عالويندوز بيعالج طلب
// واحد بكل مرة تقريباً، فلو طلبنا كل صور الشاشة دفعة وحدة بيغرق
// وبيقطع بعض الاتصالات. هون بنحدد سقف (صورتين بنفس الوقت افتراضياً)
// والباقي بينتظر دوره بالطابور. ما في كاش هون — كل طلب بيروح فعلياً
// للسيرفر، بس بشكل متحكم فيه بدل ما ينطلقوا كلهم دفعة وحدة.
class ImageLoadQueue {
  ImageLoadQueue._internal();
  static final ImageLoadQueue instance = ImageLoadQueue._internal();

  static const int maxConcurrent = 1;

  int _active = 0;
  final List<Completer<void>> _waiting = [];
  final Dio _dio = Dio();

  // ذاكرة مؤقتة بالـ RAM بس (بتختفي وقت إغلاق التطبيق) — بمنع
  // إعادة تحميل نفس الصورة كل ما تختفي وترجع تظهر بالسكرول.
  final Map<String, Uint8List> _cache = {};

  Future<Uint8List> fetchBytes(String url) async {
    final cached = _cache[url];
    if (cached != null) return cached;

    await _acquireSlot();
    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = Uint8List.fromList(response.data!);
      _cache[url] = bytes;
      return bytes;
    } finally {
      _releaseSlot();
    }
  }

  // ... _acquireSlot و _releaseSlot يضلوا زي ما هني بدون تغيير

  Future<void> _acquireSlot() async {
    if (_active < maxConcurrent) {
      _active++;
      return;
    }
    final completer = Completer<void>();
    _waiting.add(completer);
    await completer.future;
    _active++;
  }

  void _releaseSlot() {
    _active--;
    if (_waiting.isNotEmpty) {
      _waiting.removeAt(0).complete();
    }
  }
}
