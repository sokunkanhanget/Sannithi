import 'package:flutter/material.dart';

abstract class Product {
  final String id;
  String name;
  String barcode;
  String category;
  double price;
  int stockQuantity;

  Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.category,
    required this.price,
    required this.stockQuantity,
  });

  bool get isOutOfStock => stockQuantity == 0;

  bool isLowStock(int threshold) => threshold > 0 && stockQuantity <= threshold; 

}