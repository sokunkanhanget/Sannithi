import 'package:flutter_test/flutter_test.dart';
import 'package:sannithi_app/model/product.dart';
import 'package:sannithi_app/service/inventory_exception.dart';
import 'package:sannithi_app/service/product_service.dart';

void main() {
  ProductService service = ProductService();

  Product makeProduct(String id, String barcode,
      {String name = 'Item', double price = 2, int stock = 20}) {
    return Product(
      id: id,
      name: name,
      barcode: barcode,
      category: 'Test',
      price: price,
      stockQuantity: stock,
    );
  }

  setUp(() {
    service = ProductService();
  });

  test('adding a valid product saves it in the list', () {
    service.addProduct(makeProduct('P001', 'CADT1'));

    expect(service.products.length, 1);
    expect(service.findById('P001')!.name, 'Item');
  });

  test('adding a product with an empty name is rejected', () {
    expect(() {
      service.addProduct(makeProduct('P001', 'CADT1', name: ''));
    }, throwsA(isA<InventoryException>()));
  });

  test('adding a product with an empty barcode is rejected', () {
    expect(() {
      service.addProduct(makeProduct('P001', ''));
    }, throwsA(isA<InventoryException>()));
  });

  test('adding a product with a price of 0 is rejected', () {
    expect(() {
      service.addProduct(makeProduct('P001', 'CADT1', price: 0));
    }, throwsA(isA<InventoryException>()));
  });

  test('adding a product with negative stock is rejected', () {
    expect(() {
      service.addProduct(makeProduct('P001', 'CADT1', stock: -1));
    }, throwsA(isA<InventoryException>()));
  });

  test('adding a product with a duplicate barcode is rejected', () {
    service.addProduct(makeProduct('P001', 'CADT1'));

    expect(() {
      service.addProduct(makeProduct('P002', 'CADT1'));
    }, throwsA(isA<InventoryException>()));
    expect(service.products.length, 1);
  });

  test('adding a product with a duplicate id is rejected', () {
    service.addProduct(makeProduct('P001', 'CADT1'));

    expect(() {
      service.addProduct(makeProduct('P001', 'CADT2'));
    }, throwsA(isA<InventoryException>()));
  });

  test('adding a product with stock 0 is allowed', () {
    service.addProduct(makeProduct('P001', 'CADT1', stock: 0));

    expect(service.findById('P001')!.isOutOfStock, true);
  });

  test('editing a product updates its price', () {
    service.addProduct(makeProduct('P001', 'CADT1'));
    service.editProduct('P001', price: 3.0);

    expect(service.findById('P001')!.price, 3.0);
  });

  test('editing a product and keeping its own barcode is allowed', () {
    service.addProduct(makeProduct('P001', 'CADT1'));
    service.editProduct('P001', name: 'New name', barcode: 'CADT1');

    expect(service.findById('P001')!.name, 'New name');
  });

  test('editing a barcode to one used by another product is rejected', () {
    service.addProduct(makeProduct('P001', 'CADT1'));
    service.addProduct(makeProduct('P002', 'CADT2'));

    expect(() {
      service.editProduct('P002', barcode: 'CADT1');
    }, throwsA(isA<InventoryException>()));
    expect(service.findById('P002')!.barcode, 'CADT2');
  });

  test('editing with an invalid price is rejected', () {
    service.addProduct(makeProduct('P001', 'CADT1'));

    expect(() {
      service.editProduct('P001', price: -5);
    }, throwsA(isA<InventoryException>()));
    expect(service.findById('P001')!.price, 2.5);
  });

  test('editing a non-existing product is rejected', () {
    expect(() {
      service.editProduct('Z00X', price: 3.0);
    }, throwsA(isA<InventoryException>()));
  });

  test('deleting a product removes it from the list', () {
    service.addProduct(makeProduct('P001', 'CADT1'));
    service.deleteProduct('P001');

    expect(service.products, isEmpty);
    expect(service.findById('P001'), isNull);
  });

  test('deleting a non-existing product is rejected', () {
    expect(() {
      service.deleteProduct('Z00X');
    }, throwsA(isA<InventoryException>()));
  });

  test('adding stock increases the quantity', () {
    service.addProduct(makeProduct('P001', 'CADT1', stock: 5));
    service.addStock('P001', 10);

    expect(service.findById('P001')!.stockQuantity, 15);
  });

  test('adding zero stock is rejected', () {
    service.addProduct(makeProduct('P001', 'CADT1'));

    expect(() {
      service.addStock('P001', 0);
    }, throwsA(isA<InventoryException>()));
  });

  test('adding stock to a non-existing product is rejected', () {
    expect(() {
      service.addStock('Z00X', 5);
    }, throwsA(isA<InventoryException>()));
  });

  test('reducing stock decreases the quantity', () {
    service.addProduct(makeProduct('P001', 'CADT1', stock: 10));
    service.reduceStock('P001', 4);

    expect(service.findById('P001')!.stockQuantity, 6);
  });

  test('reducing more than the available stock is rejected', () {
    service.addProduct(makeProduct('P001', 'CADT1', stock: 3));

    expect(() {
      service.reduceStock('P001', 4);
    }, throwsA(isA<InventoryException>()));
    expect(service.findById('P001')!.stockQuantity, 3);
  });

  test('reducing exactly all the stock is allowed', () {
    service.addProduct(makeProduct('P001', 'CADT1', stock: 3));
    service.reduceStock('P001', 3);

    expect(service.findById('P001')!.stockQuantity, 0);
    expect(service.findById('P001')!.isOutOfStock, true);
  });

  test('stock at the threshold is low, stock above it is not', () {
    service.addProduct(makeProduct('P001', 'CADT1', stock: 5));
    service.addProduct(makeProduct('P002', 'CADT2', stock: 6));

    var low = service.getLowStockProducts(5);

    expect(low.length, 1);
    expect(low[0].id, 'P001');
  });

  test('out-of-stock product appears in the low-stock list', () {
    service.addProduct(makeProduct('P001', 'CADT1', stock: 0));

    expect(service.getLowStockProducts(5).length, 1);
  });

  test('a threshold of 0 shows no low-stock products', () {
    service.addProduct(makeProduct('P001', 'CADT1', stock: 0));

    expect(service.getLowStockProducts(0), isEmpty);
  });

  test('restocking removes a product from the low-stock list', () {
    service.addProduct(makeProduct('P001', 'CADT1', stock: 2));
    expect(service.getLowStockProducts(5).length, 1);

    service.addStock('P001', 20);

    expect(service.getLowStockProducts(5), isEmpty);
  });
}