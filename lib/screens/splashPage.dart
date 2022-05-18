import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:smlao/admin/main_admin.dart';

import 'package:smlao/screens/home.dart';

import 'package:smlao/screens/main_rider.dart';
import 'package:smlao/screens/main_shop.dart';
import 'package:smlao/screens/main_user.dart';

import 'package:smlao/utility/color.dart';
import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    checkPreferance();
    Timer(const Duration(milliseconds: 4000), () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              // colors: [orangeColors, orangeLightColors],
              colors: [orangeColors, orangeLightColors],
              end: Alignment.bottomCenter,
              begin: Alignment.topCenter),
        ),
        child: Center(
          child: MyStyle().showLogo(),
        ),
      ),
    );
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
}
