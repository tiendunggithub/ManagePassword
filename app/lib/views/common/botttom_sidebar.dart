import 'package:app/core/theme/app_colors.dart';
import 'package:app/providers/password_provider.dart';
import 'package:app/views/dashboard.dart';
import 'package:app/views/password_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../home_screen copy.dart';

class BottomSidebar extends StatefulWidget {
  @override
  _MasterBottomNavState createState() => _MasterBottomNavState();
}

class _MasterBottomNavState extends State<BottomSidebar> {
  int _selectedIndex = 0;

  // Danh sách các màn hình tương ứng với menu
  static final List<Widget> _widgetOptions = <Widget>[
    Center(child: DashboardScreen()),
    Center(child: PasswordScreen()),
    const Center(child: Text('Thông báo', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Cá nhân', style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Danh sách các mục menu
  final List<IconData> _icons = [
    Icons.home_rounded,
    Icons.key_rounded,
    Icons.notifications_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        //Trình quản lý mật khẩu
        title: Text("---", 
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)
        ),
        // elevation: 1.0,
        // shadowColor: Colors.black,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255)
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddPasswordDialog(context),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      // Center(
      //   child: Text("Màn hình ${_selectedIndex + 1}", style: TextStyle(fontSize: 24)),
      // ),
      // Đặt menu trong Stack để tạo hiệu ứng nổi (Floating)
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(displayWidth * .05),
        height: displayWidth * .155,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.1),
              blurRadius: 30,
              offset: Offset(0, 10),
            ),
          ],
          borderRadius: BorderRadius.circular(50),
        ),
        child: ListView.builder(
          itemCount: 4,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: displayWidth * .02),
          itemBuilder: (context, index) => InkWell(
            onTap: () => _onItemTapped(index),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Stack(
              children: [
                // Hiệu ứng "vệt sáng" di chuyển khi chọn tab
                AnimatedContainer(
                  duration: Duration(seconds: 1),
                  curve: Curves.fastLinearToSlowEaseIn,
                  width: index == _selectedIndex ? displayWidth * .32 : displayWidth * .18,
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: Duration(seconds: 1),
                    curve: Curves.fastLinearToSlowEaseIn,
                    height: index == _selectedIndex ? displayWidth * .12 : 0,
                    width: index == _selectedIndex ? displayWidth * .32 : 0,
                    decoration: BoxDecoration(
                      color: index == _selectedIndex
                          ? AppColors.surfaceTint
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
                // Icon và Text
                AnimatedContainer(
                  duration: Duration(seconds: 1),
                  curve: Curves.fastLinearToSlowEaseIn,
                  width: index == _selectedIndex ? displayWidth * .31 : displayWidth * .18,
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: Duration(seconds: 1),
                            curve: Curves.fastLinearToSlowEaseIn,
                            width: index == _selectedIndex ? displayWidth * .13 : 0,
                          ),
                          AnimatedOpacity(
                            opacity: index == _selectedIndex ? 1 : 0,
                            duration: Duration(seconds: 1),
                            curve: Curves.fastLinearToSlowEaseIn,
                            child: Text(
                              index == _selectedIndex ? 'Mật khẩu' : '',
                              style: TextStyle(
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: Duration(seconds: 1),
                            curve: Curves.fastLinearToSlowEaseIn,
                            width: index == _selectedIndex ? displayWidth * .03 : 20,
                          ),
                          Icon(
                            _icons[index],
                            size: displayWidth * .076,
                            color: index == _selectedIndex
                                ? const Color.fromARGB(255, 255, 255, 255)
                                : Colors.black26,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
                        '',
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