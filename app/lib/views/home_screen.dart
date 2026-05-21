import 'package:app/core/theme/app_colors.dart';
import 'package:app/views/dashboard.dart';
import 'package:app/views/password_create_screen.dart';
import 'package:app/views/password_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  bool isRegistered;
  HomeScreen(this.isRegistered, {super.key});
  @override
  _MasterBottomNavState createState() => _MasterBottomNavState();
}

class _MasterBottomNavState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Danh sách các màn hình tương ứng với menu
  List<Widget> get _widgetOptions => <Widget>[
    Center(child: DashboardScreen(onGoToSearch: (index) => _changeTab(index))),
    Center(child: PasswordScreen()),
    const Center(child: Text('Comming soon', style: TextStyle(fontSize: 24))),
    const Center(child: Text('Comming soon', style: TextStyle(fontSize: 24))),
    Center(child: CreatePasswordScreen(onGoToSearch: (index) => _changeTab(index))),
  ];

  // Hàm thay đổi tab
  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("------------------- HomeScreen initState --------------------");
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print("------------------- HomeScreen dispose --------------------");
  }

  @override
  Widget build(BuildContext context) {
    // Nếu viewInsets.bottom > 0 nghĩa là bàn phím ảo đang mở
  bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        //Trình quản lý mật khẩu
        title: Text("Quản lý mật khẩu", 
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.primary,),
            onPressed: () {
              widget.isRegistered = false;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login', // Trang bạn muốn chuyển đến
                (route) => false, // Điều kiện xóa: 'false' nghĩa là xóa SẠCH CÁC TRANG CŨ
              );
            },
          ),
        ],
        // elevation: 1.0,
        // shadowColor: Colors.black,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255)
      ),
      body: Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: _widgetOptions.elementAt(_selectedIndex)),
      floatingActionButton: isKeyboardOpen 
        ? null 
        : SizedBox(
            width: 55,
            height: 55,
            child: FittedBox(
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 4;
                  });
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
            )
          ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shadowColor: const Color.fromARGB(255, 255, 0, 0),
        elevation: 15.0,
        shape:
            CircularNotchedRectangle(), // Tạo lỗ hổng hình tròn để nút FAB lọt vào
        notchMargin: 5.0, // Khoảng cách giữa nút FAB và thanh nav
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, "Trang chủ", _selectedIndex),
            _buildNavItem(1, Icons.key_rounded, "Mật khẩu", _selectedIndex),
            const SizedBox(width: 50), // Chỗ trống cho FAB
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
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6), // Khoảng cách từ Icon đến viền nền
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
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}