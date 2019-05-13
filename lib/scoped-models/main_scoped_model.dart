import 'package:scoped_model/scoped_model.dart';

import './connected_user_product_scoped_model.dart';

class MainScopedModel extends Model with ConnectedUserProductScopedModel,
ProductScopedModel,
UserScopedModel{

} 