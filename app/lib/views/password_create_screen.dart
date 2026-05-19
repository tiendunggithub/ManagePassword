import 'dart:ffi' hide Size;

import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/utils/toast_utils.dart';
import 'package:app/models/category_model.dart';
import 'package:app/providers/category_provider.dart';
import 'package:app/providers/password_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreatePasswordScreen extends StatefulWidget {
  final Function onGoToSearch;
  const CreatePasswordScreen({super.key, required this.onGoToSearch});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

int checkPasswordStrength(String password) {
  if (password.isEmpty) return 0;
  
  int score = 0;
  
  // 1. Kiểm tra độ dài
  if (password.length >= 8) score++;
  
  // 2. Kiểm tra xem có chứa chữ số không
  if (RegExp(r'[0-9]').hasMatch(password)) score++;
  
  // 3. Kiểm tra xem có cả chữ hoa và chữ thường không
  if (RegExp(r'[a-z]').hasMatch(password) && RegExp(r'[A-Z]').hasMatch(password)) score++;
  
  // 4. Kiểm tra ký tự đặc biệt
  if (RegExp(r'[!@#\$&*~_.-]').hasMatch(password)) score++;
  
  return score; // Kết quả trả về từ 0 (Rất yếu) đến 4 (Rất mạnh)
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  bool _isHiddenPassword = true;
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  // Giá trị hiện tại của dropdown
  CategoryEntry? _selectedValue;
  
  // Danh sách các mục
  final CategoryProvider categoryProvider = CategoryProvider();
  List<CategoryEntry> categories = [];

  @override
  void initState() {
    super.initState();
    categoryProvider.loadCategories();
    categories = categoryProvider.categories;
  }

  // Hàm lấy màu sắc tương ứng với số điểm
  Color _getStrengthColor(int score) {
    switch (score) {
      case 0: return Colors.transparent; // Chưa nhập gì
      case 1: return Colors.red;         // Yếu
      case 2: return Colors.orange;      // Trung bình
      case 3: return Colors.blue;        // Mạnh
      case 4: return Colors.green;       // Rất mạnh
      default: return Colors.grey;
    }
  }

  // Hàm lấy text hiển thị
  String _getStrengthText(int score) {
    if (_passwordController.text.isEmpty) return '';
    switch (score) {
      case 1: return 'Yếu';
      case 2: return 'Trung bình';
      case 3: return 'Mạnh';
      case 4: return 'Rất mạnh';
      default: return '';
    }
  }

  Future<void> _savePassword(context) async {
    // final passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
    // final result = passwordProvider.addPassword(
    //   _titleController.text,
    //   _accountController.text,
    //   _passwordController.text,
    //   _websiteController.text,
    // );

    try {
      if (_selectedValue == null) {
        ToastUtils.showError("Vui lòng chọn danh mục!");
        return;
      }
      _categoryController.text = _selectedValue!.id;
      // Gọi Provider để mã hóa và lưu vào Secure Storage
      await Provider.of<PasswordProvider>(context, listen: false).addPassword(
        _categoryController.text,
        _titleController.text,
        _accountController.text,
        _passwordController.text,
        _websiteController.text,
      );

      if (context.mounted) {
        widget.onGoToSearch(1);
        ToastUtils.showSuccess("Thêm mật khẩu thành công!");
      }
    } catch (e) {
      ToastUtils.showError("Lỗi khi thêm mật khẩu!");
      print("------->>>>>> Error saving password: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    int score = checkPasswordStrength(_passwordController.text);
    Color strengthColor = _getStrengthColor(score);
    
    // Tính toán chiều rộng của thanh dựa trên số điểm (ví dụ: tối đa là 100%)
    double percent = _passwordController.text.isEmpty ? 0.0 : (score / 4);

    @override
    void dispose() {
      _passwordController.dispose();
      super.dispose();
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text("Tạo mật khẩu mới", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Lưu trữ thông tin đăng nhập của bạn một cách an toàn và bảo mật", style: TextStyle(fontSize: 14, color: Colors.black)),
            SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text('Tiêu đề', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                  SizedBox(height: 5),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Nhập tiêu đề vd: Gmail, Facebook, ...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    style: TextStyle(fontSize: 14),
                  ),
                  Text('Danh mục', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                  SizedBox(height: 5),
                  TextField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      hintText: 'Nhập danh mục',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    style: TextStyle(fontSize: 14),
                  ),
                  DropdownButton<CategoryEntry>(
                    // Giá trị hiện tại
                    value: _selectedValue,
                    // Chữ hiển thị khi chưa chọn gì
                    hint: const Text('Chọn danh mục'),
                    // Biểu tượng mũi tên xuống
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                    // Độ rộng tối đa theo widget cha
                    isExpanded: true, 
                    // Đường gạch chân mặc định (ẩn đi bằng Container rỗng)
                    underline: const SizedBox(), 
                    // Kiểu chữ cho các item
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    // Hàm lắng nghe sự kiện khi người dùng chọn item mới
                    onChanged: (CategoryEntry? newValue) {
                      setState(() {
                        _selectedValue = newValue;
                      });
                    },
                    // Chuyển đổi danh sách String thành danh sách DropdownMenuItem
                    items: categories.map<DropdownMenuItem<CategoryEntry>>((CategoryEntry value) {
                      return DropdownMenuItem<CategoryEntry>(
                        value: value,
                        child: Text(value.name),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  Text('Tên đăng nhập', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                  SizedBox(height: 5),
                  TextField(
                    controller: _accountController,
                    decoration: InputDecoration(
                      hintText: 'Nhập tên đăng nhập hoặc gmail',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      // labelText: 'Mật khẩu',
                    ),
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 20),
                  Text('Mật khẩu', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                  SizedBox(height: 5),
                  TextField(
                    controller: _passwordController,
                    // Thuộc tính quyết định text có bị biến thành dấu chấm tròn hay không
                    obscureText: _isHiddenPassword,
                    decoration: InputDecoration(
                      hintText: 'Nhập mật khẩu',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isHiddenPassword ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.primary,
                          size: 20,
                        ), 
                        onPressed: () {
                          // Khi bấm vào icon, đảo ngược trạng thái và cập nhật lại giao diện
                          setState(() {
                            _isHiddenPassword = !_isHiddenPassword;
                          });
                        },
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _passwordController.text = value;
                      });
                    },
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Cấu trúc thanh nền xám bên dưới
                      Expanded(
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(3),
                          ),
                          // Dùng LayoutBuilder để lấy chiều rộng tối đa hiện tại của Row
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Stack(
                                children: [
                                  // Thanh màu đại diện cho độ mạnh sẽ chạy mượt mà nhờ AnimatedContainer
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                    width: constraints.maxWidth * percent,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: strengthColor,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      
                      // 3. Chữ hiển thị trạng thái (Yếu, Mạnh...) phía bên phải
                      if (_passwordController.text.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Text(
                          _getStrengthText(score),
                          style: TextStyle(
                            color: strengthColor, 
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ]
                    ],
                  ),
                  // SizedBox(height: 20),
                  // Text('Ghi chú', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                  // SizedBox(height: 5),
                  // TextField(
                  //   decoration: InputDecoration(
                  //     hintText: 'Nhập ghi chú',
                  //     contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(12.0),
                  //     ),
                  //     // labelText: 'Ghi chú',
                  //   ),
                  //   style: TextStyle(fontSize: 14),
                  // ),
                  SizedBox(height: 20),
                  Text('Website', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                  SizedBox(height: 5),
                  TextField(
                    controller: _websiteController,
                    decoration: InputDecoration(
                      hintText: 'https://..',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      // prefixIcon: Icon(Icons.web, color: AppColors.primary),
                      suffixIcon: Icon(Icons.link, color: AppColors.primary),
                      // labelText: 'Website',
                    ),
                    keyboardType: TextInputType.url,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        minimumSize: Size.fromHeight(50)
                      ),
                      onPressed: () {
                        widget.onGoToSearch(0);
                      },
                      child: Text('Hủy', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        _savePassword(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        minimumSize: Size.fromHeight(50)
                      ),
                      child: Text('Lưu mật khẩu', style: TextStyle(fontSize: 16)),
                    ),
                  )
                ],
              )
            ),
            SizedBox(height: 40),
          ],
        ),
      )
    );
  }
}