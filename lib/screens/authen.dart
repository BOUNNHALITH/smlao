// import 'dart:convert';

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:smlao/model/user_model.dart';
// import 'package:smlao/utility/my_constant.dart';
// import 'package:smlao/utility/my_constants.dart';
// import 'package:smlao/utility/my_style.dart';
// import 'package:smlao/utility/normal_dialog.dart';
// import 'package:smlao/utility/show_title.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class Authen extends StatefulWidget {
//   const Authen({Key key}) : super(key: key);

//   @override
//   _AuthenState createState() => _AuthenState();
// }

// class _AuthenState extends State<Authen> {
//   bool statusRedEye = true;
//   final formKey = GlobalKey<FormState>();
//   TextEditingController userController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     double size = MediaQuery.of(context).size.width;
//     return Scaffold(
//       body: SafeArea(
//         child: GestureDetector(
//           onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
//           behavior: HitTestBehavior.opaque,
//           child: Form(
//             key: formKey,
//             child: ListView(
//               children: [
//                 MyStyle().showLogo(),
//                 // buildAppName(),
//                 buildUser(size),
//                 buildPassword(size),
//                 buildLogin(size),
//                 buildCreateAccount(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Row buildCreateAccount() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         ShowTitle(
//           title: 'Non Account ? ',
//           textStyle: MyConstants().h3Style(),
//         ),
//         TextButton(
//           onPressed: () =>
//               Navigator.pushNamed(context, MyConstants.routeCreateAccount),
//           child: Text('Create Account'),
//         ),
//       ],
//     );
//   }

//   Row buildLogin(double size) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           margin: EdgeInsets.symmetric(vertical: 16),
//           width: size * 0.6,
//           child: ElevatedButton(
//             style: MyConstants().myButtonStyle(),
//             onPressed: () {
//               if (formKey.currentState.validate()) {
//                 String user = userController.text;
//                 String password = passwordController.text;
//                 print('## user = $user, password = $password');
//                 checkAuthen(user: user, password: password);
//               }
//             },
//             child: Text('Login'),
//           ),
//         ),
//       ],
//     );
//   }

//   Future<Null> checkAuthen({String user, String password}) async {
//     String apiCheckAuthen =
//         '${MyConstant().domain}/smlao/getUserWhereUser.php?isAdd=true&User=$user';
//     await Dio().get(apiCheckAuthen).then((value) async {
//       print('## value for API ==>> $value');
//       if (value.toString() == 'null') {
//         normalDialog(context, 'User False !!!');
//       } else {
//         for (var item in json.decode(value.data)) {
//           UserModel model = UserModel.fromJson(item);
//           if (password == model.password) {
//             // Success Authen
//             String chooseType = model.chooseType;
//             print('## Authen Success in Type ==> $chooseType');

//             SharedPreferences preferences =
//                 await SharedPreferences.getInstance();
//             preferences.setString('chooseType', chooseType);
//             preferences.setString('user', model.user);

//             switch (chooseType) {
//               case 'buyer':
//                 Navigator.pushNamedAndRemoveUntil(
//                     context, MyConstants.routeBuyerService, (route) => false);
//                 break;
//               case 'seller':
//                 Navigator.pushNamedAndRemoveUntil(
//                     context, MyConstants.routeSalerService, (route) => false);
//                 break;
//               case 'rider':
//                 Navigator.pushNamedAndRemoveUntil(
//                     context, MyConstants.routeRiderService, (route) => false);
//                 break;
//               default:
//             }
//           } else {
//             // Authen False
//             normalDialog(context, 'Password False !!!');
//           }
//         }
//       }
//     });
//   }

//   Row buildUser(double size) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           margin: EdgeInsets.only(top: 16),
//           width: size * 0.6,
//           child: TextFormField(
//             controller: userController,
//             validator: (value) {
//               if (value.isEmpty) {
//                 return 'Please Fill User in Blank';
//               } else {
//                 return null;
//               }
//             },
//             decoration: InputDecoration(
//               // labelStyle: MyConstant().h3Style(),
//               labelText: 'User :',
//               prefixIcon: Icon(
//                 Icons.account_circle_outlined,
//                 color: Colors.green,
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.green),
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: MyConstant.light),
//                 borderRadius: BorderRadius.circular(30),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Row buildPassword(double size) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           margin: EdgeInsets.only(top: 16),
//           width: size * 0.6,
//           child: TextFormField(
//             controller: passwordController,
//             validator: (value) {
//               if (value.isEmpty) {
//                 return 'Please Fill Password in Blank';
//               } else {
//                 return null;
//               }
//             },
//             obscureText: statusRedEye,
//             decoration: InputDecoration(
//               suffixIcon: IconButton(
//                 onPressed: () {
//                   setState(() {
//                     statusRedEye = !statusRedEye;
//                   });
//                 },
//                 icon: statusRedEye
//                     ? Icon(
//                         Icons.remove_red_eye,
//                         color: Colors.white,
//                       )
//                     : Icon(
//                         Icons.remove_red_eye_outlined,
//                         color: Colors.white,
//                       ),
//               ),
//               // labelStyle: MyConstant().h3Style(),
//               labelText: 'Password :',
//               prefixIcon: Icon(
//                 Icons.lock_outline,
//                 // color: MyConstant.dark,
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.green),
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: MyConstant.light),
//                 borderRadius: BorderRadius.circular(30),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // Row buildAppName() {
//   //   return Row(
//   //     mainAxisAlignment: MainAxisAlignment.center,
//   //     children: [
//   //       ShowTitle(
//   //         title: MyConstant.appName,
//   //         textStyle: MyConstant().h1Style(),
//   //       ),
//   //     ],
//   //   );
//   // }

//   // Row buildImage(double size) {
//   //   return Row(
//   //     mainAxisAlignment: MainAxisAlignment.center,
//   //     children: [
//   //       Container(
//   //         width: size * 0.6,
//   //         child: ShowImage(path: MyConstant.logo2),
//   //       ),
//   //     ],
//   //   );
//   // }
// }
