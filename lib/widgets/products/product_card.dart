import 'package:flutter/material.dart';

import './price_tag.dart';
import './address_tag.dart';
import '../ui_elements/title_default.dart';
import '../../models/product_model.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../scoped-models/main_scoped_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final int productIndex;

  ProductCard(this.product, this.productIndex);

  Widget _buildTitlePriceRow() {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TitleDefault(product.title),
          SizedBox(
            width: 8.0,
          ),
          PriceTag(product.price.toString())
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return ScopedModelDescendant<MainScopedModel>(builder: (
          BuildContext context,Widget child, 
          MainScopedModel model){
                  return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.info),
          color: Theme.of(context).accentColor,
          onPressed: () => Navigator.pushNamed<bool>(
              context, '/product/' + model.allProducts[productIndex].id),
        ),
         IconButton(
          icon: Icon(model.allProducts[productIndex].isFavorite ?
          Icons.favorite: Icons.favorite_border),
          color: Colors.red,
          onPressed: (){

            model.selectProduct(model.allProducts[productIndex].id);
            model.toggleProductFavorite();

          },
        
          
        )
          
      ],
    );

    }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          FadeInImage(image: NetworkImage(product.image),
          height: 300.0,
          fit: BoxFit.cover,
          placeholder: AssetImage('assets/food.jpg'),),
          _buildTitlePriceRow(),
          Text(product.userEmail),
          AddressTag('Union Square, San Francisco'),
          _buildActionButtons(context)
        ],
      ),
    );
    ;
  }
}
