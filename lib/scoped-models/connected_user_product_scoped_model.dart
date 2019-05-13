import 'package:scoped_model/scoped_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

mixin ConnectedUserProductScopedModel on Model{

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
    if(!_showFavorites){
    return List.from(_products);
    }
    //where returns value of type iterable, so we need to convert 
    //it to type List using toList()
    return _products.where((ProductModel product)=>product.isFavorite).toList();
  }

  String get selectedProductId {
    return _selProductId;
  }

  ProductModel get selectedProduct {
    if (_selProductId == null) {
      return null;
    }
    return _products.firstWhere((ProductModel product)=>product.id ==_selProductId);
  }

  int get selectedProductIndex {

    if(_selProductId != null){

    return _products.
    indexWhere((ProductModel product)=> product.id == _selProductId);
    } else {
      return -1;
    }
  }

void toggleProductFavorite(){

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

Future<Null> fetchProducts(){

  _isLoading = true;
  notifyListeners();
  return http.get('https://flutter-products-1683f.firebaseio.com/products.json')
  .then((http.Response response){

    _isLoading = false;
    final Map<String,dynamic> productListData =json.decode(response.body);

  final List<ProductModel> fetchedProductList = [];

   if(productListData != null){

   productListData.forEach((String productId, dynamic productData){

   final ProductModel productModel =ProductModel(
     id:productId,
     title: productData['title'],
     description: productData['description'],
     image: productData['image'],
     price: productData['price'],
     userEmail: productData['userEmail'],
     userId: productData['userId']
   );
   
   fetchedProductList.add(productModel);
   
   });

    _products =fetchedProductList;
 }

  
   notifyListeners();

  });

}

Future<Null> addProduct(String title, String description,
        String image,double price) {

    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> productData ={

      'title':title,
      'description':description,
      'image':'https://image.shutterstock.com/image-photo/milk-chocolate-pieces-isolated-on-260nw-728366752.jpg',
      'price':price,
      'userEmail':_authenticatedUser.email,
       'userId':_authenticatedUser.id

    } ;      

     return http.post('https://flutter-products-1683f.firebaseio.com/products.json',
     body: json.encode(productData)).then((http.Response response){

     _isLoading = false;
     final Map<String, dynamic> responseData = json.decode(response.body);

     final ProductModel product =ProductModel(id:responseData['name'], title:title,
     description: description, image: image, price: price,
     userEmail: _authenticatedUser.email,
     userId: _authenticatedUser.id);

    _products.add(product);
   // _selProductIndex = null;
    notifyListeners();


     }) ;    

     
  }
  

  Future<Null> updateProduct(String title, String description,
        String image,double price) {

    _isLoading = true;      
     notifyListeners();

    final Map<String, dynamic> updatedProductData ={

      'title':title,
      'description':description,
      'image':'https://image.shutterstock.com/image-photo/milk-chocolate-pieces-isolated-on-260nw-728366752.jpg',
      'price':price,
      'userEmail':_authenticatedUser.email,
       'userId':_authenticatedUser.id

    } ;        

    return http.put('https://flutter-products-1683f.firebaseio.com/products/${selectedProduct.id}.json',
    body: json.encode(updatedProductData)).then((http.Response response){

      _isLoading = false;

      final ProductModel product =ProductModel(
      
     id: selectedProduct.id, 
     title:title,
     description: description, image: image, price: price,
     userEmail: _authenticatedUser.email,
     userId: _authenticatedUser.id,
     isFavorite: selectedProduct.isFavorite);

    _products[selectedProductIndex] = product;
    //_selProductIndex = null;
    notifyListeners();


    });      

    
  }

  void deleteProduct() {

    final productId = selectedProduct.id;
    _products.removeAt(selectedProductIndex);
    _selProductId = null;

    http.delete('https://flutter-products-1683f.firebaseio.com/products/${productId}.json')
   .then((http.Response response){
        notifyListeners();

    });
   
  }

  void selectProduct(String productId) {
    _selProductId = productId;
    if (productId != null) {
    notifyListeners();
  }
  }

  void toggleShowFavorites(){
    _showFavorites = !_showFavorites;
    notifyListeners();
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }
}



mixin UserScopedModel on ConnectedUserProductScopedModel{

 

 void login(String email, String password){

   _authenticatedUser =UserModel(id:'abcd',
   email: email,password: password);

 }


}