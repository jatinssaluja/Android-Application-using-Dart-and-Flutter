import 'package:flutter/material.dart';

import '../widgets/products/product_list_home.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped-models/main_scoped_model.dart';
import '../widgets/ui_elements/logout_list_tile.dart';

class HomePage extends StatefulWidget {
  final MainScopedModel mainScopedModel;

  HomePage(this.mainScopedModel);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  @override
  initState() {
    widget.mainScopedModel.fetchProducts();
    super.initState();
  }

  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Choose'),
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Manage Products'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/admin');
            },
          ),
          Divider(),
          LogoutListTile()
        ],
      ),
    );
  }

  Widget _buildHomeProductList() {
    return ScopedModelDescendant<MainScopedModel>(
      builder: (BuildContext context, Widget child, MainScopedModel model) {
        Widget content;

        if (model.isLoading) {
          content = Center(
            child: CircularProgressIndicator(),
          );
        } else if (model.allProducts.length > 0) {
          content = HomeProductList();
        } else {
          content = Center(
            child: Text('No Products Found'),
          );
        }

        return RefreshIndicator(
          onRefresh: () {
            return model.fetchProducts();
          },
          child: content,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSideDrawer(context),
      appBar: AppBar(
        title: Text('EasyList'),
        actions: <Widget>[
          ScopedModelDescendant<MainScopedModel>(builder:
              (BuildContext context, Widget child, MainScopedModel model) {
            return IconButton(
              icon: Icon(model.displayFavoritesOnly
                  ? Icons.favorite
                  : Icons.favorite_border),
              onPressed: () {
                model.toggleShowFavorites();
              },
            );
          }),
        ],
      ),
      body: _buildHomeProductList(),
    );
  }
}
