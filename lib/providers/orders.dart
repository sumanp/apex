import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String  authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = 'https://apex-73a20.firebaseio.com/orders/$userId.json?auth=$authToken';
    final resp = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(resp.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
        id: orderId,
        amount: orderData['amount'],
        dateTime: DateTime.parse(orderData['dateTime']),
        products: (orderData['products'] as List<dynamic>)
            .map((item) => CartItem(
                  id: item['id'],
                  price: item['price'],
                  quantity: item['quantity'],
                  title: item['title'],
                ))
            .toList(),
      ));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = 'https://apex-73a20.firebaseio.com/orders/$userId.json?auth=$authToken';
    final timestamp = DateTime.now();

    try {
      final resp = await http.post(
        url, // await block is async, result stored in resp
        body: json.encode({
          // post here is a future type
          'amount': total,
          'dateTime':
              timestamp.toIso8601String(), //store in string representation
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList(),
        }),
      );

      final newOrder = OrderItem(
          id: json.decode(resp.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: timestamp);

      _orders.add(newOrder);
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
}
