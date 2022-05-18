import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smlao/model/cart_model.dart';
import 'package:smlao/model/food_model.dart';
import 'package:smlao/model/groupfood_model.dart';
import 'package:smlao/model/user_model.dart';
import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/my_style.dart';
import 'package:smlao/utility/normal_dialog.dart';
import 'package:smlao/utility/sqlite_helper.dart';
import 'package:toast/toast.dart';

class FoodMenu extends StatefulWidget {
  final UserModel userModel;
  final GroupFoodModel groupFoodModel;
  FoodMenu({Key key, this.groupFoodModel, this.userModel}) : super(key: key);
  @override
  _FoodMenuState createState() => _FoodMenuState();
}

class _FoodMenuState extends State<FoodMenu> {
  final money = NumberFormat('#,##0', 'en_US');
  UserModel userModel;
  GroupFoodModel groupFoodModel;
  String idShop, idUser, idGrp, status, id;
  double lat1, lng1, lat2, lng2;
  Location location = Location();
  List<CartModel> cartModels = [];
  List<FoodModel> foodModels = [];
  List<GroupFoodModel> groupFoodModels = [];
  List<UserModel> userModels = [];
  int total = 0;
  int amount = 1;
  int amounts = 0;
  // int get length =amout++;
  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    groupFoodModel = widget.groupFoodModel;
    userModel = widget.userModel;
    readFoodMenu();
    readShopss();
    // checkAmunt();
    readCurrentInfo();
  }

  Future<Null> checkAmunt() async {
    await SQLiteHelper().readAllDataFromSQLite().then((value) {
      int i = value.length;
      setState(() {
        amounts = i;
      });

      //  else {
      //   if (value.length) {
      //     setState(() {
      //       amount = i + 1;
      //     });
      //   }
      // else {
      //   setState(() {
      //     amount = i + 1;
      //   });
      // }
    });
  }

  Future<Null> readCurrentInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idUser = preferences.getString('id');
    print('idUser ==>> $idUser');

    String url =
        '${MyConstant().domain}/smlao/getUserWhereId.php?isAdd=true&id=$idUser';

    Response response = await Dio().get(url);
    // print('response ==>> $response');

    var result = json.decode(response.data);
    // print('result ==>> $result');
    for (var map in result) {
      print('map ==>> $map');
      setState(() {
        userModel = UserModel.fromJson(map);
        idUser = userModel.id;
        checkAmunt();
        // address = userModel.address;
        // phone = userModel.phone;
      });
    }
  }

  Future<Null> readShopss() async {
    // idShop == userModel.id;
    String url =
        '${MyConstant().domain}/smlao/getUserWhereIdShop.php?isAdd=true&idShop=2';
    await Dio().get(url).then((value) {
      // print('value = $value');
      var result = json.decode(value.data);
      // int index = 0;
      for (var map in result) {
        UserModel models = UserModel.fromJson(map);

        String nameShop = models.nameShop;
        if (nameShop.isNotEmpty) {
          // print('NameShop = ${models.nameShop}');
          setState(() {
            userModels.add(models);
            // shopCards.add(createCard(models, index));
            // index++;
          });
        }
      }
    });
  }

  Future<Null> readFoodMenu() async {
    idGrp = groupFoodModel.id;
    idShop = groupFoodModel.idShop;
    String url =
        '${MyConstant().domain}/smlao/getGroupFoodWhereIdGrp.php?isAdd=true&idGrp=$idGrp&idShop=$idShop';

    Response response = await Dio().get(url);
    if (response.toString() != 'null') {
      var result = json.decode(response.data);
      for (var map in result) {
        FoodModel foodModel = FoodModel.fromJson(map);
        // if (!((foodModel.status == 'bormee') ||
        //       (foodModel.status == 'CancelOrder'))) {
        if (!((foodModel.status == 'bormee')))
          setState(() {
            foodModels.add(foodModel);
          });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[MyStyle().iconShowCart(context, amounts)],
        title: Text(groupFoodModel.nameGroup),
      ),
      body: foodModels.length == 0
          ? MyStyle().showProgress()
          : GridView.extent(
              childAspectRatio: (2 / 2),
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              padding: EdgeInsets.all(10.0),
              maxCrossAxisExtent: 200.0,
              children: List.generate(
                foodModels.length,
                (index) => GestureDetector(
                  onTap: () {
                    // print('You Click index = $index');
                    amount = 1;
                    confirmOrder(index);
                    // checkAmunt();
                  },
                  child: Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        showFoodImage(context, index),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildTotal() => Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Row(
              children: <Widget>[
                MyStyle().showTitleH4('  ລວມ : '),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: MyStyle().showTitleH4('${total.toString()} ກີບ'),
          )
        ],
      );
  Container showFoodImage(BuildContext context, int index) {
    return Container(
      // child: Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            child: Container(
              // padding: const EdgeInsets.all(8),
              width: 140.0,
              height: 100.0,
              child: Image.network(
                  '${MyConstant().domain}${foodModels[index].pathImage}'),
              // fit: BoxFit.cover,
              //  fit: BoxFit.scaleDown,
            ),
          ),
          Divider(),
          new Text(
            foodModels[index].nameFood,
            style: MyStyle().mainTitle,
          ),
          new Container(
            alignment: FractionalOffset.center,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // new Text(
                //   money.format(int.parse('₭ ${foodModels[index].price}')),
                //   style: MyStyle().mainTitle,
                // ),
                new Text(
                  money.format(int.parse(foodModels[index].price)),
                  style: MyStyle().mainTitle,
                ),
                new Text(
                  '₭/ ${foodModels[index].detail}',
                  // style: MyStyle().mainTitle,
                ),
                // Text(foodModels[index].detail),
              ],
            ),
          ),
          // mee(),
          // new Text(
          //   '${foodModels[index].detail}',
          //   style: new TextStyle(
          //       color: Color(0xFF84A2AF), fontWeight: FontWeight.bold),
          // ),
        ],
      ),
      // ),
    );
  }

  Future<Null> confirmOrder(int index) async {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                foodModels[index].nameFood,
                style: MyStyle().mainH2Title,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 210,
                height: 170,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: NetworkImage(
                        '${MyConstant().domain}${foodModels[index].pathImage}'),
                    // fit: BoxFit.cover),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.add_circle,
                      size: 36,
                      color: Colors.green,
                    ),
                    onPressed: () {
                      setState(() {
                        amount++;
                      });
                      // checkAmunt();
                    },
                  ),
                  Text(
                    amount.toString(),
                    style: MyStyle().mainTitle,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle,
                      size: 36,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      if (amount > 1) {
                        setState(
                          () {
                            amount--;
                          },
                        );
                      }
                    },
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                    width: 110,
                    child: ElevatedButton(
                      onPressed: () {
                        addOrderToCart(index);
                        readCurrentInfo();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'ຕົກລົງ',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Container(
                    width: 110,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'ຍົກເລິກ',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<Null> addOrderToCart(int index) async {
    String idUser = userModel.id;
    String idFood = foodModels[index].id;
    String nameFood = foodModels[index].nameFood;
    String price = foodModels[index].price;
    String detail = foodModels[index].detail;

    int priceInt = int.parse(price);
    int sumInt = priceInt * amount;

    print(
        '####===>>>  idShop = 2, idFood = $idFood, nameFood = $nameFood, price = $price, amount = $amount, sum = $sumInt');

    Map<String, dynamic> map = Map();

    map['idShop'] = idShop;
    map['idUser'] = idUser;
    map['idFood'] = idFood;
    map['nameFood'] = nameFood;
    map['price'] = price;
    map['detail'] = detail;
    map['amount'] = amount.toString();
    map['sum'] = sumInt.toString();
    print('map ==> ${map.toString()}');
    CartModel cartModel = CartModel.fromJson(map);
    var object = await SQLiteHelper().readAllDataFromSQLite();
    print('object lenght = ${object.length}');

    if (object.length == 0) {
      await SQLiteHelper().insertDataToSQLite(cartModel).then((value) {
        print('Insert Success');
        // showToast('Insert Success');
      });
    } else {
      String idShopSQLite = object[0].idShop;
      print('idShopSQLite ==> $idShopSQLite');
      if (idShop == idShopSQLite) {
        await SQLiteHelper().insertDataToSQLite(cartModel).then((value) {
          print('Insert Success');
          // showToast('Insert Success');
        });
      } else {
        normalDialog(context,
            'ກະຕ່າ ມີລາຍການສິນຄ້າຂອງຮ້ານນີ້ ${object[0].nameShop}ກະລຸນາຊື້ຈາກຮ້ານນີ້ໃຫ້ ສຳເລັດກ່ອນ');
      }
    }
  }

  void showToast(String string) {
    Toast.show(
      string,
      context,
      duration: Toast.LENGTH_LONG,
    );
  }
}
