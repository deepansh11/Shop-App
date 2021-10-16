import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/provider/cart.dart';
import 'package:http/http.dart' as http;

class Orders with ChangeNotifier {
  List<OrderItems> _orders = [];
  final String token;
  final String userId;

  Orders(this._orders, this.token, this.userId);

  List<OrderItems> get orders {
    return [..._orders];
  }

  Future<void> setOrders() async {
    final url = Uri.parse(
        'https://test-project-8a6f8-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token');
    final res = await http.get(url);
    final List<OrderItems> orderItems = [];
    final extractedData = json.decode(res.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      orderItems.add(OrderItems(
          orderId: orderId,
          price: orderData['price'],
          products: (orderData['products'] as List<dynamic>)
              .map(
                (e) => CartItem(
                  id: e['id'],
                  title: e['title'],
                  quantity: e['quantity'],
                  price: e['price'],
                ),
              )
              .toList(),
          dateTime: DateTime.parse(
            orderData['dateTime'],
          )));
    });
    _orders = orderItems.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrders(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://test-project-8a6f8-default-rtdb.firebaseio.com/orders/$userId.json?auth=$token');
    final timeStamp = DateTime.now();
    final res = await http.post(url,
        body: json.encode({
          'price': total,
          'products': cartProducts
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'price': e.price,
                    'quantity': e.quantity
                  })
              .toList(),
          'dateTime': timeStamp.toIso8601String(),
        }));
    _orders.insert(
      0,
      OrderItems(
        orderId: json.decode(res.body)['name'],
        price: total,
        products: cartProducts,
        dateTime: timeStamp,
      ),
    );
    notifyListeners();
  }
}

class OrderItems {
  final String orderId;
  final double price;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItems({
    required this.orderId,
    required this.price,
    required this.products,
    required this.dateTime,
  });
}
