import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import './product_card.dart';
import '../../models/product_model.dart';
import '../../scoped-models/main_scoped_model.dart';

class HomeProductList extends StatelessWidget {
  Widget _buildProductList(List<ProductModel> products) {
    Widget productCards;
    if (products.length > 0) {
      productCards = ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
            ProductCard(products[index], index),
        itemCount: products.length,
      );
    } else {
      productCards = Container();
    }
    return productCards;
  }


  @override
  Widget build(BuildContext context) {
    print('[Products Widget] build()');
    return ScopedModelDescendant<MainScopedModel>(builder: (BuildContext context, Widget child, MainScopedModel model) {
      return  _buildProductList(model.displayedProducts);
    },);
  }
}
