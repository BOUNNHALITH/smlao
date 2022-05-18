import 'dart:convert';

import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smlao/model/groupfood_model.dart';
import 'package:smlao/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/my_style.dart';

import 'food_shop.dart';

class ListFoodMenuShop extends StatefulWidget {
  @override
  _ListFoodMenuShopState createState() => _ListFoodMenuShopState();
}

class _ListFoodMenuShopState extends State<ListFoodMenuShop> {
  UserModel userModel;
  bool loadStatus = true; // Process Load JSON
  bool status = true; // Have Data
  // ignore: deprecated_member_use
  List<GroupFoodModel> groupFoodModels = List();
  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    readGroupFoodMenu();
  }

  // void routeToAddInfo() {
  //   Widget widget = userModel.nameShop.isEmpty ? AddFoodMenu() : EditFoodMenu();
  //   MaterialPageRoute materialPageRoute = MaterialPageRoute(
  //     builder: (context) => widget,
  //   );
  //   Navigator.push(context, materialPageRoute)
  //       .then((value) => readGroupFoodMenu());
  // }

  Future<Null> readGroupFoodMenu() async {
    if (groupFoodModels.length != 0) {
      loadStatus = true;
      status = true;
      var groupFoodModels;
      groupFoodModels.clear();
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idShop = preferences.getString('id');
    print('idShop = $idShop');
    String url =
        '${MyConstant().domain}/smlao/getGroupFoodWhereIdShop.php?isAdd=true&idShop=$idShop';
    await Dio().get(url).then((value) {
      setState(() {
        loadStatus = false;
      });
      if (value.toString() != 'null') {
        // print('value ==>> $value');

        var result = json.decode(value.data);
        print('result ==>> $result');

        for (var map in result) {
          GroupFoodModel groupFoodModel = GroupFoodModel.fromJson(map);
          setState(() {
            groupFoodModels.add(groupFoodModel);
          });
        }
      } else {
        setState(() {
          status = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        loadStatus ? MyStyle().showProgress() : showContent(),
        // addMenuButton(),
      ],
    );
  }

  Widget showContent() {
    return status
        // ? Text('ຍັງບໍ່ມີໝວດສິນຄ້າ')
        ? showListGroupFood()
        : Center(
            child: Text('ຍັງບໍ່ມີໝວດສິນຄ້າ'),
          );
  }

  Widget showListGroupFood() => ListView.builder(
        itemCount: groupFoodModels.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () {
            print('#### You Click index $index');
            MaterialPageRoute route = MaterialPageRoute(
              // builder: (context) => AddFood(
              builder: (context) => FoodShop(
                groupFoodModel: groupFoodModels[index],
                userModel: userModel,
              ),
            );
            Navigator.push(context, route).then(
              (value) => readGroupFoodMenu(),
            );
          },
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Card(
                // child:
                Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10.0),
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.width * 0.3,
                      child: Image.network(
                        '${MyConstant().domain}${groupFoodModels[index].pathImage}',
                        // fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10.0),
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.width * 0.3,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              groupFoodModels[index].nameGroup,
                              style: MyStyle().mainTitle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  // ),
                ),
              ],
            ),
          ),
        ),
      );
}
