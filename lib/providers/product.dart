import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product({
    @required this.id,
    @required this.description,
    @required this.title,
    @required this.price,
    @required this.imageUrl,
    this.isFavourite = false,
  });

  void _setFavValue(bool newValue) {
    isFavourite = newValue;
    notifyListeners();
  }

  Future<void> toggleFav() async {
    final oldStatus = isFavourite;
    isFavourite = !isFavourite;
    notifyListeners();
    final url =
        'https://apex-73a20.firebaseio.com/products/$id.json'; // using final and not const since the value is dynamic
    try {
      final resp = await http.patch(
        //patch put delete dont return error codes
        url,
        body: json.encode({
          'isFavourite': isFavourite,
        }),
      );
      if (resp.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (error) {
      _setFavValue(oldStatus);
    }
  }
}
