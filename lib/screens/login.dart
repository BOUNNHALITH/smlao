import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:smlao/admin/main_admin.dart';
import 'package:smlao/model/user_model.dart';
import 'package:smlao/screens/main_rider.dart';
import 'package:smlao/screens/main_shop.dart';
import 'package:smlao/screens/main_user.dart';
import 'package:smlao/screens/register.dart';
import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/my_constants.dart';
import 'package:smlao/utility/my_style.dart';
import 'package:smlao/utility/normal_dialog.dart';
import 'package:smlao/utility/show_title.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool statusRedEye = true;
  final formKey = GlobalKey<FormState>();
  TextEditingController userController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String user, password;
  bool statusLogin = true; // true => Non Login
  String nameUser;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    checkStatusLogin();
    findUser();
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
  //       if (chooseType == 'ຜູ້ໃຊ້') {
  //         routeToService(MainUser());
  //       } else if (chooseType == 'ຮ້ານຄ້າ') {
  //         routeToService(MainShop());
  //       } else if (chooseType == 'ຜູ້ສົງອາຫານ') {
  //         routeToService(MainRider());
  //       } else if (chooseType == 'ຫົວໜ້າ') {
  //         routeToService(Admin());
  //       } else {
  //         // normalDialog(context, 'Error User Type');
  //       }
  //     }
  //   } catch (e) {}
  // }

  // void routeToService(Widget myWidget) {
  //   MaterialPageRoute route = MaterialPageRoute(
  //     builder: (context) => myWidget,
  //   );
  //   Navigator.pushAndRemoveUntil(context, route, (route) => false);
  // }

  Future<Null> findUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      nameUser = preferences.getString('Name');
    });
  }

  Future<Null> checkStatusLogin() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String type = preferences.getString('ChooseType');
      if (type != null) {
        user = preferences.getString('User');
        password = preferences.getString('Password');
        statusLogin = false;
        checkAuthen();
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      // appBar: AppBar(),
      body: Container(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MyStyle().showLogo(),
                MyStyle().mySizebox(),
                MyStyle().mySizebox(),
                // MyStyle().mySizebox(),
                usernameForm(),
                MyStyle().mySizebox(),
                buildPassword(size),

                MyStyle().mySizebox(),
                loginButton(),
                // buildCreateAccount(),
                // buildButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row buildCreateAccount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ShowTitle(
          title: 'ຍັງບໍ່ມີບັນຊີ ຜູ້ໃຊ້ບໍ ? ',
          textStyle: MyConstants().h3Style(),
        ),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Register(),
            ),
          ),
          child: MyStyle().showTitleH3green('ສະໝັກບັນຊີຜູ້ໃຊ້'),
          // child: Text('ສະໝັກບັນຊີຜູ້ໃຊ້'),
        ),
      ],
    );
  }

  // ElevatedButton buildButton() {
  //   return ElevatedButton(
  //     onPressed: () => Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => Authen(),
  //       ),
  //     ),
  //     child: Text(
  //       'buildButton',
  //       style: TextStyle(color: Colors.white),
  //     ),
  //   );
  // }

  ElevatedButton buildFlatButton() {
    return ElevatedButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Register(),
        ),
      ),
      child: Text(
        'ສະໝັກສະມາຊິກ',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget loginButton() => Container(
        width: 250.0,
        child: ElevatedButton(
          // color: Mystyle().darkColor,
          onPressed: () {
            if (user == null ||
                user.isEmpty ||
                password == null ||
                password.isEmpty) {
              normalDialog(context, 'ກະລຸນາໃສ່ຂໍ້ມູນໃຫ້ຄົບ');
            } else {
              checkAuthen();
            }
          },
          child: Text(
            'ເຂົ້າສູ່ລະບົບ',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

  Future<Null> checkAuthen() async {
    String url =
        '${MyConstant().domain}/smlao/getUserWhereUser.php?isAdd=true&User=$user';
    print('url ===>> $url');
    try {
      Response response = await Dio().get(url);
      print('res = $response');

      var result = json.decode(response.data);
      print('result =$result');
      for (var map in result) {
        UserModel userModel = UserModel.fromJson(map);
        if (password == userModel.password) {
          String chooseType = userModel.chooseType;
          checkTypeAndRoute(chooseType, userModel);
        } else {
          normalDialog(context, 'ຜູ້ໃຊ້ແລະລະຫັດຜ່ານບໍ່ຖຶກຕ້ອງກະລຸນາລອງໄໝ່');
        }
      }
    } catch (e) {}
  }

  void checkTypeAndRoute(String chooseType, UserModel userModel) {
    if (chooseType == 'Shop') {
      routeTuService(MainShop(), userModel);
    } else if (chooseType == 'User') {
      routeTuService(MainUser(), userModel);
    } else if (chooseType == 'Rider') {
      routeTuService(MainRider(), userModel);
    } else if (chooseType == 'Admin') {
      routeTuService(Admin(), userModel);
    } else {
      normalDialog(context, 'Error');
    }
  }

  Future<Null> routeTuService(Widget myWidget, UserModel userModel) async {
    if (statusLogin) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('id', userModel.id);
      preferences.setString('ChooseType', userModel.chooseType);
      preferences.setString('Name', userModel.name);
      preferences.setString('User', userModel.user);
      preferences.setString('Password', userModel.password);
    }

    MaterialPageRoute route = MaterialPageRoute(
      builder: (context) => myWidget,
    );
    Navigator.pushAndRemoveUntil(context, route, (route) => false);
  }

  //กรอบเข้าสู่ระบบ
  Widget usernameForm() => Container(
        width: 250.0,
        child: TextField(
          onChanged: (value) => user = value.trim(),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.account_box,
              color: MyStyle().darkColor,
            ),
            labelStyle: TextStyle(color: MyStyle().darkColor),
            labelText: 'ຜູ້ໃຊ້ :',
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: MyStyle().darkColor)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: MyStyle().primaryColor)),
          ),
        ),
      );

  Row buildPassword(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(top: 16),
          width: 250.0,
          child: TextFormField(
            onChanged: (value) => password = value.trim(),
            controller: passwordController,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please Fill Password in Blank';
              } else {
                return null;
              }
            },
            obscureText: statusRedEye,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    statusRedEye = !statusRedEye;
                  });
                },
                icon: statusRedEye
                    ? Icon(
                        Icons.remove_red_eye,
                        color: Colors.green,
                      )
                    : Icon(
                        Icons.remove_red_eye_outlined,
                        color: Colors.green,
                      ),
              ),
              labelStyle: TextStyle(color: MyStyle().darkColor),
              labelText: 'ລະຫັດຜ່ານ :',
              prefixIcon: Icon(
                Icons.lock,
                color: Colors.green,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
                // borderRadius: BorderRadius.circular(30),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
                // borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget passwordForm() => Container(
        width: 250.0,
        child: TextField(
          onChanged: (value) => password = value.trim(),
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.lock,
              color: MyStyle().darkColor,
            ),
            labelStyle: TextStyle(color: MyStyle().darkColor),
            labelText: 'ລະຫັດຜ່ານ :',
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: MyStyle().darkColor)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: MyStyle().primaryColor)),
          ),
        ),
      );
}
