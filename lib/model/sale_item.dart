import 'product.dart';

class SaleItem {
  Product product;
  int quantity;
  double unitPrice; // price at the time of sale

  SaleItem(this.product, this.quantity) : unitPrice = product.price;

  double get subtotal {
    return unitPrice * quantity;
  }
}