import 'package:flutter/material.dart';
import 'package:smlao/model/groupfood_model.dart';
import 'package:smlao/model/user_model.dart';
import 'package:smlao/utility/sqlite_helper.dart';
// import 'about_shop.dart';
import 'foodmenu13.dart';

class Showfood extends StatefulWidget {
  final UserModel userModel;
  final GroupFoodModel groupFoodModel;
  Showfood({Key key, this.groupFoodModel, this.userModel}) : super(key: key);
  @override
  _ShowfoodState createState() => _ShowfoodState();
}

class _ShowfoodState extends State<Showfood> {
  GroupFoodModel groupFoodModel;
  UserModel userModel;
  String idShop, idGrp;
  // ignore: deprecated_member_use
  List<Widget> listWidgets = List();
  int indexPage = 0;

  // get idShop => userModel.nameShop;

  @override
  void initState() {
    super.initState();
    userModel = widget.userModel;
    print('#### Name login = ${userModel.toJson()}');
    groupFoodModel = widget.groupFoodModel;
    print('##### groupFoodModel nameGroup ===>> ${groupFoodModel.toJson()}');

    checkAmunt();
    userModel = widget.userModel;
    listWidgets.add(FoodMenu(
      userModel: userModel,
    ));
  }

  int amount = 0;

  Future<Null> checkAmunt() async {
    await SQLiteHelper().readAllDataFromSQLite().then((value) {
      int i = value.length;
      setState(() {
        amount = i;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // actions: <Widget>[MyStyle().iconShowCart(context, amount)],
        title: Row(
          children: [
            Text(groupFoodModel.nameGroup),
            // Text(userModel.id),
          ],
        ),
      ),
      body: FoodMenu(
        groupFoodModel: groupFoodModel,
        userModel: userModel,
      ),
    );
  }
}
