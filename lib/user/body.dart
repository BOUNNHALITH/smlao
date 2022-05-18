import 'dart:convert';

import 'package:carousel_pro/carousel_pro.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:smlao/model/photo_model.dart';
import 'package:smlao/model/user_model.dart';
import 'package:smlao/user/foodmenu13.dart';
// import 'package:smlao/user/groupmenu002.dart';
import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/my_style.dart';
import 'package:smlao/utility/sqlite_helper.dart';

class Bodyss extends StatefulWidget {
  @override
  _BodyssState createState() => _BodyssState();
}

class _BodyssState extends State<Bodyss> {
  UserModel userModel;
  double lat1, lng1, lat2, lng2, distance;
  Location location = Location();
  String distanceString;
  int transport;
  List<UserModel> userModels = [];
  List<Widget> shopCards = [];
  List<PhotoModel> photoModels = [];
  String id, nameimage, image;
  Widget currentWidget;
  int amount = 1;
  @override
  void initState() {
    super.initState();

    readShop();
    readPhoto();
  }

  final List<String> images = [
    '${MyConstant().domain}/smlao/Photo/1111.png',
    '${MyConstant().domain}/smlao/Photo/2222.jpg',
    '${MyConstant().domain}/smlao/Photo/3333.png',
    '${MyConstant().domain}/smlao/Photo/4444.png',
    '${MyConstant().domain}/smlao/Photo/5555.png',
  ];
  Future<Null> readShop() async {
    //  idShop == userModel.id;
    String url =
        '${MyConstant().domain}/smlao/1getUserWhereChooseType.php?isAdd=true&ChooseType=Shop';
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

  Future<Null> readPhoto() async {
    //  id == photoModel.id;
    String url =
        '${MyConstant().domain}/smlao/1getGroupFoodWhereIdShop.php?isAdd=true&id=$id';
    await Dio().get(url).then((value) {
      // print('value = $value');
      var result = json.decode(value.data);
      // int index = 0;
      for (var map in result) {
        PhotoModel model = PhotoModel.fromJson(map);

        // String nameimage = model.nameimage;
        if (nameimage.isNotEmpty) {
          // print('NameShop = ${model.nameShop}');
          setState(() {
            photoModels.add(model);
            // shopCards.add(createCard(model, index));
            // index++;
          });
        }
      }
    });
  }

  Future<Null> checkAmunt() async {
    await SQLiteHelper().readAllDataFromSQLite().then((value) {
      int i = value.length;
      setState(() {
        amount = i;
      });
    });
  }

  Widget createCard(UserModel userModel, int index) {
    return GestureDetector(
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 90.0,
              height: 70.0,
              child: Image.network(
                  '${MyConstant().domain}${userModel.urlPicture}'),
            ),
            MyStyle().mySizebox(),
            Container(
              width: 130,
              child: MyStyle().showTitleH3(userModel.nameShop),
            ),
          ],
        ),
      ),
      onTap: () {
        checkAmunt();
        print('#master Test ### You Click index $index');

        print('### nameShop = ${userModels[index].nameShop}');
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => FoodMenu(
        //       userModel: userModels[index],
        //     ),
        //   ),
        // );
        Navigator.of(context)
            .push(new MaterialPageRoute(builder: (context) => FoodMenu()))
            .whenComplete(readShop);
        // Navigator.pop(context);
        // Navigator.push(context, route).then(onGoBack);

        // Navigator.push(context, route).then(
        //   (value) => checkAmunt(),
        // );
      },
    );
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
            title: Text(' ເລຶອກຮ້ານຄ້າທີໃກ້ບ້ານທ່ານ'),
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
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Wrap(
  //       children: <Widget>[
  //         // MyStyle().showImages(),
  //         photohead(),
  //         // Divider(),
  //         ListTile(
  //           leading: Icon(Icons.fastfood),
  //           title: Text(' ເລຶອກຮ້ານຄ້າທີໃກ້ບ້ານທ່ານ'),
  //         ),
  //         shopCards.length == 0
  //             ? MyStyle().showProgress()
  //             : Wrap(
  //                 children: [
  //                   Container(
  //                     height: 450,
  //                     child: GridView.extent(
  //                       maxCrossAxisExtent: 220.0,
  //                       mainAxisSpacing: 10.0,
  //                       crossAxisSpacing: 10.0,
  //                       children: shopCards,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //       ],
  //     ),
  //     // bottomNavigationBar: Padding(
  //     //   padding: EdgeInsets.all(8.0),
  //     //   // ignore: deprecated_member_use
  //     //   child: RaisedButton(
  //     //     onPressed: () {},
  //     //     color: Colors.green,
  //     //     textColor: Colors.white,
  //     //     // MyStyle().showImages(),

  //     //     child: Text('ຂໍອະໄພແອບຂອງພວກເຮົາກຳລັງພັດທະນາ'),
  //     //   ),
  //     // ),
  //   );
  // }

  Container photohead() {
    return Container(
      alignment: Alignment.center,
      // margin: EdgeInsets.all(20),
      // height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5), //border corner radius
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), //color of shadow
            // spreadRadius: 5, //spread radius
            // blurRadius: 7, // blur radius
            // offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      // child: Image.network('${MyConstant().domain}${photoModels[].image}'),
      child: Image.asset('images/4444.jpg'),
      // child: Text(
      //   "Box Shadow on Container",
      //   style: TextStyle(
      //     fontSize: 20,
      //   ),
      // ),
    );
  }

  Widget showListGroupFood() => ListView.builder(
        itemCount: photoModels.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () {
            print('#### You Click index $index');
          },
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10.0),
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.width * 0.3,
                      child: Image.network(
                        '${MyConstant().domain}${photoModels[index].image}',
                        // fit: BoxFit.cover,
                      ),
                    ),
                  ],
                  // ),
                ),
              ],
            ),
          ),
        ),
      );
}
