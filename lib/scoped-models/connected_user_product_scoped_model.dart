import 'package:scoped_model/scoped_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';
import '../services/easy_list_api_service.dart';
import '../models/auth.dart';

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

  void toggleProductFavorite() async {
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

    http.Response response;
    if (newFavoriteStatus) {
      response = await http.put(
          'https://flutter-products-1683f.firebaseio.com/products/${selectedProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(true));
    } else {
      response = await http.delete(
          'https://flutter-products-1683f.firebaseio.com/products/${selectedProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}');
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      final ProductModel updatedProduct = ProductModel(
          id: selectedProduct.id,
          title: selectedProduct.title,
          description: selectedProduct.description,
          price: selectedProduct.price,
          image: selectedProduct.image,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId,
          isFavorite: !newFavoriteStatus);
      _products[selectedProductIndex] = updatedProduct;
      notifyListeners();
    }

    _selProductId = null;
  }

  Future<Null> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    EasyListApiService easyListApiService = new EasyListApiService();

    _products = await easyListApiService.fetchProducts(_authenticatedUser);
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
        _authenticatedUser.id,
        _authenticatedUser);

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
        selectedProduct.isFavorite,
        _authenticatedUser);

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
    await easyListApiService.deleteProduct(productId, _authenticatedUser);
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
  PublishSubject<bool> _userSubject = PublishSubject();
  Timer _authTimer;

  UserModel get user {
    return _authenticatedUser;
  }

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };

    http.Response response;
    if (mode == AuthMode.Login) {
      response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyCEUbNQw77DRKxzTE7GzMRYP5cglkfT0nQ',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      response = await http.post(
          'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyCEUbNQw77DRKxzTE7GzMRYP5cglkfT0nQ',
          body: json.encode(authData),
          headers: {'Content-Type': 'application/json'});
    }

    final Map<String, dynamic> responseData = json.decode(response.body);
    bool hasError = true;
    String message = 'Something went wrong.';
    print(responseData);
    if (responseData.containsKey('idToken')) {
      hasError = false;
      message = 'Authentication succeeded!';
      _authenticatedUser = UserModel(
          id: responseData['localId'],
          email: email,
          token: responseData['idToken']);
      setAuthTimeout(int.parse(responseData['expiresIn']));
      _userSubject.add(true);
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', responseData['idToken']);
      prefs.setString('userEmail', email);
      prefs.setString('userId', responseData['localId']);
      prefs.setString('expiryTime', expiryTime.toIso8601String());
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This email already exists.';
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'This email was not found.';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'The password is invalid.';
    }
    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  void autoAuthenticate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    final String expiryTimeString = prefs.getString('expiryTime');
    if (token != null) {
      final DateTime now = DateTime.now();
      final parsedExpiryTime = DateTime.parse(expiryTimeString);
      if (parsedExpiryTime.isBefore(now)) {
        _authenticatedUser = null;
        notifyListeners();
        return;
      }
      final String userEmail = prefs.getString('userEmail');
      final String userId = prefs.getString('userId');
      final int tokenLifespan = parsedExpiryTime.difference(now).inSeconds;
      _authenticatedUser =
          UserModel(id: userId, email: userEmail, token: token);
      _userSubject.add(true);
      setAuthTimeout(tokenLifespan);

      notifyListeners();
    }
  }

  void logout() async {
    print('Logout');
    _authenticatedUser = null;
    _authTimer.cancel();
    _userSubject.add(false);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userEmail');
    prefs.remove('userId');
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), logout);
  }
}
