import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:smlao/model/groupfood_model.dart';
import 'package:smlao/model/user_model.dart';
import 'package:smlao/user/foodmenu13.dart';
// import 'package:smlao/user/show_shop_food_menu02.dart';
import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/my_style.dart';

class Bodys extends StatefulWidget {
  final UserModel userModel;

  const Bodys({Key key, this.userModel}) : super(key: key);
  @override
  _BodysState createState() => _BodysState();
}

class _BodysState extends State<Bodys> {
  UserModel userModel;
  List<UserModel> userModels = [];
  List<GroupFoodModel> groupFoodModels = [];
  List<Widget> shopCards = [];
  String idShop, idGrp, status;

  @override
  void initState() {
    super.initState();

    readShop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Wrap(
        children: <Widget>[
          MyStyle().showImages(),
          // photohead(),
          // Divider(),
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
      // bottomNavigationBar: Padding(
      //   padding: EdgeInsets.all(8.0),
      //   // ignore: deprecated_member_use
      //   child: RaisedButton(
      //     onPressed: () {},
      //     color: Colors.green,
      //     textColor: Colors.white,
      //     // MyStyle().showImages(),

      //     child: Text('ຂໍອະໄພແອບຂອງພວກເຮົາກຳລັງພັດທະນາ'),
      //   ),
      // ),
    );
  }
}
