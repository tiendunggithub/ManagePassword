import 'package:app/core/theme/app_colors.dart';
import 'package:app/models/category_model.dart';
import 'package:app/models/password_model.dart';
import 'package:app/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/providers/password_provider.dart';

class DashboardScreen extends StatefulWidget {
  final Function onGoToSearch;
  const DashboardScreen({super.key, required this.onGoToSearch});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final CategoryProvider categoryProvider = CategoryProvider();
  List<CategoryEntry> categories = [];
  final int limitCategories = 6;

  @override
  void initState() {
    super.initState();
    categoryProvider.loadCategories();
    categories = categoryProvider.categories;
  }

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
                      SizedBox(
                        width: passwords.length.toString().length > 3 ? screenWidth*0.5 : screenWidth*0.7,
                        child: Text('Số lượng mật khẩu được bảo vệ',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 18),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Danh mục', style: TextStyle(color: AppColors.textColorMain, fontWeight: FontWeight.w500, fontSize: 16)),
                    TextButton(
                      onPressed: () {
                        widget.onGoToSearch(2);
                      }, 
                      child: Text('Xem tất cả', 
                        style: TextStyle(
                          color: AppColors.primary, fontWeight: FontWeight.w500, fontSize: 13
                        )
                      )
                    )
                  ],
                ),
                GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,        // Number of columns
                    mainAxisSpacing: 5,      // Spacing between columns
                    crossAxisSpacing: 5,     // Spacing between rows
                    childAspectRatio: 1.7,    // Adjusts the height/width ratio of cards
                  ),
                  itemCount: categories.length > limitCategories ? limitCategories : categories.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: categories[index].color,
                      elevation: 4,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                passwords.where((p) => p.categoryId == categories[index].id).length.toString(),
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                // maxLines: 1,
                                // overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(categories[index].icon, size: 30, color: Colors.white),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Mới nhất', style: TextStyle(color: AppColors.textColorMain, fontWeight: FontWeight.w500, fontSize: 16)),
                    TextButton(
                      onPressed: () {
                        widget.onGoToSearch(1);
                      }, 
                      child: Text('Xem tất cả', 
                        style: TextStyle(
                          color: AppColors.primary, fontWeight: FontWeight.w500, fontSize: 13
                        )
                      )
                    )
                  ],
                ),
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
                ),
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
}
