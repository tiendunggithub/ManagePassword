import 'package:app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/password_provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PasswordProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Trình quản lý mật khẩu", 
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)
        ),
        // elevation: 1.0,
        // shadowColor: Colors.black,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255)
      ),
      body: 
      Container( 
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.backgroundBody, // Single color
          // Or use a gradient
          // gradient: LinearGradient(
          //   colors: [Colors.blue, Colors.green],
          // ),
        ),
        child: Row(
          children: [
            Expanded (
              child: ListView.builder(
                itemCount: provider.passwords.length,
                itemBuilder: (context, index) {
                  final entry = provider.passwords[index];

                  return 
                    ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.lock)),
                      title: Text(entry.serviceName),
                      subtitle: Text(entry.username),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_red_eye),
                        onPressed: () async {
                          final raw = await provider.decryptPassword(entry.encryptedPassword);
                          _showPasswordDetail(context, entry.serviceName, raw);
                        },
                      ),
                    );
                },
              ),
            )
          ],
        )
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddPasswordDialog(context),
      ),
    );
  }

  void _showPasswordDetail(BuildContext context, String service, String password) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Mật khẩu cho $service"),
        content: TextFormField(
          initialValue: password,
          readOnly: true,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                // Thêm logic copy to clipboard:
                // Clipboard.setData(ClipboardData(text: password));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã sao chép vào bộ nhớ tạm")),
                );
              },
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng")),
        ],
      ),
    );
  }

  void _showAddPasswordDialog(BuildContext context) {
  final nameController = TextEditingController();
  final userController = TextEditingController();
  final passController = TextEditingController();
  bool isSaving = false;

  showDialog(
    context: context,
    barrierDismissible: false, // Ngăn người dùng tắt dialog khi đang lưu
    builder: (context) => StatefulBuilder( // Dùng StatefulBuilder để cập nhật trạng thái trong Dialog
      builder: (context, setState) => AlertDialog(
        title: const Text("Thêm mật khẩu mới"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Tên dịch vụ",
                  hintText: "Ví dụ: Facebook, Gmail...",
                ),
              ),
              TextField(
                controller: userController,
                decoration: const InputDecoration(labelText: "Tên đăng nhập"),
              ),
              TextField(
                controller: passController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Mật khẩu"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: isSaving ? null : () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: isSaving 
              ? null 
              : () async {
                  if (nameController.text.isEmpty || passController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Vui lòng nhập đủ thông tin!")),
                    );
                    return;
                  }

                  setState(() => isSaving = true);

                  try {
                    // Gọi Provider để mã hóa và lưu vào Secure Storage
                    await Provider.of<PasswordProvider>(context, listen: false).addPassword(
                      nameController.text,
                      userController.text,
                      passController.text,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Đã lưu mật khẩu thành công!")),
                      );
                    }
                  } catch (e) {
                    setState(() => isSaving = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Lỗi: $e")),
                    );
                  }
                },
            child: isSaving 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text("Lưu lại"),
          ),
        ],
      ),
    ),
  );
}
}