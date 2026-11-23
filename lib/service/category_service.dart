import '../exception/inventory_exception.dart';
import '../model/category.dart';

class CategoryService {
  final List<Category> _categories = [];

  Category addCategory(String id, String name) {
    if (name.trim().isEmpty) {
      throw InventoryException('Category name is required');
    }
    if (_idExists(id)) {
      throw InventoryException('Category ID already exists');
    }
    if (_nameExists(name)) {
      throw InventoryException('Category name already exists');
    }

    Category category = Category(id, name.trim());
    _categories.add(category);
    return category;
  }

  List<Category> getCategories() {
    return List.unmodifiable(_categories);
  }

  bool _idExists(String id) {
    for (int i = 0; i < _categories.length; i++) {
      if (_categories[i].id == id) {
        return true;
      }
    }
    return false;
  }

  bool _nameExists(String name) {
    for (int i = 0; i < _categories.length; i++) {
      if (_categories[i].name.toLowerCase() == name.trim().toLowerCase()) {
        return true;
      }
    }
    return false;
  }
}