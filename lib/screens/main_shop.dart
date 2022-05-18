import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:smlao/model/user_model.dart';
import 'package:smlao/screens/register.dart';

import 'package:smlao/shop/list_groupfood_menu_shop.dart';
import 'package:smlao/showorder/order_shop.dart';
import 'package:smlao/utility/my_constant.dart';

import 'package:smlao/utility/my_style.dart';
import 'package:smlao/utility/normal_dialog.dart';
import 'package:smlao/utility/signout_process.dart';
import 'package:smlao/shop/infomation_shop.dart';
import 'package:smlao/shop/list_food_manu_shop.dart';
import 'package:smlao/shop/order_list_shop.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainShop extends StatefulWidget {
  @override
  _MainShopState createState() => _MainShopState();
}

class _MainShopState extends State<MainShop> {
  UserModel userModel;
  List<UserModel> userModels = [];
  Widget currentWidget = OrderListShop();
  String idShop;
  String nameUser, nameShop;
  @override
  void initState() {
    super.initState();
    aboutNotification();

    findUser();
  }

  Future<Null> findUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      nameUser = preferences.getString('Name');
    });
  }

  Future<Null> aboutNotification() async {
    if (Platform.isAndroid) {
      print('aboutNoti Work Android');
      FirebaseMessaging firebaseMessaging = FirebaseMessaging();
      // FirebaseMessaging firebaseMessaging = FirebaseMessaging();

      await firebaseMessaging.configure(
        onLaunch: (message) async {
          print('Noti onLaunch');
        },
        onResume: (message) async {
          String title = message['data']['title'];
          String body = message['data']['body'];
          print('Noti onResume ${message.toString()}');
          print('title = $title, body = $body');
          normalDialog2(context, title, body);
        },
        onMessage: (message) async {
          print('Noti onMessage ${message.toString()}');
          String title = message['notification']['title'];
          String notiMessage = message['notification']['body'];
          normalDialog2(context, title, notiMessage);
        },
      );
    } else if (Platform.isIOS) {
      print('aboutNoti Work iOS');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nameShop == null ? 'Main Shop' : 'login  $nameShop'),
        // title: Text(userModel.nameShop),
      ),
      drawer: showDrawer(),
      body: currentWidget,
    );
  }

  Drawer showDrawer() => Drawer(
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                showHead(),

                homeMenu(),
                Divider(),
                orderSell(),
                Divider(),
                groupFoodMenu(),
                Divider(),
                foodMenu(),
                Divider(),
                buildCreateAccount(),
                Divider(),
                infomationMenu(),
                // Column(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: <Widget>[
                //     buildCreateAccount(),
                //   ],
                // ),
              ],
            ),
            // Column(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: <Widget>[
            //     buildCreateAccount(),
            //   ],
            // ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                signOutMenu(),
              ],
            ),
          ],
        ),
      );
  ListTile homeMenu() => ListTile(
        leading: Icon(Icons.home),
        title: Text('ລາຍການສິນຄ້າທີ່ລູກຄ້າສັ່ງ'),
        onTap: () {
          setState(() {
            currentWidget = OrderListShop();
          });
          Navigator.pop(context);
        },
      );
  // ListTile groupFoodMenu() => ListTile(
  //       leading: Icon(Icons.fastfood),
  //       title: Text('ໝວດສິນຄ້າ'),
  //       subtitle: Text('ລາຍການໝວດສິນຄ້າຂອງທ່າ'),
  //       onTap: () {
  //         setState(() {
  //           currentWidget = ListGroupFoodMenu();
  //         });
  //         Navigator.pop(context);
  //       },
  //     );

  Future<Null> readOrderFromIdUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    idShop = preferences.getString(MyConstant().keyId);
    String apiGetOrderWhereIdUser =
        '${MyConstant().domain}/smlao/getOrderWhereIdShop.php?isAdd=true&idShop=$idShop';
    await Dio().get(apiGetOrderWhereIdUser).then((value) {
      // print('value ==>> $value');
      if (value.toString() != 'null') {
        // var result = json.decode(value.data);
        // print('result ==>> $result');

        // for (var item in result) {
        //   UserModel userModel = UserModel.fromJson(item);

        // }
      }
    });
  }

  Widget buildCreateAccount() {
    return ListTile(
      leading: Icon(Icons.person_add),
      title: Text('ສ້າງຜູ້ໃຊ້'),
      subtitle: Text('ສະໝັກບັນຊີຜູ້ໃຊ້'),
      onTap: () {
        Navigator.pop(context);
        MaterialPageRoute route = MaterialPageRoute(
          // builder: (context) => WaitOrder(),
          builder: (context) => Register(),
        );
        Navigator.push(context, route).then(
          (value) => MainShop(),
        );
      },
    );
  }

  Widget groupFoodMenu() {
    return ListTile(
      leading: Icon(Icons.store),
      title: Text('ໝວດສິນຄ້າ'),
      subtitle: Text('ລາຍການໝວດສິນຄ້າຂອງທ່າ'),
      onTap: () {
        Navigator.pop(context);
        MaterialPageRoute route = MaterialPageRoute(
          // builder: (context) => WaitOrder(),
          builder: (context) => ListGroupFoodMenu(),
        );
        Navigator.push(context, route).then(
          (value) => readOrderFromIdUser(),
        );
      },
    );
  }

  ListTile foodMenu() => ListTile(
        leading: Icon(Icons.format_list_bulleted),
        title: Text('ລາຍການສິນຄ້າ'),
        subtitle: Text('ລາຍການສິນຄ້າ ຂອງຮ້ານ'),
        onTap: () {
          setState(() {
            currentWidget = ListFoodMenuShop();
          });
          Navigator.pop(context);
        },
      );
  ListTile orderSell() => ListTile(
        leading: Icon(Icons.storefront),
        title: Text('ລາຍການສິນຄ້າທີຂາຍ'),
        subtitle: Text('ລາຍການສິນຄ້າທີຂາຍ ຂອງຮ້ານ'),
        onTap: () {
          setState(() {
            currentWidget = OrderShop();
          });
          Navigator.pop(context);
        },
      );
  ListTile infomationMenu() => ListTile(
        leading: Icon(Icons.info),
        title: Text('ຂໍ້ມູນຮ້ານ'),
        subtitle: Text('ຂໍ້ມູນຮ້ານ ພ້ອມ Edit'),
        onTap: () {
          setState(() {
            currentWidget = InfomationShop();
          });
          Navigator.pop(context);
        },
      );

  // ListTile signOutMenu() => ListTile(
  //       leading: Icon(Icons.exit_to_app),
  //       title: Text('ອອກ'),
  //       subtitle: Text('ອອກ ເພຶ່ອ ກັບໄປສູ່ ໜ້າທຳອິດ'),
  //       onTap: () => signOutProcess(context),
  //     );

  Widget signOutMenu() {
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

  UserAccountsDrawerHeader showHead() {
    return UserAccountsDrawerHeader(
      decoration: MyStyle().myBoxDecoration('shop.jpg'),
      currentAccountPicture: MyStyle().showLogo(),
      accountName: Text(
        nameUser == null ? 'Name Login' : nameUser,
        style: TextStyle(color: MyStyle().darkColor),
      ),
      accountEmail: Text(
        'ກຳລັງໃຊ້ງານ',
        style: TextStyle(color: MyStyle().primaryColor),
      ),
    );
  }
}
