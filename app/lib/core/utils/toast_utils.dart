import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtils {
  // Hàm hiển thị thông báo thành công (Màu xanh)
  static void showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  // Hàm hiển thị thông báo lỗi (Màu đỏ)
  static void showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  // Hàm custom toast thành công (Có icon tích xanh, nền xanh nhẹ)
  static void showSuccessToastCustom(BuildContext context, String message) {
    // 1. Khởi tạo FToast và liên kết với context
    FToast fToast = FToast();
    fToast.init(context);

    // 2. Tự thiết kế giao diện (Custom Widget) theo ý bạn
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.green.shade600,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Giúp toast co giãn theo độ dài chữ
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
          const SizedBox(width: 10.0),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );

    // 3. Hiển thị Toast
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM, // Vị trí hiển thị
      toastDuration: const Duration(seconds: 1), // Thời gian hiển thị
    );
  }

    // Hàm custom toast thành công (Có icon tích xanh, nền xanh nhẹ)
  static void showErrorToastCustom(BuildContext context, String message) {
    // 1. Khởi tạo FToast và liên kết với context
    FToast fToast = FToast();
    fToast.init(context);

    // 2. Tự thiết kế giao diện (Custom Widget) theo ý bạn
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.red.shade600,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Giúp toast co giãn theo độ dài chữ
        children: [
          const Icon(Icons.cancel_outlined, color: Colors.white, size: 22),
          const SizedBox(width: 10.0),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );

    // 3. Hiển thị Toast
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM, // Vị trí hiển thị
      toastDuration: const Duration(seconds: 1), // Thời gian hiển thị
    );
  }
}