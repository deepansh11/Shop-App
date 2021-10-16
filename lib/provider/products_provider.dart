import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shop_app/models/http_exceptions.dart';
import 'package:shop_app/provider/products.dart';

class Products with ChangeNotifier {
  Products(this._items, this.token, this.userId);

  List<Product> _items = [];

  String token;
  String userId;

  void updateUser(String token, String id) {
    this.userId = id;
    this.token = token;
    notifyListeners();
  }

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavourite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> setProduct([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';

    var url = Uri.parse(
        'https://test-project-8a6f8-default-rtdb.firebaseio.com/products.json?auth=$token&$filterString');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url = Uri.parse(
          'https://test-project-8a6f8-default-rtdb.firebaseio.com/userFavs/$userId.json?auth=$token');
      final favProduct = await http.get(url);
      final favData = json.decode(favProduct.body);
      final List<Product> loadedProds = [];

      extractedData.forEach((prodId, prodData) {
        loadedProds.add(
          Product(
              id: prodId,
              title: prodData['title'],
              description: prodData['description'],
              imageUrl: prodData['imageUrl'],
              price: prodData['price'],
              // ignore: unnecessary_null_comparison
              isFavourite: favData == null
                  ? false
                  : favData[prodId] == null
                      ? false
                      : favData[prodId]['isFav']),
        );
      });

      _items = loadedProds;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://test-project-8a6f8-default-rtdb.firebaseio.com/products.json?auth=$token');
    try {
      final value = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId
          }));

      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(value.body)['name'],
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse(
          'https://test-project-8a6f8-default-rtdb.firebaseio.com/products/$id.json?auth=$token');
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://test-project-8a6f8-default-rtdb.firebaseio.com/products/$id.json?auth=$token');
    final existingProdIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProd = _items[existingProdIndex];
    _items.removeAt(existingProdIndex);
    notifyListeners();
    final res = await http.delete(url);
    if (res.statusCode >= 400) {
      _items.insert(existingProdIndex, existingProd);
      notifyListeners();

      throw HttpException('Could not delete product!');
    }
    existingProd = null;
  }
}
