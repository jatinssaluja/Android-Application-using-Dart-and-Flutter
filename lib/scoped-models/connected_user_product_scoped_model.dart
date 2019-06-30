import 'package:scoped_model/scoped_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../services/easy_list_api_service.dart';

mixin ConnectedUserProductScopedModel on Model {
  List<ProductModel> _products = [];
  String _selProductId;
  UserModel _authenticatedUser;
  bool _isLoading = false;

  bool get isLoading {
    return _isLoading;
  }
}

mixin ProductScopedModel on ConnectedUserProductScopedModel {
  bool _showFavorites = false;

  List<ProductModel> get allProducts {
    return List.from(_products);
  }

  List<ProductModel> get displayedProducts {
    if (!_showFavorites) {
      return List.from(_products);
    }
    //where returns value of type iterable, so we need to convert
    //it to type List using toList()
    return _products
        .where((ProductModel product) => product.isFavorite)
        .toList();
  }

  String get selectedProductId {
    return _selProductId;
  }

  ProductModel get selectedProduct {
    if (_selProductId == null) {
      return null;
    }
    return _products
        .firstWhere((ProductModel product) => product.id == _selProductId);
  }

  int get selectedProductIndex {
    if (_selProductId != null) {
      return _products
          .indexWhere((ProductModel product) => product.id == _selProductId);
    } else {
      return -1;
    }
  }

  void toggleProductFavorite() {
    final bool currentFavoriteStatus = selectedProduct.isFavorite;
    final bool newFavoriteStatus = !currentFavoriteStatus;

    final ProductModel updatedProduct = ProductModel(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
        isFavorite: newFavoriteStatus);

    _products[selectedProductIndex] = updatedProduct;

    notifyListeners();
    _selProductId = null;
  }

  Future<Null> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    EasyListApiService easyListApiService = new EasyListApiService();

    _products = await easyListApiService.fetchProducts();
    _isLoading = false;
    notifyListeners();
  }

  Future<Null> addProduct(
      String title, String description, String image, double price) async {
    _isLoading = true;
    notifyListeners();

    EasyListApiService easyListApiService = new EasyListApiService();

    final ProductModel product = await easyListApiService.addProduct(
        title,
        description,
        image,
        price,
        _authenticatedUser.email,
        _authenticatedUser.id);

    _isLoading = false;
    _products.add(product);
    // _selProductIndex = null;
    notifyListeners();
  }

  Future<Null> updateProduct(
      String title, String description, String image, double price) async {
    _isLoading = true;
    notifyListeners();

    EasyListApiService easyListApiService = new EasyListApiService();
    final ProductModel product = await easyListApiService.updateProduct(
        title,
        description,
        image,
        price,
        _authenticatedUser.email,
        _authenticatedUser.id,
        selectedProduct.id,
        selectedProduct.isFavorite);

    _isLoading = false;
    _products[selectedProductIndex] = product;
    //_selProductIndex = null;
    notifyListeners();
  }

  Future<Null> deleteProduct() async {
    final productId = selectedProduct.id;
    _products.removeAt(selectedProductIndex);
    _selProductId = null;

    EasyListApiService easyListApiService = new EasyListApiService();
    await easyListApiService.deleteProduct(productId);
    notifyListeners();
  }

  void selectProduct(String productId) {
    _selProductId = productId;
    if (productId != null) {
      notifyListeners();
    }
  }

  void resetSelectedProductId() {
    _selProductId = null;
  }

  void toggleShowFavorites() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }
}

mixin UserScopedModel on ConnectedUserProductScopedModel {
  void login(String email, String password) {
    _authenticatedUser =
        UserModel(id: 'abcd', email: email, password: password);
  }
}
