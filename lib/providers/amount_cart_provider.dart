import 'package:flutter/foundation.dart';
import 'package:smlao/model/amount_cart_model.dart';

class AmountCartProvider with ChangeNotifier {
  AmountCartModel amountCartModel;

  int getAmountCart() {
    return amountCartModel.amountCart;
  }

  void addAmountCart(int amountCart) {}
}
