import 'dart:convert';

import 'package:carousel_pro/carousel_pro.dart';
import 'package:dio/dio.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smlao/model/groupfood_model.dart';
import 'package:smlao/model/photo_model.dart';
import 'package:smlao/model/user_model.dart';
import 'package:smlao/showorder/order_finish.dart';
import 'package:smlao/showorder/show_cart.dart';
import 'package:smlao/user/foodmenu13.dart';
import 'package:smlao/user/wait_shop_check_order.dart';
import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/my_style.dart';
import 'package:smlao/utility/signout_process.dart';
import 'package:smlao/utility/sqlite_helper.dart';

class MainUser extends StatefulWidget {
  @override
  _MainUserState createState() => _MainUserState();
}

class _MainUserState extends State<MainUser> {
  UserModel userModel;
  String nameUser;
  int amounts = 0;
  int amount = 1;
  List<UserModel> userModels = [];
  List<PhotoModel> photoModels = [];
  List<GroupFoodModel> groupFoodModels = [];
  List<Widget> shopCards = [];
  String idShop, idGrp, status;

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
    readCurrentInfo();
    findUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(userModel.nameUser),
        title: Center(
            // child: Text(nameUser == null ? 'Main User' : '  $nameUser')),
            child: Text('ບໍລິສັດ ເມືອງລາວ ')),
        actions: <Widget>[
          MyStyle().iconShowCart(
            context,
            amounts,
          ),
        ],
      ),
      drawer: showDrawer(),
      body: ListView(
        padding: EdgeInsets.zero,
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
                      height: 600,
                      // padding: EdgeInsets.all(5.0),
                      child: GridView.extent(
                        // childAspectRatio:
                        //     MediaQuery.of(context).size.height / 400,
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

  Future<Null> findUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      nameUser = preferences.getString('Name');
    });
  }

  Future<Null> readCurrentInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idShop = preferences.getString('id');
    print('idShop ==>> $idShop');

    String url =
        '${MyConstant().domain}/smlao/getUserWhereId.php?isAdd=true&id=2';

    Response response = await Dio().get(url);
    // print('response ==>> $response');

    var result = json.decode(response.data);
    // print('result ==>> $result');
    for (var map in result) {
      print('map ==>> $map');
      setState(() {
        userModel = UserModel.fromJson(map);
        // nameShop = userModel.nameShop;
        // address = userModel.address;
        // phone = userModel.phone;
        // urlPicture = userModel.urlPicture;
        checkAmunt();
      });
    }
  }

  Drawer showDrawer() => Drawer(
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                showHead(),
                menuCart(),
                Divider(),
                menuListShop(),
                Divider(),
                menuStatusFoodOrder(),

                // menuStatus(),
                // ffood(),
                // body(),
                // fcat(),
                // infomationMenu()
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                menuSignOut(),
              ],
            ),
          ],
        ),
      );

  UserAccountsDrawerHeader showHead() {
    return UserAccountsDrawerHeader(
      decoration: MyStyle().myBoxDecoration('user.jpg'),
      currentAccountPicture: MyStyle().showLogo(),
      accountName: Text(
        nameUser == null ? 'Name Login' : nameUser,
        style: TextStyle(color: MyStyle().darkColor),
      ),
      accountEmail: Text(
        'Login',
        style: TextStyle(color: MyStyle().primaryColor),
      ),
    );
  }

  Widget menuCart() {
    return ListTile(
      leading: Icon(Icons.shopping_cart),
      title: Text('ກະຕ່າ'),
      subtitle: Text('ສິຄ້າທີເລຶອກ ແຕ່ຍັງບໍ່ທັນສັ່ງ'),
      onTap: () {
        Navigator.pop(context);
        MaterialPageRoute route = MaterialPageRoute(
          builder: (context) => ShowCart(),
        );
        Navigator.push(context, route).then(
          (value) => readCurrentInfo(),
        );
      },
    );
  }

  Widget menuListShop() {
    return ListTile(
      leading: Icon(Icons.store),
      title: Text('ສິນຄ້າທີ່ກຳລັງສັ່ງ'),
      subtitle: Text('ສະແດງສິນຄ້າທັງໝົດ ທີ່ກຳລັງສັ່ງຊື້'),
      onTap: () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => WaitShopCheckOrder()),
            ModalRoute.withName('/'));

        // Navigator.pop(context);
        // MaterialPageRoute route = MaterialPageRoute(
        //   // builder: (context) => WaitOrder(),
        //   builder: (context) => WaitShopCheckOrder(),
        // );
        // Navigator.push(context, route).then(
        //   (value) => readCurrentInfo(),
        // );
      },
    );
  }

  ListTile menuStatusFoodOrder() {
    return ListTile(
      leading: Icon(Icons.history),
      title: Text('ປະຫວັດການສັ່ງສິນຄ້າ'),
      subtitle: Text('ສະແດງສິນຄ້າທີ່ສັ່ງເຄີຍສັ່ງຜ່ານມາ'),
      onTap: () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => OrderFinish()),
            ModalRoute.withName('/'));

        // Navigator.pop(context);
        // MaterialPageRoute route = MaterialPageRoute(
        //   builder: (context) => OrderFinish(),
        // );
        // Navigator.push(context, route).then(
        //   (value) => readCurrentInfo(),
        // );
      },
    );
  }

  Future<Null> checkAmunt() async {
    await SQLiteHelper().readAllDataFromSQLite().then((value) {
      int i = value.length;
      setState(() {
        amounts = i;
      });
    });
  }

  Widget menuSignOut() {
    return Container(
      decoration: BoxDecoration(color: Colors.green),
      child: ListTile(
        onTap: () => signOutProcess(context),
        leading: Icon(
          Icons.exit_to_app,
          color: Colors.white,
        ),
        title: Text(
          'ອອກຈາກລະບົບ',
          style: TextStyle(color: Colors.white),
        ),
        // subtitle: Text(
        //   'ອອກ',
        //  style: TextStyle(color: Colors.white),
        // ),
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
        Navigator.push(context, route).then((value) => readCurrentInfo());
      },
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 140.0,
              height: 100.0,
              child: Image.network(
                  // backgroundImage: NetworkImage(
                  '${MyConstant().domain}${groupFoodModel.pathImage}'),
              // ),
            ),
            MyStyle().mySizebox(),
            Container(
              width: 140,
              child: Align(
                alignment: Alignment.center,
                child: MyStyle().showTitleH3(groupFoodModel.nameGroup),
              ),
            ),
            // Container(
            //   width: 130,
            //   child: MyStyle().showTitleH3(groupFoodModel.nameGroup),
            // ),
          ],
        ),
      ),
    );
  }
}
