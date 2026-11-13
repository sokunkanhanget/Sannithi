import '../model/product.dart';
import 'inventory_exception.dart';

class ProductService {
  List<Product> products = [];

  Product? findById(String id) {
    for (int i = 0; i < products.length; i++) {
      if (products[i].id == id) {
        return products[i];
      }
    }
    return null;
  }

  void addProduct(Product product) {
    if (product.name.trim().isEmpty || product.barcode.trim().isEmpty) {
      throw InventoryException('Product name and barcode are required');
    }
    if (product.price <= 0) {
      throw InventoryException('Price must be greater than 0');
    }
    if (product.stockQuantity < 0) {
      throw InventoryException('Stock cannot be negative');
    }
    if (findById(product.id) != null) {
      throw InventoryException('Product id already exists');
    }
    if (barcodeExists(product.barcode)) {
      throw InventoryException('Product barcode already exists');
    }

    products.add(product);
  }

  void editProduct(
    String id, {
    String? name,
    String? barcode,
    String? category,
    double? price,
  }) {
    Product? product = findById(id);
    if (product == null) {
      throw InventoryException('Product not found');
    }

    String newName = name ?? product.name;
    String newBarcode = barcode ?? product.barcode;
    double newPrice = price ?? product.price;

    if (newName.trim().isEmpty || newBarcode.trim().isEmpty) {
      throw InventoryException('Product name and barcode are required');
    }
    if (newPrice <= 0) {
      throw InventoryException('Price must be greater than 0');
    }
    if (newBarcode != product.barcode && barcodeExists(newBarcode)) {
      throw InventoryException('Product barcode already exists');
    }

    product.name = newName.trim();
    product.barcode = newBarcode.trim();
    product.price = newPrice;

    if (category != null) {
      product.category = category.trim();
    }
  }

  void deleteProduct(String id) {
    Product? product = findById(id);
    if (product == null) {
      throw InventoryException('Product not found');
    }
    products.remove(product);
  }

  void addStock(String id, int quantity) {
    if (quantity <= 0) {
      throw InventoryException('Stock to add must be greater than 0');
    }
    Product? product = findById(id);
    if (product == null) {
      throw InventoryException('Product not found');
    }
    product.stockQuantity = product.stockQuantity + quantity;
  }

  void reduceStock(String id, int quantity) {
    if (quantity <= 0) {
      throw InventoryException('Quantity must be greater than 0');
    }
    Product? product = findById(id);
    if (product == null) {
      throw InventoryException('Product not found');
    }
    if (quantity > product.stockQuantity) {
      throw InventoryException(
          'Not enough stock for ${product.name} '
          '(available: ${product.stockQuantity})');
    }
    product.stockQuantity = product.stockQuantity - quantity;
  }

  List<Product> getLowStockProducts(int threshold) {
    List<Product> result = [];
    for (int i = 0; i < products.length; i++) {
      if (products[i].isLowStock(threshold)) {
        result.add(products[i]);
      }
    }
    return result;
  }

  bool barcodeExists(String barcode) {
    for (int i = 0; i < products.length; i++) {
      if (products[i].barcode == barcode.trim()) {
        return true;
      }
    }
    return false;
  }
}