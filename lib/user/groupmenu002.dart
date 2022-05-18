import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:smlao/model/groupfood_model.dart';
import 'package:smlao/model/user_model.dart';
import 'package:smlao/user/foodmenu13.dart';
import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/my_style.dart';
import 'package:smlao/utility/sqlite_helper.dart';

class HomeMenu extends StatefulWidget {
  final UserModel userModel;
  HomeMenu({Key key, this.userModel}) : super(key: key);
  @override
  _HomeMenuState createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> {
  UserModel userModel;
  String idShop;
  int amount = 1;
  double lat1, lng1, lat2, lng2;
  Location location = Location();
  // ignore: deprecated_member_use
  List<GroupFoodModel> groupFoodModels = List();

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    userModel = widget.userModel;

    print('### At groupmenu002 ===>> ${userModel.nameShop}');

    readFoodMenu();
  }

  Future<Null> readFoodMenu() async {
    idShop = userModel.id;
    String url =
        '${MyConstant().domain}/smlao/getGroupFoodWhereIdShop.php?isAdd=true&idShop=$idShop';
    Response response = await Dio().get(url);
    // print('res --> $response');

    var result = json.decode(response.data);
    // print('result = $result');

    for (var map in result) {
      GroupFoodModel groupFoodModel = GroupFoodModel.fromJson(map);
      setState(() {
        groupFoodModels.add(groupFoodModel);
        checkAmunt();
      });
    }
  }

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
          actions: <Widget>[MyStyle().iconShowCart(context, amount)],
          title: Text(userModel.nameShop),
        ),
        body: groupFoodModels.length == 0
            ? MyStyle().showProgress()
            :
            // GridView.count(
            //     crossAxisCount: 3,
            //     crossAxisSpacing: 5,
            //     mainAxisSpacing: 5,
            //     padding: EdgeInsets.all(10.0),
            GridView.extent(
                childAspectRatio: (2 / 2),
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                padding: EdgeInsets.all(10.0),
                maxCrossAxisExtent: 200.0,
                children: List.generate(
                  groupFoodModels.length,
                  (index) => GestureDetector(
                    onTap: () {
                      print('#### You Click index $index');
                      MaterialPageRoute route = MaterialPageRoute(
                        // builder: (context) => Showfood(
                        builder: (context) => FoodMenu(
                          groupFoodModel: groupFoodModels[index],
                          userModel: userModel,
                        ),
                      );
                      Navigator.push(context, route).then(
                        (value) => checkAmunt(),
                      );
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
              ));
  }

  Container showFoodImage(BuildContext context, int index) {
    return Container(
      // child: Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20.0),
            width: 180.0,
            height: 110.0,
            child: Image.network(
                '${MyConstant().domain}${groupFoodModels[index].pathImage}'),
            // fit: BoxFit.cover,
            //  fit: BoxFit.scaleDown,
          ),
          Container(
            // width: 130,
            child: new Text(
              groupFoodModels[index].nameGroup,
              style: MyStyle().mainTitle,
            ),
          ),

          // new Text(
          //   groupFoodModels[index].nameGroup,
          //   style: MyStyle().mainTitle,
          // ),
        ],
      ),
      // ),
    );
  }
}
