import 'sale_item.dart';

class Sale {
  String id;
  DateTime date;
  List<SaleItem> items;

  Sale(this.id, this.date, this.items);

  double get totalAmount {
    double total = 0;
    for (int i = 0; i < items.length; i++) {
      total = total + items[i].subtotal;
    }
    return total;
  }

  int get totalQuantity {
    int total = 0;
    for (int i = 0; i < items.length; i++) {
      total = total + items[i].quantity;
    }
    return total;
  }
}