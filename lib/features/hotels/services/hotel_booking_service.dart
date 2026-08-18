import 'package:tourify/core/network/api_service.dart';

class HotelBookingService {
  final ApiService apiService = ApiService();

  Future<Map<String, dynamic>> bookAvailableRoom({
    required List<int> roomIds,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (!startDate.isBefore(endDate)) {
      throw Exception('تاريخ البداية يجب أن يكون قبل تاريخ النهاية.');
    }

    for (final roomId in roomIds) {
      try {
        final response = await apiService.post(
          '/rooms/$roomId/book',
          data: {
            'start_date': _formatDate(startDate),
            'end_date': _formatDate(endDate),
          },
        );
        return response['data'];
      } catch (e) {
        // ⚠️ التمييز هون معتمد على تطابق نص الرسالة العربي حرفياً —
        // إذا رفيقك غيّر صياغة رسالة "محجوزة بالفعل" بالباك مستقبلاً،
        // هالسطر لازم يتحدث معه.
        if (e.toString().contains('محجوزة')) {
          continue; // هاي الغرفة مش متوفرة، جرب التالية بصمت
        }
        rethrow; // أي خطأ تاني (رصيد غير كافي، إلخ) -> وقف فوراً
      }
    }

    throw Exception('ما في غرف متوفرة من هالنوع بهالتواريخ، جرب تواريخ تانية.');
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
