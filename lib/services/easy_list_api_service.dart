import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';
import '../models/user_model.dart';

class EasyListApiService {
  static final EasyListApiService _singleton = EasyListApiService._internal();

  factory EasyListApiService() {
    return _singleton;
  }
  EasyListApiService._internal();

  Future<List<ProductModel>> fetchProducts(
      UserModel authenticatedUser, bool onlyForUser) async {
    final response = await http.get(
        'https://flutter-products-1683f.firebaseio.com/products.json?auth=${authenticatedUser.token}');
    final Map<String, dynamic> productListData = json.decode(response.body);
    List<ProductModel> fetchedProductList = [];

    if (productListData != null) {
      productListData.forEach((String productId, dynamic productData) {
        final ProductModel productModel = ProductModel(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            image: productData['image'],
            price: productData['price'],
            userEmail: productData['userEmail'],
            userId: productData['userId'],
            isFavorite: productData['wishlistUsers'] == null
                ? false
                : (productData['wishlistUsers'] as Map<String, dynamic>)
                    .containsKey(authenticatedUser.id));

        fetchedProductList.add(productModel);
      });
    }

    fetchedProductList = onlyForUser
        ? fetchedProductList.where((ProductModel product) {
            return product.userId == authenticatedUser.id;
          }).toList()
        : fetchedProductList;

    return fetchedProductList;
  }

  Future<ProductModel> addProduct(
      String title,
      String description,
      String image,
      double price,
      String userEmail,
      String userId,
      UserModel authenticatedUser) async {
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image':
          'https://image.shutterstock.com/image-photo/milk-chocolate-pieces-isolated-on-260nw-728366752.jpg',
      'price': price,
      'userEmail': userEmail,
      'userId': userId
    };

    final response = await http.post(
        'https://flutter-products-1683f.firebaseio.com/products.json?auth=${authenticatedUser.token}',
        body: json.encode(productData));

    final Map<String, dynamic> responseData = json.decode(response.body);

    final ProductModel product = ProductModel(
        id: responseData['name'],
        title: title,
        description: description,
        image: image,
        price: price,
        userEmail: userEmail,
        userId: userId);

    return product;
  }

  Future<ProductModel> updateProduct(
      String title,
      String description,
      String image,
      double price,
      String userEmail,
      String userId,
      String selectedProductId,
      bool selectedProductFavoriteStatus,
      UserModel authenticatedUser) async {
    final Map<String, dynamic> updatedProductData = {
      'title': title,
      'description': description,
      'image':
          'https://image.shutterstock.com/image-photo/milk-chocolate-pieces-isolated-on-260nw-728366752.jpg',
      'price': price,
      'userEmail': userEmail,
      'userId': userId
    };

    final response = await http.put(
        'https://flutter-products-1683f.firebaseio.com/products/${selectedProductId}.json?auth=${authenticatedUser.token}',
        body: json.encode(updatedProductData));

    final ProductModel product = ProductModel(
        id: selectedProductId,
        title: title,
        description: description,
        image: image,
        price: price,
        userEmail: userEmail,
        userId: userId,
        isFavorite: selectedProductFavoriteStatus);

    return product;
  }

  Future<Null> deleteProduct(
      String productId, UserModel authenticatedUser) async {
    await http.delete(
        'https://flutter-products-1683f.firebaseio.com/products/${productId}.json?auth=${authenticatedUser.token}');
  }
}
