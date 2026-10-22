import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Quản lý trạng thái Firebase toàn cục (offline-first).
///
/// LƯU Ý: Repo hiện CHƯA có cấu hình Firebase thật
/// (`lib/firebase_options.dart` + `android/app/google-services.json`) —
/// xem Linear IN4-115. Khi chưa cấu hình, app vẫn chạy đầy đủ ở chế độ
/// local (shared_preferences) và tính năng Cloud Sync tự vô hiệu hóa.
class FirebaseService {
  FirebaseService._();

  static bool _available = false;

  /// `true` khi [Firebase.initializeApp] thành công.
  static bool get isAvailable => _available;

  /// Khởi tạo Firebase an toàn — không bao giờ làm crash app khi
  /// thiếu cấu hình.
  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
      _available = true;
    } catch (e) {
      _available = false;
      debugPrint(
        'Firebase chưa được cấu hình (IN4-115), chạy chế độ local: $e',
      );
    }
  }
}
