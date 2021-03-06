// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:smlao/model/food_model.dart';
// import 'package:smlao/model/groupfood_model.dart';
// import 'package:smlao/model/user_model.dart';
// import 'package:smlao/shop/food_shop.dart';
// import 'package:smlao/utility/my_constant.dart';
// import 'package:smlao/utility/my_style.dart';
// import 'package:smlao/utility/normal_dialog.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class EditFoods extends StatefulWidget {
//   final UserModel userModel;
//   final FoodModel foodModel;
//   final GroupFoodModel groupFoodModel;
//   EditFoods({Key key, this.groupFoodModel, this.userModel, this.foodModel})
//       : super(key: key);
//   @override
//   _EditFoodsState createState() => _EditFoodsState();
// }

// class _EditFoodsState extends State<EditFoods> {
//   UserModel userModel;
//   FoodModel foodModel;
//   GroupFoodModel groupFoodModel;
//   String idShop, idGrp, status, pathImage;
//   List<GroupFoodModel> groupFoodModels = [];
//   List<FoodModel> foodModels = [];
//   File file;
//   String nameFood, price, detail, nameGroup;

//   List<UserModel> userModels = [];
//   int total = 0;
//   int amount = 1;
//   @override
//   void initState() {
//     // ignore: todo
//     // TODO: implement initState
//     super.initState();
//     groupFoodModel = widget.groupFoodModel;
//     userModel = widget.userModel;

//     foodModel = widget.foodModel;
//     nameFood = foodModel.nameFood;
//     price = foodModel.price;
//     detail = foodModel.detail;
//     idGrp = foodModel.idGrp;
//     status = foodModel.status;
//     pathImage = foodModel.pathImage;
//     readFoodMenu();
//   }

//   Future<Null> readFoodMenu() async {
//     idGrp = groupFoodModel.id;
//     idShop = groupFoodModel.idShop;
//     String url =
//         '${MyConstant().domain}/smlao/getGroupFoodWhereIdGrp.php?isAdd=true&idGrp=$idGrp&idShop=2';

//     Response response = await Dio().get(url);
//     if (response.toString() != 'null') {
//       var result = json.decode(response.data);
//       for (var map in result) {
//         FoodModel foodModel = FoodModel.fromJson(map);
//         setState(() {
//           foodModels.add(foodModel);
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         // actions: <Widget>[MyStyle().iconShowCart(context, amount)],
//         title: Row(
//           children: [
//             Text(groupFoodModel.nameGroup),
//           ],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: <Widget>[
//             nameGrop(),
//             nameFoods(),
//             groupImage(),
//             priceFood(),
//             detailFood(),
//             MyStyle().showTitleH2('??????????????????????????????????????????????????? :'),
//             MyStyle().mySizebox(),
//             onRadio(),
//             offRadio(),
//             groupFood()
//           ],
//         ),
//       ),
//     );
//   }

//   FloatingActionButton uploadButton() {
//     return FloatingActionButton(
//       onPressed: () {
//         // file == null ? Text('No image selected') : Image.file(file);
//         if (file == null) {
//           confirmEdits();
//         }
//         // ? AssetImage('${MyConstant().domain}${foodModel.pathImage}')
//         // : FileImage(File(file.path))) {
//         // return null;
//         else if (nameFood.isEmpty ||
//             price.isEmpty ||
//             detail.isEmpty ||
//             idGrp.isEmpty) {
//           normalDialog(context, '????????????????????????????????????????????????????????????');
//         } else {
//           confirmEdit();
//         }
//       },
//       child: Icon(Icons.cloud_upload),
//     );
//   }

//   Future<Null> confirmEdit() async {
//     showDialog(
//       context: context,
//       builder: (context) => SimpleDialog(
//         title: Text('???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????? ?'),
//         children: <Widget>[
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: <Widget>[
//               ElevatedButton.icon(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   editValueOnMySQL();
//                 },
//                 icon: Icon(
//                   Icons.check,
//                   color: Colors.green,
//                 ),
//                 label: Text('??????????????????'),
//               ),
//               ElevatedButton.icon(
//                 onPressed: () => Navigator.pop(context),
//                 icon: Icon(
//                   Icons.clear,
//                   color: Colors.red,
//                 ),
//                 label: Text('?????????????????????'),
//               )
//             ],
//           )
//         ],
//       ),
//     );
//   }

//   Future<Null> confirmEdits() async {
//     showDialog(
//       context: context,
//       builder: (context) => SimpleDialog(
//         title: Text('???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????? ?'),
//         children: <Widget>[
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: <Widget>[
//               ElevatedButton.icon(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   editValueOnMySQLs();
//                 },
//                 icon: Icon(
//                   Icons.check,
//                   color: Colors.green,
//                 ),
//                 label: Text('??????????????????'),
//               ),
//               ElevatedButton.icon(
//                 onPressed: () => Navigator.pop(context),
//                 icon: Icon(
//                   Icons.clear,
//                   color: Colors.red,
//                 ),
//                 label: Text('?????????????????????'),
//               )
//             ],
//           )
//         ],
//       ),
//     );
//   }

//   Future<Null> editValueOnMySQLs() async {
//     String id = foodModel.id;
//     String url =
//         '${MyConstant().domain}/smlao/editNameFoodWhereId.php?isAdd=true&id=$id&NameFood=$nameFood&Price=$price&Detail=$detail&idGrp=$idGrp&Status=$status';
//     Response response = await Dio().get(url);
//     if (response.toString() == 'true') {
//       // Navigator.push(
//       //     context,
//       //     MaterialPageRoute(
//       //       builder: (context) => FoodShop(
//       //           // foodModel: foodModel,
//       //           // userModel: userModel,
//       //           ),
//       //     ));
//       Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => FoodShop(
//               groupFoodModel: groupFoodModel,
//               userModel: userModel,
//             ),
//           ));
//     } else {
//       normalDialog(context, '?????????????????????????????????????????? ??????????????????????????????????????????');
//     }
//     ;
//   }

//   Future<Null> editValueOnMySQL() async {
//     Random random = Random();
//     int i = random.nextInt(100000);
//     String nameFile = 'editFood$i.jpg';
//     Map<String, dynamic> map = Map();
//     map['file'] = await MultipartFile.fromFile(file.path, filename: nameFile);
//     FormData formData = FormData.fromMap(map);
//     String urlUpload = '${MyConstant().domain}/smlao/saveFood.php';
//     await Dio().post(urlUpload, data: formData).then((value) async {
//       pathImage = '/smlao/Food/$nameFile';
//       String id = foodModel.id;
//       String url =
//           '${MyConstant().domain}/smlao/editFoodWhereId.php?isAdd=true&id=$id&NameFood=$nameFood&PathImage=$pathImage&Price=$price&Detail=$detail&idGrp=$idGrp&Status=$status';
//       Response response = await Dio().get(url);
//       if (response.toString() == 'true') {
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => FoodShop(
//                 groupFoodModel: groupFoodModel,
//                 userModel: userModel,
//               ),
//             ));
//       } else {
//         normalDialog(context, '?????????????????????????????????????????? ??????????????????????????????????????????');
//       }
//     });
//   }

//   Widget groupImage() => Row(
//         children: <Widget>[
//           IconButton(
//             icon: Icon(Icons.add_a_photo),
//             onPressed: () => chooseImage(ImageSource.camera),
//           ),
//           Container(
//             padding: EdgeInsets.all(16.0),
//             width: 250.0,
//             height: 250,
//             child: file == null
//                 ? Image.network(
//                     '${MyConstant().domain}${foodModel.pathImage}',
//                     fit: BoxFit.cover,
//                   )
//                 : Image.file(file),
//           ),
//           IconButton(
//             icon: Icon(Icons.add_photo_alternate),
//             onPressed: () => chooseImage(ImageSource.gallery),
//           ),
//         ],
//       );

//   Future<Null> chooseImage(ImageSource source) async {
//     try {
//       var object = await ImagePicker().getImage(
//         source: source,
//         maxWidth: 600.0,
//         maxHeight: 600.0,
//       );
//       setState(() {
//         file = File(object.path);
//       });
//     } catch (e) {}
//   }

//   Widget nameGrop() => Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Container(
//             margin: EdgeInsets.only(top: 16.0),
//             width: 250.0,
//             child: TextFormField(
//               onChanged: (value) => nameGroup = value.trim(),
//               initialValue: nameGroup,
//               decoration: InputDecoration(
//                 labelText: 'nameGrop',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ),
//         ],
//       );
//   Widget nameFoods() => Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Container(
//             margin: EdgeInsets.only(top: 16.0),
//             width: 250.0,
//             child: TextFormField(
//               onChanged: (value) => nameFood = value.trim(),
//               initialValue: nameFood,
//               decoration: InputDecoration(
//                 labelText: '???????????????????????????',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ),
//         ],
//       );

//   Widget priceFood() => Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Container(
//             margin: EdgeInsets.only(top: 16.0),
//             width: 250.0,
//             child: TextFormField(
//               onChanged: (value) => price = value.trim(),
//               keyboardType: TextInputType.number,
//               initialValue: price,
//               decoration: InputDecoration(
//                 labelText: '???????????? ??????????????????',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ),
//         ],
//       );

//   Widget detailFood() => Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Container(
//             margin: EdgeInsets.only(top: 16.0),
//             width: 250.0,
//             child: TextFormField(
//               onChanged: (value) => detail = value.trim(),
//               keyboardType: TextInputType.multiline,
//               initialValue: detail,
//               decoration: InputDecoration(
//                 labelText: '?????????????????????',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ),
//         ],
//       );
//   Widget groupFood() => Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           Container(
//             margin: EdgeInsets.only(top: 16.0),
//             width: 250.0,
//             child: TextFormField(
//               onChanged: (value) => idGrp = value.trim(),
//               keyboardType: TextInputType.multiline,
//               initialValue: idGrp,
//               decoration: InputDecoration(
//                 labelText: '???????????????????????????',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//           ),
//         ],
//       );

//   Widget onRadio() => Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: <Widget>[
//           Container(
//             width: 250.0,
//             child: Row(
//               children: <Widget>[
//                 Radio(
//                   value: 'on',
//                   groupValue: status,
//                   onChanged: (value) {
//                     setState(() {
//                       status = value;
//                     });
//                   },
//                 ),
//                 Text(
//                   ' ????????????????????????',
//                   style: TextStyle(color: MyStyle().darkColor),
//                 )
//               ],
//             ),
//           ),
//         ],
//       );
//   Widget offRadio() => Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: <Widget>[
//           Container(
//             width: 250.0,
//             child: Row(
//               children: <Widget>[
//                 Radio(
//                   value: 'off',
//                   groupValue: status,
//                   onChanged: (value) {
//                     setState(() {
//                       status = value;
//                     });
//                   },
//                 ),
//                 Text(
//                   '????????????????????????????????????????????????',
//                   style: TextStyle(color: MyStyle().darkColor),
//                 )
//               ],
//             ),
//           ),
//         ],
//       );
// }
