import 'package:app/models/category_model.dart';
import 'package:flutter/material.dart';

class CategoryProvider extends ChangeNotifier {
  List<CategoryEntry> categories = [];
  CategoryProvider() {
    loadCategories();
  }
  void loadCategories() {
    categories = [
      CategoryEntry(
        id: "1",
        name: "Email",
        icon: Icons.email_outlined,
        color: Colors.red
      ),
      CategoryEntry(
        id: "2",
        name: "Mạng xã hội",
        icon: Icons.people_outline,
        color: Colors.blue
      ),
      CategoryEntry(
        id: "3",
        name: "Mua sắm",
        icon: Icons.shopping_bag_outlined,
        color: Colors.orange
      ),
      CategoryEntry(
        id: "4",
        name: "Tài khoản ngân hàng",
        icon: Icons.account_balance,
        color: Colors.green
      ),
      CategoryEntry(
        id: "5",
        name: "Công việc",
        icon: Icons.work_outline,
        color: Colors.deepPurple
      ),
      CategoryEntry(
        id: "6",
        name: "Khác",
        icon: Icons.more_horiz_rounded,
        color: Colors.grey
      ),];
    notifyListeners();
  }

  void addCategory(CategoryEntry category) {
    categories.add(category);
    notifyListeners();
  }

  void deleteCategory(String id) {
    categories.removeWhere((entry) => entry.id == id);
    notifyListeners();
  }
}