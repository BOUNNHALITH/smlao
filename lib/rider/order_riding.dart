import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:smlao/model/cart_model.dart';
import 'package:smlao/model/user_model.dart';
import 'package:smlao/rider/send_rider.dart';
import 'package:smlao/utility/normal_dialog.dart';
import 'package:smlao/utility/sqlite_helper.dart';
import 'package:smlao/model/order_model.dart';
import 'package:smlao/utility/my_api.dart';
import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steps_indicator/steps_indicator.dart';

class OrderRiding extends StatefulWidget {
  final UserModel userModel;
  final OrderModel orderModel;

  const OrderRiding({Key key, this.orderModel, this.userModel})
      : super(key: key);

  @override
  _OrderRidingState createState() => _OrderRidingState();
}

class _OrderRidingState extends State<OrderRiding> {
  UserModel userModel;
  OrderModel orderModel;
  String idUser;
  String idShop;
  File file;
  String id, address, addressAround, phone, payment;
  List<OrderModel> orderModels = [];
  List<List<String>> listNameFoods = [];
  List<List<String>> listMenuFoods = [];
  List<List<String>> listPrices = [];
  List<List<String>> listAmounts = [];
  List<List<String>> listSums = [];
  List<int> totals = [];
  List<CartModel> cartModels = [];
  List<int> statusInts = [];
  int total = 0;
  int totalall = 0;
  bool status = true;
  bool loadStatus = true; // Process Load JSON

  @override
  void initState() {
    super.initState();
    orderModel = widget.orderModel;
    findIdShopAndReadOrder();
    readSQLite();
  }

  Future<Null> findIdShopAndReadOrder() async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    // String id = preferences.getString(orderModel.id);
    // print('idShop = $idShop');

    String path =
        '${MyConstant().domain}/smlao/getOrderWhereStatus.php?isAdd=true&Status=ReceiveOrder';
    await Dio().get(path).then((value) {
      // print('value ==>> $value');
      var result = json.decode(value.data);
      // print('result ==>> $result');
      for (var item in result) {
        OrderModel model = OrderModel.fromJson(item);
        // print('orderDateTime = ${model.orderDateTime}');

        List<String> nameFoods = MyAPI().createStringArray(model.nameFood);
        List<String> prices = MyAPI().createStringArray(model.price);
        List<String> amounts = MyAPI().createStringArray(model.amount);
        List<String> sums = MyAPI().createStringArray(model.sum);

        int total = 0;
        for (var item in sums) {
          total = total + int.parse(item);
        }

        setState(() {
          orderModels.add(model);
          listNameFoods.add(nameFoods);
          listPrices.add(prices);
          listAmounts.add(amounts);
          listSums.add(sums);
          totals.add(total);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: orderModels.length == 0
          ? MyStyle().showwarng()
          : ListView.builder(
              itemCount: orderModels.length,
              itemBuilder: (context, index) => Card(
                color: index % 2 == 0
                    ? Colors.lime.shade100
                    : Colors.lime.shade400,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyStyle().showTitleH2(
                          'ຊື່ຮ້ານ: ${orderModels[index].nameShop}'),
                      MyStyle().showTitleH2(
                          'ບ່ອນສົ່ງ: ${orderModels[index].address}'),
                      MyStyle().showTitleH3(
                          'ຈຸດພິເສດບ່ອນສົ່ງ: ${orderModels[index].address}'),
                      MyStyle().showTitleH3(
                          'ວັນທີ່: ${orderModels[index].orderDateTime}'),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                MyStyle().showTitleH2(
                                    'ຊື່ລູກຄ້າ: ${orderModels[index].nameUser}'),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: MyStyle().showTitleH3Red(
                                'ເບ້ຕິດຕໍ່: ${orderModels[index].phone}'),
                          ),
                        ],
                      ),
                      buildTitle(),
                      // buildStepIndicator(statusInts[index]),
                      // buildListViewMenuFood(index),
                      ListView.builder(
                        itemCount: listNameFoods[index].length,
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemBuilder: (context, index2) => Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(listNameFoods[index][index2]),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(listPrices[index][index2]),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(listAmounts[index][index2]),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(listSums[index][index2]),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                MyStyle().showTitleH2('ລວມ :'),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: MyStyle().showTitleH3Red(
                                '${totals[index].toString()} ກີບ'),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                MyStyle().showTitleH2('ຄ່ສົ່ງ :'),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: MyStyle().showTitleH3Red(
                                '${orderModels[index].transport} ກີບ'),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(
                              // color: Colors.red,
                              // shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(30)),
                              onPressed: () {},
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.white,
                              ),
                              label: Text(
                                'Cancel',
                                style: TextStyle(color: Colors.white),
                              )),
                          ElevatedButton(
                            style: TextButton.styleFrom(
                              primary: Colors.white,
                            ),
                            onPressed: () {
                              sendingOrder();
                              MaterialPageRoute route = MaterialPageRoute(
                                builder: (context) => SendRider(
                                  orderModel: orderModels[index],
                                ),
                              );
                              Navigator.push(context, route)
                                  .then((value) => findIdShopAndReadOrder());
                            },
                            child: Text('ສົງສິນຄ້າ'),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildStepIndicator(int index) => Column(
        children: [
          StepsIndicator(
            lineLength: 80,
            selectedStep: index,
            nbSteps: 4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('ອໍເດີ'),
              Text('ກະກຽມ'),
              Text('ກຳລັງມາສົ່ງ'),
              Text('ສຳເລັດ'),
            ],
          ),
        ],
      );
  ListView buildListViewMenuFood(int index) => ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: listMenuFoods[index].length,
        itemBuilder: (context, index2) => Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(listMenuFoods[index][index2]),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(listPrices[index][index2]),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(listAmounts[index][index2]),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(listSums[index][index2]),
                ],
              ),
            ),
          ],
        ),
      );

  int showStep(String status) {
    switch (status) {
      case 'UserOrder':
        return 0;
        break;
      case 'ReceiveOrder':
        return 1;
        break;
      case 'RiderOrder':
        return 2;
        break;
      default:
        return 0;
    }
  }

  Future<Null> readOrder() async {
    if (orderModels.length != 0) {
      loadStatus = true;
      status = true;
      var orderModels;
      orderModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String id = preferences.getString(orderModel.id);
    print('idShop = $id');

    String url =
        '${MyConstant().domain}/smlao/getOrderWhereId.php?isAdd=true&id=$id';
    await Dio().get(url).then((value) {
      setState(() {
        loadStatus = false;
      });

      if (value.toString() != 'null') {
        // print('value ==>> $value');

        var result = json.decode(value.data);
        // print('result ==>> $result');

        for (var map in result) {
          OrderModel orderModel = OrderModel.fromJson(map);
          setState(() {
            orderModels.add(orderModel);
          });
        }
      } else {
        setState(() {
          status = false;
        });
      }
    });
  }

  Future<Null> sendingOrder() async {
    // print('idShop = $idShop');
    String id = orderModel.id;
    // print('id = $id');
    String apiEditStatus =
        '${MyConstant().domain}/smlao/editOrderWhereIdAnStatus.php?isAdd=true&id=$id&Status=RiderOrder';
    Response response = await Dio().get(apiEditStatus);
    if (response.toString() == 'true') {
      notificationToShop(idUser);
      Navigator.pop(context);
    } else {
      normalDialog(context, 'ຍັງແກ້ໄຂບໍ່ໄດ້ ກະລຸນາແກ້ໄຂໄໝ່');
    }
  }

  Future<Null> chooseOrder() async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('ຊື່ລູກຄ້າ: ${orderModels[0].status}'),

        // title: Text('ທ່ານຕ້ອງການຈະປ່ນແປງຂໍ້ມູນໝວດສິນຄ້ານີ້ແທ້ບໍ ?'),
        // nameGroupFood(),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // MaterialPageRoute route = MaterialPageRoute(
                  //   builder: (context) => SendRider(
                  //     orderModel: orderModels[index],
                  //   ),
                  // );
                  // Navigator.push(context, route)
                  //     .then((value) => findIdShopAndReadOrder());
                  sendingOrder();
                  readOrder();
                },
                icon: Icon(
                  Icons.check,
                  color: Colors.green,
                ),
                label: Text('ຍອມຮັບ'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.clear,
                  color: Colors.red,
                ),
                label: Text('ປະຕິເສດ'),
              )
            ],
          )
        ],
      ),
    );
  }

  Future<Null> clearAllSQLite() async {
    // Toast.show(
    //   'Order เรียบร้อยแล้ว คะ',
    //   context,
    //   duration: Toast.LENGTH_LONG,
    // );
    await SQLiteHelper().deleteAllData().then((value) {
      readSQLite();
    });
  }

  Future<Null> notificationToShop(String idUser) async {
    String urlFindToken =
        '${MyConstant().domain}/smlao/getUserWhereId.php?isAdd=true&id=$idUser';
    await Dio().get(urlFindToken).then((value) {
      var result = json.decode(value.data);
      print('result ==> $result');
      for (var json in result) {
        UserModel model = UserModel.fromJson(json);
        String tokenShop = model.token;
        print('tokenShop ==>> $tokenShop');

        String title = 'ໄລເດີ ມາຮັບສິນຄ້າຂອງທ່ານແລ້ວ ພວກເຮົາກຳລັງໄປສົ່ງ';
        String body = 'ຂໍອະໄພໃນຄວາມລ່າຊ້າ ແອບຂອງພວກເຮົາກຳລັງພັດທະນາ ';
        String urlSendToken =
            '${MyConstant().domain}/smlao/apiNotification.php?isAdd=true&token=$tokenShop&title=$title&body=$body';

        sendNotificationToShop(urlSendToken);
      }
    });
  }

  Future<Null> sendNotificationToShop(String urlSendToken) async {
    await Dio().get(urlSendToken).then(
          (value) => normalDialog(context, 'ສົ່ງ Order ໄປທີ່ຮ້ານຄ້າສຳເລັດແລ້ວ'),
        );
  }

  Future<Null> readSQLite() async {
    var object = await SQLiteHelper().readAllDataFromSQLite();
    print('object length ==> ${object.length}');
    // if (object.length != 0) {
    //   for (var model in object) {
    //     String sumString = model.sum;
    //     int sumInt = int.parse(sumString);
    //     setState(() {
    //       // status = false;
    //       // cartModels = object;
    //       // total = total + sumInt;
    //       // totalall = total + sumInt + totalall;
    //     });
    //   }
    // } else {
    //   setState(() {
    //     status = true;
    //   });
    // }
  }

  Container buildTitle() {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.lime.shade700),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: MyStyle().showTitleH3('ຊື່ສິນຄ້າ'),
          ),
          Expanded(
            flex: 2,
            child: MyStyle().showTitleH3('ລາຄາ'),
          ),
          Expanded(
            flex: 2,
            child: MyStyle().showTitleH3('ຈຳນວນ'),
          ),
          Expanded(
            flex: 0,
            child: MyStyle().showTitleH3('ລວມ'),
          ),
          Expanded(
            flex: 1,
            child: MyStyle().mySizebox(),
          )
        ],
      ),
    );
  }
}
