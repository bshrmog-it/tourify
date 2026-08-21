import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tourify/core/naviagtion/navigation_service.dart';
import 'package:tourify/core/network/api_service.dart';
import 'package:tourify/core/services/firebase_messaging_handler.dart';
import 'package:tourify/features/agency/home/views/active_packages_view.dart';
import 'package:tourify/features/agency/home/views/package_bookings_view.dart';
import 'package:tourify/features/agency/home/models/active_package_model.dart';
import 'package:tourify/features/agency/home/services/agency_package_service.dart';
import 'package:tourify/features/bookings/views/my_bookings_view.dart';
import 'package:tourify/firebase_options.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final ApiService _apiService = ApiService();
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload == null) return;

        try {
          final data = Map<String, dynamic>.from(jsonDecode(payload));
          _handleNotificationData(data);
        } catch (e) {
          print('❌ Failed to parse notification payload: $e');
        }
      },
    );

    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    final token = await _messaging.getToken();
    print('🔥 FCM TOKEN: $token');

    if (token != null) {
      await _saveTokenToBackend(token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await _saveTokenToBackend(newToken);
    });

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // ============================================================
    // التطبيق مفتوح (foreground)
    // ============================================================
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('🔔 NOTIFICATION RECEIVED (foreground): ${message.data}');

      final notification = message.notification;
      if (notification != null) {
        await _showLocalNotification(
          title: notification.title ?? 'Tourify',
          body: notification.body ?? '',
          data: message.data,
        );
      }
    });

    // ============================================================
    // التطبيق بالخلفية وتم الضغط على الإشعار
    // ============================================================
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('👆 NOTIFICATION CLICKED (background): ${message.data}');
      _handleNotificationData(message.data);
    });

    // ============================================================
    // التطبيق كان مغلقاً بالكامل وتم فتحه من الإشعار
    // ============================================================
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print(
        '🚀 APP OPENED FROM NOTIFICATION (terminated): ${initialMessage.data}',
      );
      _handleNotificationData(initialMessage.data);
    }
  }

  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'tourify_notifications',
      'Tourify Notifications',
      channelDescription: 'Tourify booking notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: jsonEncode(data), // 👈 صرنا نبعت كل الـ data مش بس type
    );
  }

  static Future<void> _saveTokenToBackend(String token) async {
    try {
      await _apiService.post('/fcm-token', data: {'fcm_token': token});
      print('✅ FCM token saved to backend');
    } catch (e) {
      print('❌ Failed to save FCM token: $e');
    }
  }

  // ================================================================
  // 🎯 نقطة واحدة موحّدة للتنقل — مستخدمة بكل الحالات التلاتة
  // (foreground / background / terminated)
  // ================================================================
  static void _handleNotificationData(Map<String, dynamic> data) {
    final type = data['type']?.toString();
    if (type == null) return;

    print('🔔 Handling notification type: $type, data: $data');

    switch (type) {
      case 'booking_approved':
      case 'booking_rejected':
        NavigationService.navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const MyBookingsView()),
        );
        break;

      case 'booking_created':
      case 'booking_cancelled':
        final packageIdStr = data['package_id']?.toString();
        final packageId = packageIdStr != null
            ? int.tryParse(packageIdStr)
            : null;

        if (packageId != null) {
          _openSpecificPackageBookings(packageId);
        } else {
          NavigationService.navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => const ActivePackagesView()),
          );
        }
        break;
    }
  }

  // ================================================================
  // يروح مباشرة لصفحة حجوزات الباكج المحدد (مش القائمة العامة بس)
  // ================================================================
  static Future<void> _openSpecificPackageBookings(int packageId) async {
    try {
      final packages = await AgencyPackageService().getActivePackages();
      final matches = packages.where((p) => p.id == packageId);

      if (matches.isNotEmpty) {
        final ActivePackageModel package = matches.first;
        NavigationService.navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => PackageBookingsView(package: package),
          ),
        );
        return;
      }
    } catch (e) {
      print('❌ Failed to fetch package #$packageId: $e');
    }

    // fallback: لو ما لقينا الباكج (اتحذف، أو خطأ شبكة)، خليه يشوف القائمة العامة على الأقل
    NavigationService.navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const ActivePackagesView()),
    );
  }
}
