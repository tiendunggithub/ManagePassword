import 'package:app/core/theme/app_colors.dart';
import 'package:app/models/password_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/password_provider.dart';

class PasswordScreen extends StatelessWidget {
  PasswordScreen({super.key});
  final TextEditingController _searchController = TextEditingController();

  bool _isSearch = false;

  @override
  Widget build(BuildContext context) {
    final passwords = context.select<PasswordProvider, List<PasswordEntry>>((m) => m.passwords);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10,),
            Text('Tất cả mật khẩu', style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),),
            SizedBox(height: 10,),
            Divider(color: AppColors.primary.withOpacity(.2)),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Nhập tiêu đề hoặc tên đăng nhập",
                suffixIcon: IconButton(
                  icon: Icon(_isSearch ? Icons.clear : Icons.search),
                  onPressed: () {
                    if (_isSearch) {
                      _isSearch = false;
                      _searchController.clear();
                      context.read<PasswordProvider>().loadPasswords();
                    }
                  },
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 2.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              ),
              onChanged: (value) {
                // thêm logic tìm kiếm
                _isSearch = value.isNotEmpty;
                context.read<PasswordProvider>().search(value);
              },
            ),
            SizedBox(height: 20,),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true, // list view tự co giãn chiều cao theo nội dung bên trong
                itemCount: passwords.length,
                itemBuilder: (context, index) {
                  final entry = passwords[index];
                  return Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(bottom: 8.0, left: 5.0, right: 5.0), 
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  child: ListTile(
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
                        _showPasswordDetail(context, entry.serviceName, entry.username, raw);
                      },
                    ),
                  ),
                );
                },
              ),
            )
          ],
        )
      )
    );
  }

  void _showPasswordDetail(BuildContext context, String service, String username, String password) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Tên đăng nhập"),
              TextFormField(
                initialValue: username,
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
              Text("Mật khẩu"),
              TextFormField(
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
            ],
          )
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng")),
        ],
      ),
    );
  }
}