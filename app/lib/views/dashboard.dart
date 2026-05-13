import 'package:app/core/theme/app_colors.dart';
import 'package:app/models/password_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/password_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final passwords = context.select<PasswordProvider, List<PasswordEntry>>((m) => m.passwords);
    final passwordsNew = context.select<PasswordProvider, List<PasswordEntry>>((m) => m.passwordsNew);
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: 
      Container( 
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.backgroundBody, // Single color
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
          child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    width: screenWidth,
                    duration: const Duration(milliseconds: 300),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: passwords.length.toString().length > 3 ? screenWidth*0.5 : screenWidth*0.7,
                          child: Text('Số lượng mật khẩu được bảo vệ',
                          style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18),
                          )
                        ),
                        // SizedBox(width: 10),
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 194, 219, 255).withOpacity(.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          child: Text(passwords.length.toString(), style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500, fontSize: 20),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text('Mới nhất', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500, fontSize: 16)),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: 100,
                      maxHeight: 300,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true, // list view tự co giãn chiều cao theo nội dung bên trong
                      itemCount: passwordsNew.length,
                      itemBuilder: (context, index) {
                        final entry = passwordsNew[index];
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
          )
          )
        )
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.add),
      //   onPressed: () => _showAddPasswordDialog(context),
      // ),
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
