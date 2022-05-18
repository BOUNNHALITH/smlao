import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smlao/admin/main_admin.dart';
import 'package:smlao/model/user_model.dart';
import 'package:smlao/screens/aboutUs.dart';
import 'package:smlao/screens/login.dart';
import 'package:smlao/screens/main_rider.dart';
import 'package:smlao/screens/main_shop.dart';
import 'package:smlao/screens/main_user.dart';
import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/my_style.dart';
import 'package:smlao/utility/sqlite_helper.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  UserModel userModel;
  List<Widget> listWidgets = [];
  int indexPage = 0;

  int amount = 0;

  @override
  void initState() {
    super.initState();
    checkAmunt();
    checkPreferance();
    // listWidgets.add(SignIn());
    listWidgets.add(Login());
    listWidgets.add(AboutUs());
  }

  Future<Null> checkPreferance() async {
    try {
      FirebaseMessaging firebaseMessaging = FirebaseMessaging();
      String token = await firebaseMessaging.getToken();
      print('token ====>>> $token');

      SharedPreferences preferences = await SharedPreferences.getInstance();
      String chooseType = preferences.getString('ChooseType');
      String idLogin = preferences.getString('id');
      print('idLogin = $idLogin');

      if (idLogin != null && idLogin.isNotEmpty) {
        String url =
            '${MyConstant().domain}/smlao/editTokenWhereId.php?isAdd=true&id=$idLogin&Token=$token';
        await Dio()
            .get(url)
            .then((value) => print('###### Update Token Success #####'));
      }

      if (chooseType != null && chooseType.isNotEmpty) {
        if (chooseType == 'ຜູ້ໃຊ້') {
          routeToService(MainUser());
        } else if (chooseType == 'ຮ້ານຄ້າ') {
          routeToService(MainShop());
        } else if (chooseType == 'ຜູ້ສົງອາຫານ') {
          routeToService(MainRider());
        } else if (chooseType == 'ຫົວໜ້າ') {
          routeToService(Admin());
        } else {
          // normalDialog(context, 'Error User Type');
        }
      }
    } catch (e) {}
  }

  void routeToService(Widget myWidget) {
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => myWidget,
    );
    Navigator.pushAndRemoveUntil(context, route, (route) => false);
  }

  BottomNavigationBarItem showMenuFoodNav() {
    return BottomNavigationBarItem(
      icon: Icon(Icons.login),
      // ignore: deprecated_member_use
      label: ('ເຂົ້າສູ່ລະບົບ'),
    );
  }

  BottomNavigationBarItem aboutShopNav() {
    return BottomNavigationBarItem(
      icon: Icon(Icons.info),
      // ignore: deprecated_member_use
      label: ('ຂໍ້ມູນບໍລິສັດ'),
    );
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
        // actions: <Widget>[MyStyle().iconShowCart(context, amount)],

        title: Center(child: Text('ບໍລິສັດ ເມືອງລາວ ຍິນດີຕ້ອນຮັບ')),
      ),
      body:
          //  Column(children: <Widget>[
          //   ListTile(
          //     leading: Icon(Icons.fastfood),
          //     title: Text('ເລຶກໝວດສິນຄ້າທີ່ທ່ານຕ້ອງການ'),
          //     // onTap: () {
          //     //   currentWidget = ShowListShopAll();
          //     // },
          //   ),
          listWidgets.length == 0
              ? MyStyle().showProgress()
              : listWidgets[indexPage],
      bottomNavigationBar: showBottonNavigationBar(),
      // ]),
    );
  }

  BottomNavigationBar showBottonNavigationBar() => BottomNavigationBar(
        backgroundColor: Colors.green,
        selectedItemColor: Colors.white,
        currentIndex: indexPage,
        onTap: (value) {
          setState(() {
            indexPage = value;
          });
        },
        items: <BottomNavigationBarItem>[
          showMenuFoodNav(),
          // groupFood(),
          aboutShopNav(),
          // groupFood1(),
        ],
      );
}
