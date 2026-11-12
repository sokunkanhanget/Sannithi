import '../model/product.dart';
import '../model/sale.dart';
import '../model/sale_item.dart';
import 'inventory_exception.dart';
import 'product_service.dart';

class SaleService {
  ProductService productService;

  List<SaleItem> cart = [];
  List<Sale> salesHistory = [];
  int nextId = 1;

  SaleService(this.productService);

  SaleItem? findInCart(String productId) {
    for (int i = 0; i < cart.length; i++) {
      if (cart[i].product.id == productId) {
        return cart[i];
      }
    }
    return null;
  }

  void addToCart(String productId, int quantity) {
    if (quantity <= 0) {
      throw InventoryException('Quantity must be greater than 0');
    }

    Product? product = productService.findById(productId);
    if (product == null) {
      throw InventoryException('Product not found');
    }

    SaleItem? existing = findInCart(productId);
    int inCart = 0;
    if (existing != null) {
      inCart = existing.quantity;
    }

    if (inCart + quantity > product.stockQuantity) {
      throw InventoryException(
          'Not enough stock (available: ${product.stockQuantity})');
    }

    if (existing == null) {
      cart.add(SaleItem(product, quantity));
    } else {
      existing.quantity = existing.quantity + quantity;
    }
  }

  void removeFromCart(String productId) {
    SaleItem? item = findInCart(productId);
    if (item == null) {
      throw InventoryException('Product not in cart');
    }
    cart.remove(item);
  }

  double calculateCartTotal() {
    double total = 0;
    for (int i = 0; i < cart.length; i++) {
      total = total + cart[i].subtotal;
    }
    return total;
  }

  Sale checkout() {
    if (cart.isEmpty) {
      throw InventoryException('Cart is empty');
    }

    // Check ALL items first so a failure leaves stock untouched
    for (int i = 0; i < cart.length; i++) {
      if (cart[i].quantity > cart[i].product.stockQuantity) {
        throw InventoryException(
            'Not enough stock for ${cart[i].product.name}');
      }
    }

    // Then reduce the stock
    for (int i = 0; i < cart.length; i++) {
      productService.reduceStock(cart[i].product.id, cart[i].quantity);
    }

    Sale sale = Sale('S$nextId', DateTime.now(), List.from(cart));
    nextId = nextId + 1;
    salesHistory.add(sale);
    cart.clear();
    return sale;
  }

  double getTotalRevenue() {
    double total = 0;
    for (int i = 0; i < salesHistory.length; i++) {
      total = total + salesHistory[i].totalAmount;
    }
    return total;
  }
}