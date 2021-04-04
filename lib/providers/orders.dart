import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:shop/utils/constants.dart';
import 'cart.dart';

class Order {
  final String id;
  final double total;
  final double amount;
  final List<CartItem> products;
  final DateTime date;

  Order({
    this.id,
    this.total,
    this.amount,
    this.products,
    this.date,
  });
}

class Orders with ChangeNotifier {
  final String _baseUrl = '${Constants.BASE_API_URL}/orders';
  List<Order> _items = [];
  String _token;
  String _userId;

  Orders([this._token, this._userId, this._items = const []]);

  List<Order> get items {
    return [..._items];
  }

  int get itemsCount => _items.length;

  Future<void> loadOrders() async {
    List<Order> orders = [];
    final response = await get('$_baseUrl/$_userId.json?auth=$_token');
    Map<String, dynamic> data = json.decode(response.body);

    if (data == null) {
      return Future.value();
    }

    data.forEach((key, value) {
      orders.add(
        Order(
          id: key,
          total: value['total'],
          date: DateTime.parse(value['date']),
          products: (value['products'] as List<dynamic>).map((e) {
            return CartItem(
              id: e['id'],
              productId: e['productId'],
              title: e['title'],
              quantity: e['quantity'],
              price: e['price'],
            );
          }).toList(),
        ),
      );
    });

    _items = orders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(Cart cart) async {
    final date = DateTime.now();
    final response = await post(
      '$_baseUrl/$_userId.json?auth=$_token',
      body: json.encode({
        'total': cart.totalAmount,
        'date': date.toIso8601String(),
        'products': cart.items.values
            .map((e) => {
                  'id': e.id,
                  'productId': e.productId,
                  'title': e.title,
                  'quantity': e.quantity,
                  'price': e.price,
                })
            .toList()
      }),
    );
    _items.insert(
      0,
      Order(
        id: json.decode(response.body)['name'],
        total: cart.totalAmount,
        date: date,
        products: cart.items.values.toList(),
      ),
    );

    notifyListeners();
  }
}
