import 'package:app/core/theme/app_colors.dart';
import 'package:app/models/password_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/password_provider.dart';

class PasswordScreen extends StatelessWidget {
  const PasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final passwords = context.select<PasswordProvider, List<PasswordEntry>>((m) => m.passwords);

    return Scaffold(
      body: Column(
        children: [
          Text('Tất cả'),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true, // list view tự co giãn chiều cao theo nội dung bên trong
              itemCount: passwords.length,
              itemBuilder: (context, index) {
                final entry = passwords[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(.2),
                    child: Icon(Icons.lock, color: AppColors.primary,)
                  ),
                  title: Text(entry.serviceName),
                  subtitle: Text(entry.username),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_red_eye),
                    onPressed: () async {
                      final raw = await context.read<PasswordProvider>().decryptPassword(entry.encryptedPassword);
                      _showPasswordDetail(context, entry.serviceName, raw);
                    },
                  ),
                );
              },
            ),
          )
        ],
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
}