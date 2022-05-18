import 'dart:convert';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:smlao/model/groupfood_model.dart';
import 'package:smlao/model/photo_model.dart';
import 'package:smlao/model/user_model.dart';
import 'package:smlao/user/foodmenu13.dart';
import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/my_style.dart';

class HomeShop extends StatefulWidget {
  @override
  _HomeShopState createState() => _HomeShopState();
}

class _HomeShopState extends State<HomeShop> {
  UserModel userModel;
  List<UserModel> userModels = [];
  List<PhotoModel> photoModels = [];
  List<GroupFoodModel> groupFoodModels = [];
  List<Widget> shopCards = [];
  String idShop, idGrp, status;
  // final List<String> images = [
  //   'images/3333.jpg',
  //   'images/4444.jpg',
  //   'images/1111.png',
  // ];
  final List<String> images = [
    '${MyConstant().domain}/smlao/Photo/1111.png',
    '${MyConstant().domain}/smlao/Photo/2222.jpg',
    '${MyConstant().domain}/smlao/Photo/3333.png',
    '${MyConstant().domain}/smlao/Photo/4444.png',
    '${MyConstant().domain}/smlao/Photo/5555.png',
  ];
  @override
  void initState() {
    super.initState();
    readShop();
    // readPhoto();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Wrap(
        children: <Widget>[
          SizedBox(
            child: Carousel(
              images: images
                  .map((item) => Container(
                        child: Image.network(
                          item,
                          fit: BoxFit.cover,
                        ),
                      ))
                  .toList(),
              dotSpacing: 15.0,
              dotSize: 6.0,
              dotIncreasedColor: Colors.green,
              dotBgColor: Colors.transparent,
              indicatorBgPadding: 10.0,
              autoplay: true,
              autoplayDuration: Duration(seconds: 8),
              // dotPosition: DotPosition.topCenter,
            ),
            height: 180.0,
            width: double.infinity,
          ),
          ListTile(
            leading: Icon(Icons.fastfood),
            title: Text(' ເລຶອກປະເພດສິນຄ້າທ່ານຕ້ອງການ'),
            // onTap: () {
            //   currentWidget = ShowListShopAll();
            // },
          ),
          shopCards.length == 0
              ? MyStyle().showProgress()
              : Wrap(
                  children: [
                    Container(
                      height: 450,
                      child: GridView.extent(
                        maxCrossAxisExtent: 220.0,
                        mainAxisSpacing: 10.0,
                        crossAxisSpacing: 10.0,
                        children: shopCards,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Future<Null> readShop() async {
    String url =
        '${MyConstant().domain}/smlao/getGroupFoodWhereIdShop.php?isAdd=true&idShop=2';
    await Dio().get(url).then((value) {
      // print('value = $value');
      var result = json.decode(value.data);
      int index = 0;
      for (var map in result) {
        GroupFoodModel model = GroupFoodModel.fromJson(map);

        String nameGroup = model.nameGroup;
        if (nameGroup.isNotEmpty) {
          print('NameGroup = ${model.nameGroup}');
          setState(() {
            groupFoodModels.add(model);
            shopCards.add(createCard(model, index));
            index++;
          });
        }
      }
    });
  }

  Widget createCard(GroupFoodModel groupFoodModel, int index) {
    return GestureDetector(
      onTap: () {
        print('You Click index $index');
        MaterialPageRoute route = MaterialPageRoute(
          builder: (context) => FoodMenu(
            groupFoodModel: groupFoodModels[index],
            userModel: userModel,
          ),
        );
        Navigator.push(context, route);
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 80.0,
              height: 80.0,
              child: Image.network(
                  // backgroundImage: NetworkImage(
                  '${MyConstant().domain}${groupFoodModel.pathImage}'),
              // ),
            ),
            MyStyle().mySizebox(),
            Container(
              width: 120,
              child: MyStyle().showTitleH3(groupFoodModel.nameGroup),
            ),
          ],
        ),
      ),
    );
  }
}
