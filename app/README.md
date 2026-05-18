# app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


# Build APK

## 1. Build ra file APK gọn nhẹ nhất (khuyến khích dùng)
    flutter build apk --split-per-abi

### Tác dụng: 
Lệnh này sẽ chia nhỏ ứng dụng và xuất ra 3 file APK riêng biệt tương ứng với các kiến trúc chip điện thoại hiện nay (armeabi-v7a, arm64-v8a, x86_64).

### Ưu điểm: 
Khi bạn gửi file arm64-v8a (hầu hết điện thoại đời mới) hoặc armeabi-v7a (điện thoại đời cũ) cho người khác, dung lượng file sẽ cực kỳ nhẹ (giảm từ 30% - 50% dung lượng) vì không phải gánh cấu hình của các loại chip khác.


## 2. Build ra 1 file duy nhất chứa tất cả
    flutter build apk

### Tác dụng: 
Xuất ra 1 file APK duy nhất (thường tên là app-release.apk). File này chứa tất cả mã nguồn cho mọi loại cấu hình chip.

### Ưu điểm: 
Tiện lợi, gửi file này thì máy Android nào cũng cài được, không cần quan tâm máy đó dùng chip gì.

### Nhược điểm: 
Dung lượng file sẽ nặng hơn đáng kể.

## 3. Build file để debug (Kiểm tra lỗi trên máy khác)
    flutter build apk --debug

### Tác dụng: 
Tạo ra file APK phiên bản thử nghiệm. File này cho phép kết nối với máy tính để xem log lỗi, nhưng dung lượng rất nặng và chạy sẽ bị giật lag hơn bản Release.

# Đường dẫn tìm file APK sau khi Build xong

Sau khi Terminal chạy xong và báo Built build/app/outputs/flutter-apk/..., bạn hãy vào thư mục dự án của mình theo đường dẫn sau để lấy file:

![alt text](image.png)