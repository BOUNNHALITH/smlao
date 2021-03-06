import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:smlao/model/user_model.dart';
import 'package:smlao/screens/home22.dart';
// import 'package:smlao/user/body.dart';
import 'package:smlao/user/show_shop_food_menu02.dart';
import 'package:smlao/utility/signout_process.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smlao/screens/signIn.dart';
import 'package:smlao/admin/signup.dart';
import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/my_style.dart';

class Admin extends StatefulWidget {
  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  String nameUser;
  // Widget currentWidget;
  // ignore: deprecated_member_use
  List<UserModel> userModels = List();
  // ignore: deprecated_member_use
  List<Widget> shopCards = List();

  // Widget currentWidget;

  @override
  void initState() {
    super.initState();
    // currentWidget = ShowListShopAll();
    // findUser();
    // checkPreferance();
    readShop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('smlao food online'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => signOutProcess(context),
          )
        ],
      ),
      drawer: showDrawer(),
      body: shopCards.length == 0
          ? MyStyle().showProgress()
          : GridView.extent(
              maxCrossAxisExtent: 220.0,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              children: shopCards,
            ),
    );
  }

  Drawer showDrawer() => Drawer(
        child: ListView(
          children: <Widget>[
            showHeadDrawer(),
            signInMenu(),
            signUpMenu(),
            listMenu(),
            listww(),
          ],
        ),
      );

  ListTile signInMenu() {
    return ListTile(
      leading: Icon(Icons.login),
      title: Text('???????????????????????????????????????'),
      onTap: () {
        Navigator.pop(context);
        MaterialPageRoute route =
            MaterialPageRoute(builder: (value) => SignIn());
        Navigator.push(context, route);
      },
    );
  }

  ListTile listww() {
    return ListTile(
      leading: Icon(Icons.menu),
      title: Text('????????????1'),
      onTap: () {
        Navigator.pop(context);
        MaterialPageRoute route =
            MaterialPageRoute(builder: (value) => Bodys());
        Navigator.push(context, route);
      },
    );
  }

  ListTile listMenu() {
    return ListTile(
      leading: Icon(Icons.menu),
      title: Text('????????????'),
      onTap: () {
        Navigator.pop(context);
        MaterialPageRoute route =
            MaterialPageRoute(builder: (value) => Bodys());
        Navigator.push(context, route);
      },
    );
  }

  ListTile signUpMenu() {
    return ListTile(
      leading: Icon(Icons.how_to_reg),
      title: Text('????????????????????????'),
      onTap: () {
        Navigator.pop(context);
        MaterialPageRoute route =
            MaterialPageRoute(builder: (value) => SignUp());
        Navigator.push(context, route);
      },
    );
  }

  Future<Null> readShop() async {
    String url =
        '${MyConstant().domain}/smlao/getUserWhereChooseType.php?isAdd=true&ChooseType=Shop';
    await Dio().get(url).then((value) {
      // print('value = $value');
      var result = json.decode(value.data);
      int index = 0;
      for (var map in result) {
        UserModel model = UserModel.fromJson(map);

        String nameShop = model.nameShop;
        if (nameShop.isNotEmpty) {
          print('NameShop = ${model.nameShop}');
          setState(() {
            userModels.add(model);
            shopCards.add(createCard(model, index));
            index++;
          });
        }
      }
    });
  }

  Future<Null> findUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      nameUser = preferences.getString('Name');
    });
  }

  UserAccountsDrawerHeader showHeadDrawer() {
    return UserAccountsDrawerHeader(
      decoration: MyStyle().myBoxDecoration('guest.jpg'),
      currentAccountPicture: MyStyle().showLogo(),
      accountName: Text('Guest'),
      accountEmail: Text('Please Login'),
    );
  }

  Widget createCard(UserModel userModel, int index) {
    return GestureDetector(
      onTap: () {
        print('You Click index $index');
        MaterialPageRoute route = MaterialPageRoute(
          builder: (context) => ShowShopFoodMenu(
            userModel: userModels[index],
          ),
        );
        Navigator.push(context, route);
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 90.0,
              height: 100.0,
              child: Image.network(
                '${MyConstant().domain}${userModel.urlPicture}',
                fit: BoxFit.scaleDown,
              ),
            ),
            MyStyle().mySizebox(),
            Center(
              child: Container(
                width: 120,
                child: MyStyle().showTitleH3(userModel.nameShop),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Future<Null> checkPreferance() async {
  //   try {
  //     FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  //     String token = await firebaseMessaging.getToken();
  //     print('token ====>>> $token');

  //     SharedPreferences preferences = await SharedPreferences.getInstance();
  //     String chooseType = preferences.getString('ChooseType');
  //     String idLogin = preferences.getString('id');
  //     print('idLogin = $idLogin');

  //     if (idLogin != null && idLogin.isNotEmpty) {
  //       String url =
  //           '${MyConstant().domain}/smlao/editTokenWhereId.php?isAdd=true&id=$idLogin&Token=$token';
  //       await Dio()
  //           .get(url)
  //           .then((value) => print('###### Update Token Success #####'));
  //     }

  //     if (chooseType != null && chooseType.isNotEmpty) {
  //       if (chooseType == '??????????????????') {
  //         routeToService(MainUser());
  //       } else if (chooseType == '?????????????????????') {
  //         routeToService(MainShop());
  //       } else if (chooseType == '?????????????????????????????????') {
  //         routeToService(MainRider());
  //       } else {
  //         normalDialog(context, 'Error User Typewwwwwww');
  //       }
  //     }
  //   } catch (e) {}
  // }

  void routeToService(Widget myWidget) {
    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => myWidget,
    );
    Navigator.pushAndRemoveUntil(context, route, (route) => false);
  }
}
