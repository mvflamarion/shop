import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shop/data/dummy_data.dart';
import 'package:shop/providers/product.dart';

class Products with ChangeNotifier {
  List<Product> _items = DUMMY_PRODUCTS;

  List<Product> get items => [..._items];
  List<Product> get favoriteItems => _items.where((p) => p.isFavorite).toList();
  int get itemsCount => _items.length;

  void addProduct(Product newProduct) {
    _items.add(
      Product(
          id: Random().nextDouble().toString(),
          title: newProduct.title,
          description: newProduct.description,
          price: newProduct.price,
          imageUrl: newProduct.imageUrl),
    );
    notifyListeners();
  }

  void updateProduct(Product product) {
    if (product == null || product.id == null) {
      return;
    }

    final index = _items.indexWhere((prod) => prod.id == product.id);

    if (index >= 0) {
      _items[index] = product;
      notifyListeners();
    }
  }

  void deleteProduct(String productId) {
    final index = _items.indexWhere((product) => product.id == productId);
    if (index >= 0) {
      _items.removeWhere((product) => product.id == productId);
      notifyListeners();
    }
  }
}
