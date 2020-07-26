import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import './product.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  // var _showFavouritesOnly = false;

  final String authToken;
  final String userId;

  Products(
    this.authToken,
    this.userId,
    this._items,
  ); //ensures _items state isnt lost when using proxy provider

  List<Product> get items {
    // if (_showFavouritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavourite).toList();
    // }
    return [
      ..._items
    ]; //returns a copy of items to avoid direct mutation on _items
  }

  List<Product> get favItems {
    return _items.where((prodItem) => prodItem.isFavourite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false ]) async {
    final filterString = filterByUser ? 'orderBy="userId"&equalTo="$userId"' : '';

    var url = 'https://apex-73a20.firebaseio.com/products.json?auth=$authToken&$filterString';

    try {
      final resp = await http.get(url);
      final extractedData = json.decode(resp.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      if (extractedData == null) {
        return;
      }

      url =
          'https://apex-73a20.firebaseio.com/userFavourites/$userId.json?auth=$authToken';

      final favouriteResp = await http.get(url);
      final favouriteData = json.decode(favouriteResp.body);

      extractedData.forEach((key, value) {
        loadedProducts.add(Product(
          id: key,
          title: value['title'],
          description: value['description'],
          price: value['price'],
          isFavourite: favouriteData == null ? false : favouriteData[key] ?? false, // ?? checks for null
          imageUrl: value['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://apex-73a20.firebaseio.com/products.json?auth=$authToken';

    try {
      // exception handling with try-ctach instead of Futures catchError
      final resp = await http.post(
        url, // await block is async, result stored in resp
        body: json.encode({
          // post here is a future type
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavourite': product.isFavourite,
          'userId': userId,
        }),
      );

      final newProduct = Product(
        // use resp (awaits result), code below await block only runs after await is successful
        id: json.decode(resp.body)['name'],
        description: product.description,
        title: product.title,
        price: product.price,
        imageUrl: product.imageUrl,
      );

      _items.add(newProduct);
      notifyListeners(); // notifies
    } catch (error) {
      print(error); //Can add crash reporting library here
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://apex-73a20.firebaseio.com/products/$id.json?auth=$authToken'; // using final and not const since the value is dynamic
      await http.patch(
        url,
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'price': newProduct.price,
        }),
      );
      _items[prodIndex] = newProduct;
      notifyListeners(); // notifies
    } else {
      print('..');
    }
  }

  Future<void> deleteProduct(String id) async {
    //optimistic update demo
    final url =
        'https://apex-73a20.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(
        existingProductIndex); // pattern: rollback if operataion fails
    notifyListeners();
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners(); //dart does not block code execution

      throw HttpException('Could not delete product');
    }
    existingProduct = null;
  }
}
