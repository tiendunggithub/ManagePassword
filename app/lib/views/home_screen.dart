import 'package:app/core/theme/app_colors.dart';
import 'package:app/views/dashboard.dart';
import 'package:app/views/password_create_screen.dart';
import 'package:app/views/password_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/password_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  // _HomeScreenState createState() => _HomeScreenState();
  _MasterBottomNavState createState() => _MasterBottomNavState();
  // _MasterNotchedBarState createState() => _MasterNotchedBarState();
}

class _HomeScreenState extends State<HomeScreen> {
  //PasswordScreen

  int _selectedIndex = 0;

  // Danh sách các màn hình tương ứng với menu
  static final List<Widget> _widgetOptions = <Widget>[
    Center(child: PasswordScreen()),
    const Center(child: Text('Tìm kiếm', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Thông báo', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Cá nhân', style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent, // Màu khi được chọn
        unselectedItemColor: Colors.grey,     // Màu khi không chọn
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Giữ vị trí icon cố định
        showSelectedLabels: true,
        showUnselectedLabels: false,         // UX: Chỉ hiện label khi được chọn để đỡ rối mắt
        elevation: 10,
      ),
    );
  }
}

class _MasterBottomNavState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Danh sách các màn hình tương ứng với menu
  static final List<Widget> _widgetOptions = <Widget>[
    Center(child: DashboardScreen()),
    Center(child: PasswordScreen()),
    const Center(child: Text('Comming soon', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Comming soon', style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
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
      body: _widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddPasswordDialog(context);
            // CreatePasswordScreen();
          },
          backgroundColor: AppColors.primary, // Màu xanh như hình
          shape: const CircleBorder(
            side: BorderSide(
              color: Colors.white, // Border color
              width: 3.0, // Border width
            ),
          ),
          child: Icon(Icons.add, size: 30, color: AppColors.background),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape:
              CircularNotchedRectangle(), // Tạo lỗ hổng hình tròn để nút FAB lọt vào
          notchMargin: 1.0, // Khoảng cách giữa nút FAB và thanh nav
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, "Home", _selectedIndex),
              _buildNavItem(1, Icons.key_rounded, "Mật khẩu", _selectedIndex),
              const SizedBox(width: 30), // Chỗ trống cho FAB
              _buildNavItem(2, Icons.category, "Danh mục", _selectedIndex),
              _buildNavItem(3, Icons.person, "Profile", _selectedIndex),
            ],
          ),
        ),
    );
  }
  // Widget cho từng nút điều hướng
  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    int currentIdx,
  ) {
    bool isSelected = currentIdx == index;

    return InkWell(
      onTap: () =>
          setState(() {
            _selectedIndex = index;
          }), // Cập nhật qua ref
      // Bọc trong Padding để vùng nhấn rộng hơn, dễ bấm hơn
      child: 
      // Padding(
      //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        AnimatedContainer(
          width: 80,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), // Khoảng cách từ Icon đến viền nền
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent, // Màu nền
            shape: BoxShape.rectangle, // Hoặc BoxShape.rectangle để tạo hình vuông/chữ nhật
            // Nếu dùng hình chữ nhật, bạn có thể bo góc:
            borderRadius: BorderRadius.circular(14),
          ),
          duration: const Duration(milliseconds: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
              icon,
              size: isSelected ? 26 : 24,
              color: isSelected ? AppColors.background : Colors.grey,
            ),
            AnimatedContainer(
              height: isSelected ? 18 : 0,
              duration: const Duration(milliseconds: 300),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.background : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
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