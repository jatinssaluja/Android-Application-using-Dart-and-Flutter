import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
// import 'package:flutter/rendering.dart';

import './pages/auth.dart';
import './pages/products_admin.dart';
import './pages/home.dart';
import './pages/product.dart';
import './models/product_model.dart';
import './scoped-models/main_scoped_model.dart';

void main() {
  // debugPaintSizeEnabled = true;
  // debugPaintBaselinesEnabled = true;
  // debugPaintPointersEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainScopedModel _mainScopedModel = MainScopedModel();

  @override
  void initState() {
    _mainScopedModel.autoAuthenticate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainScopedModel>(
      model: _mainScopedModel,
      child: MaterialApp(
        // debugShowMaterialGrid: true,
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.deepOrange,
            accentColor: Colors.deepPurple,
            buttonColor: Colors.deepPurple),
        // home: AuthPage(),
        routes: {
          '/': (BuildContext context) => ScopedModelDescendant(
                builder: (BuildContext context, Widget child,
                    MainScopedModel model) {
                  return model.user == null
                      ? AuthPage()
                      : HomePage(_mainScopedModel);
                },
              ),
          '/products': (BuildContext context) => HomePage(_mainScopedModel),
          '/admin': (BuildContext context) =>
              ProductsAdminPage(_mainScopedModel),
        },
        onGenerateRoute: (RouteSettings settings) {
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'product') {
            final String productId = pathElements[2];
            _mainScopedModel.selectProduct(productId);
            return MaterialPageRoute<bool>(
              builder: (BuildContext context) => ProductPage(),
            );
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (BuildContext context) => HomePage(_mainScopedModel));
        },
      ),
    );
  }
}
