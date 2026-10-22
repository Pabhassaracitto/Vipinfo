# Vipinfo — GTD Manager Pro

Dự án **quản lý thông tin thông minh**: ứng dụng Flutter quản lý công việc theo phương pháp GTD (Getting Things Done) với các tính năng nâng cao.

## Tính năng

- ✅ **Tasks (GTD)** — quản lý công việc theo 6 danh mục: Inbox, Next, Projects, Waiting, Calendar, Someday; ưu tiên, tags, hạn chót, tìm kiếm & lọc.
- 📊 **Dashboard** — thống kê, biểu đồ tiến độ (fl_chart).
- ⏱️ **Pomodoro** — đồng hồ tập trung tích hợp với tasks.
- 🔁 **Habits** — theo dõi thói quen, chuỗi ngày (streak).
- 🌙 **Dark mode** — chuyển giao diện sáng/tối.
- 🔔 **Thông báo cục bộ** — nhắc việc theo giờ (flutter_local_notifications).
- 📤 **Export/Import JSON** — sao lưu và khôi phục dữ liệu.
- ☁️ **Cloud Sync (Firebase)** — *tùy chọn*; xem ghi chú bên dưới.

## Chạy dự án

```bash
flutter pub get
flutter run
```

Chạy test:

```bash
flutter test
```

### Ghi chú về Firebase

Repo **chưa kèm** cấu hình Firebase (`lib/firebase_options.dart`, `android/app/google-services.json`). Khi chưa cấu hình, app tự chạy ở chế độ **offline-first** (dữ liệu lưu cục bộ bằng `shared_preferences`) và tính năng Cloud Sync bị vô hiệu hóa — app không crash.

Để bật Cloud Sync: tạo Firebase project, chạy `flutterfire configure`, bật Authentication + Cloud Firestore (chi tiết trong Linear issue IN4-115).

## Cấu trúc thư mục

```
lib/
├── main.dart              # Entry point, khởi tạo providers & services
├── models/                # Task, Habit
├── providers/             # TaskProvider, HabitProvider, PomodoroProvider, ThemeProvider
├── screens/               # Home, Dashboard, Pomodoro, Habits, Settings, Navigation
├── services/              # NotificationService, FirebaseService
└── widgets/               # AddTaskDialog, CategoryDrawer, TaskItem, TaskList
```

## Nền tảng hỗ trợ

Hiện tại: **Android**. iOS/web dự kiến bổ sung sau (Linear issue IN4-116).
