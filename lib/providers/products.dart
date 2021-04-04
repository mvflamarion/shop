import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/providers/product.dart';
import 'package:http/http.dart';
import 'package:shop/utils/constants.dart';

class Products with ChangeNotifier {
  final String _baseUrl = '${Constants.BASE_API_URL}/products';
  List<Product> _items = [];
  String _token;
  String _userId;

  Products([this._token, this._userId, this._items = const []]);

  List<Product> get items => [..._items];
  List<Product> get favoriteItems => _items.where((p) => p.isFavorite).toList();
  int get itemsCount => _items.length;

  Future<void> loadProducts() async {
    _items.clear();

    final response = await get('$_baseUrl.json?auth=$_token');
    final favoriteResponse = await get(
        '${Constants.BASE_API_URL}/userFavorites/$_userId.json?auth=$_token');
    final favMap = json.decode(favoriteResponse.body);

    Map<String, dynamic> data = json.decode(response.body);
    if (data == null) {
      return Future.value();
    }

    data.forEach((key, value) {
      final isFavorite = favMap == null ? false : favMap[key] ?? false;
      _items.add(Product(
        id: key,
        title: value['title'],
        description: value['description'],
        price: value['price'],
        imageUrl: value['imageUrl'],
        isFavorite: isFavorite,
      ));
    });
    notifyListeners();
  }

  Future<void> addProduct(Product newProduct) async {
    var response = await post(
      '$_baseUrl.json?auth=$_token',
      body: json.encode({
        'title': newProduct.title,
        'description': newProduct.description,
        'price': newProduct.price,
        'imageUrl': newProduct.imageUrl,
      }),
    );

    _items.add(Product(
      id: json.decode(response.body)['name'],
      title: newProduct.title,
      description: newProduct.description,
      price: newProduct.price,
      imageUrl: newProduct.imageUrl,
    ));
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    if (product == null || product.id == null) {
      return;
    }

    final index = _items.indexWhere((prod) => prod.id == product.id);

    if (index >= 0) {
      await patch(
        '$_baseUrl/${product.id}.json?auth=$_token',
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl
        }),
      );
      _items[index] = product;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    final index = _items.indexWhere((product) => product.id == productId);
    if (index >= 0) {
      final product = _items[index];
      _items.remove(product);
      notifyListeners();

      final response =
          await delete('$_baseUrl/${product.id}.json?auth=$_token');

      if (response.statusCode >= 400) {
        _items.insert(index, product);
        notifyListeners();
        throw HttpException('Ocorreu um erro na exclusão do produto.');
      }
    }
  }
}
