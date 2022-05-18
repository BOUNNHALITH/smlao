import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:smlao/model/cart_model.dart';
import 'package:smlao/model/food_model.dart';
import 'package:smlao/model/groupfood_model.dart';
import 'package:smlao/model/user_model.dart';
import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/my_style.dart';
import 'package:smlao/utility/sqlite_helper.dart';
import 'add_food.dart';
import 'edit_food_menu.dart';

class FoodShop extends StatefulWidget {
  final UserModel userModel;
  final GroupFoodModel groupFoodModel;
  FoodShop({Key key, this.groupFoodModel, this.userModel}) : super(key: key);
  @override
  _FoodShopState createState() => _FoodShopState();
}

class _FoodShopState extends State<FoodShop> {
  UserModel userModel;
  GroupFoodModel groupFoodModel;
  String idShop, idGrp, status;
  double lat1, lng1, lat2, lng2;
  // Location location = Location();
  List<CartModel> cartModels = [];
  // ignore: deprecated_member_use
  List<FoodModel> foodModels = List();
  // ignore: deprecated_member_use
  List<GroupFoodModel> groupFoodModels = List();
  // ignore: deprecated_member_use
  List<UserModel> userModels = List();
  int total = 0;
  int amount = 1;
  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    groupFoodModel = widget.groupFoodModel;
    userModel = widget.userModel;
    readFoodMenu();
    // findLocation();
    checkAmunt();
  }

  // Future<Null> findLocation() async {
  //   location.onLocationChanged.listen((event) {
  //     lat1 = event.latitude;
  //     lng1 = event.longitude;
  //   });
  // }

  Future<Null> checkAmunt() async {
    await SQLiteHelper().readAllDataFromSQLite().then((value) {
      int i = value.length;
      setState(() {
        amount = i;
      });
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
        // actions: <Widget>[MyStyle().iconShowCart(context, amount)],
        title: Row(
          children: [
            Text(groupFoodModel.nameGroup),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(8.0),

        // ignore: deprecated_member_use
        child: ElevatedButton(
          onPressed: () {
            MaterialPageRoute route = MaterialPageRoute(
              builder: (context) => AddFood(
                // builder: (context) => FoodShop(
                groupFoodModel: groupFoodModel,
                userModel: userModel,
              ),
            );
            Navigator.push(context, route).then((value) => FoodShop(
                // groupFoodModel: groupFoodModel,
                // userModel: userModel,
                ));
          },
          style: ElevatedButton.styleFrom(
              primary: Colors.green,
              onPrimary: Colors.white
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                "ເພີ່ມສິນຄ້າ",
                style: TextStyle(
                  color: Colors.white,
                  // fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              // addMenuButton(),
            ],
          ),
        ),
      ),
      body: foodModels.length == 0
          ? MyStyle().showProgress()
          : Center(
              child: Container(
                child: GridView.extent(
                  childAspectRatio: (2 / 2),
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  padding: EdgeInsets.all(10.0),
                  maxCrossAxisExtent: 200.0,
                  children: List.generate(
                    foodModels.length,
                    (index) => GestureDetector(
                      onTap: () {},
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
              ),
            ),
    );
  }

  Container showFoodImage(BuildContext context, int index) {
    return Container(
      // child: Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            child: Container(
              // padding: const EdgeInsets.all(8),
              width: 180.0,
              height: 65.0,
              child: Image.network(
                  '${MyConstant().domain}${foodModels[index].pathImage}'),
              // fit: BoxFit.cover,
              //  fit: BoxFit.scaleDown,
            ),
          ),
          // Divider(),
          new Text(
            foodModels[index].nameFood,
            style: MyStyle().mainTitle,
          ),
          new Container(
            alignment: FractionalOffset.center,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(
                  '₭ ${foodModels[index].price} /',
                  style: MyStyle().mainTitle,
                ),
                Text(foodModels[index].detail),
              ],
            ),
          ),

          new Container(
            alignment: FractionalOffset.center,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    MaterialPageRoute route = MaterialPageRoute(
                      builder: (context) => EditFoodMenu(
                        groupFoodModel: groupFoodModel,
                        userModel: userModel,
                        foodModel: foodModels[index],
                      ),
                    );
                    Navigator.push(context, route)
                        .then((value) => readFoodMenu());
                  },
                ),
                Text(
                  '   ${foodModels[index].status}',
                  // style: TextStyle(color: black),
                ),
                IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      deleateFood(foodModels[index]);
                      readFoodMenu();
                    }),
              ],
            ),
          ),

          // ),
        ],
      ),
      // ),
    );
  }

  Future<Null> deleateFood(FoodModel foodModel) async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: MyStyle()
            .showTitleH2('ທ່ານຕ້ອງການລົບເມນູນີ້ແທ້ບໍ ${foodModel.nameFood} ?'),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  String url =
                      '${MyConstant().domain}/smlao/deleteFoodWhereId.php?isAdd=true&id=${foodModel.id}';
                  await Dio().get(url).then((value) {
                    Navigator.pop(context);
                  });
                },
                child: Text('ຍອມຮັບ'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('ປະຕິເສດ'),
              )
            ],
          )
        ],
      ),
    );
  }
}
