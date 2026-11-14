import 'package:flutter_test/flutter_test.dart';
import 'package:sannithi_app/model/product.dart';
import 'package:sannithi_app/service/inventory_exception.dart';
import 'package:sannithi_app/service/product_service.dart';
import 'package:sannithi_app/service/sale_service.dart';

class TestProduct extends Product {
  TestProduct(String id, String name, double price, int stock)
      : super(
          id: id,
          name: name,
          barcode: 'BC-$id',
          category: 'Test',
          price: price,
          stockQuantity: stock,
        );
}

void main() {
  ProductService productService = ProductService();
  SaleService service = SaleService(productService);

  setUp(() {
    productService = ProductService();
    productService.addProduct(TestProduct('P001', 'Item 1', 2.5, 10));
    productService.addProduct(TestProduct('P002', 'Item 2', 4.0, 5));
    service = SaleService(productService);
  });

  int stockOf(String id) {
    return productService.findById(id)!.stockQuantity;
  }

  test('single item sale updates stock and saves transaction', () {
    service.addToCart('P001', 3);
    var sale = service.checkout();

    expect(sale.totalAmount, 7.5);
    expect(stockOf('P001'), 7);
    expect(service.salesHistory.length, 1);
    expect(service.cart, isEmpty);
  });

  test('multiple item sale calculates total and updates all stock', () {
    service.addToCart('P001', 2);
    service.addToCart('P002', 1);
    var sale = service.checkout();

    expect(sale.totalAmount, 9.0);
    expect(sale.items.length, 2);
    expect(stockOf('P001'), 8);
    expect(stockOf('P002'), 4);
  });

  test('removing an item from the cart updates the total', () {
    service.addToCart('P001', 2);
    service.addToCart('P002', 1);
    service.removeFromCart('P002');

    expect(service.cart.length, 1);
    expect(service.calculateCartTotal(), 5.0);
  });

  test('total revenue adds up all completed sales', () {
    service.addToCart('P001', 2);
    service.checkout();
    service.addToCart('P002', 1);
    service.checkout();

    expect(service.getTotalRevenue(), 9.0);
  });

  test('quantity above available stock is blocked', () {
    expect(() {
      service.addToCart('P001', 11);
    }, throwsA(isA<InventoryException>()));
  });

  test('zero quantity is rejected', () {
    expect(() {
      service.addToCart('P001', 0);
    }, throwsA(isA<InventoryException>()));
  });

  test('negative quantity is rejected', () {
    expect(() {
      service.addToCart('P001', -2);
    }, throwsA(isA<InventoryException>()));
  });

  test('non-existent product id is rejected', () {
    expect(() {
      service.addToCart('Z00X', 1);
    }, throwsA(isA<InventoryException>()));
  });

  test('checkout with an empty cart is rejected', () {
    expect(() {
      service.checkout();
    }, throwsA(isA<InventoryException>()));
  });

  test('removing an item that is not in the cart is rejected', () {
    expect(() {
      service.removeFromCart('P001');
    }, throwsA(isA<InventoryException>()));
  });

  test('selling exactly the remaining stock succeeds', () {
    service.addToCart('P001', 10);
    service.checkout();
    expect(stockOf('P001'), 0);
  });

  test('adding the same product twice cannot be more than total stock',() {
    service.addToCart('P001', 6);
    expect(() {
      service.addToCart('P001', 5);
    }, throwsA(isA<InventoryException>()));
    expect(service.cart[0].quantity, 6);
  });

  test('failed checkout leaves all stock untouched', () {
    service.addToCart('P001', 2);
    service.addToCart('P002', 5);
    productService.findById('P002')!.stockQuantity = 3; // stock dropped

    expect(() {
      service.checkout();
    }, throwsA(isA<InventoryException>()));

    expect(stockOf('P001'), 10);
    expect(stockOf('P002'), 3);
    expect(service.salesHistory, isEmpty);
  });
}