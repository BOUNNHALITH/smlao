import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:smlao/model/cart_model.dart';
import 'package:smlao/model/user_model.dart';
import 'package:smlao/utility/sqlite_helper.dart';
import 'package:smlao/model/order_model.dart';
import 'package:smlao/utility/my_api.dart';
import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steps_indicator/steps_indicator.dart';

import 'main_user.dart';

class WaitOrder extends StatefulWidget {
  final OrderModel orderModels;

  const WaitOrder({Key key, this.orderModels}) : super(key: key);
  @override
  _WaitOrderState createState() => _WaitOrderState();
}

class _WaitOrderState extends State<WaitOrder> {
  UserModel userModel;
  OrderModel orderModel;
  String idUser;
  String idShop;
  String id, address, addressAround, phone, payment;
  List<OrderModel> orderModels = [];
  List<List<String>> listNameFoods = [];
  List<List<String>> listMenuFoods = [];
  List<List<String>> listPrices = [];
  List<List<String>> listAmounts = [];
  List<List<String>> listSums = [];
  List<int> totals = [];
  List<CartModel> cartModels = [];
  int total = 0;
  int totalall = 0;
  bool status = true;
  @override
  void initState() {
    super.initState();
    findIdShopAndReadOrder();
    readSQLite();
    findIdUser();
  }

  Future<Null> findIdUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    idUser = preferences.getString('id');

    String apiGetOrderWhereIdUser =
        '${MyConstant().domain}/smlao/getOrderWhereIdUserLast.php?isAdd=true&idUser=$idUser';
    await Dio().get(apiGetOrderWhereIdUser).then((value) {
      // if (value.toString() != 'null') {
      for (var item in json.decode(value.data)) {
        OrderModel model = OrderModel.fromJson(item);
        // if (!((model.status == 'UserOrder') ||
        //     // (model.status == 'CancelOrder') ||
        //     (model.status == 'RiderOrder') ||
        //     (model.status == 'ReceiveOrder'))) {
        //   setState(() {
        //     orderModels.add(model);
        //   });
        // }
        List<String> menuFoods = MyAPI().createStringArray(model.nameFood);
        List<String> prices = MyAPI().createStringArray(model.price);
        List<String> amounts = MyAPI().createStringArray(model.amount);
        List<String> sums = MyAPI().createStringArray(model.sum);

        int total = 0;
        for (var item in sums) {
          total = total + int.parse(item);
        }
        setState(
          () {
            status = false;
            orderModels.add(model);
            listMenuFoods.add(menuFoods);
            listPrices.add(prices);
            listAmounts.add(amounts);
            listSums.add(sums);

            // totalInts.add(total);
            // statusInts.add(status);
          },
        );
      }
    });
  }

  Future<Null> findIdShopAndReadOrder() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    idUser = preferences.getString('id');

    String apiGetOrderWhereIdUser =
        '${MyConstant().domain}/smlao/getOrderWhereIdUserLast.php?isAdd=true&idUser=$idUser';
    await Dio().get(apiGetOrderWhereIdUser).then((value) {
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
        if (!((model.status == 'OrderFinish') ||
            (model.status == 'CancelOrder')))
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
      appBar: AppBar(
        title: Text('ສິນຄ້າທີ່ກຳລັງສັ່ງ'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MainUser(),
              ),
            ),
          ),
        ],
      ),
      body: orderModels.length == 0
          ? MyStyle().showProgress()
          : new ListView.builder(
              itemCount: orderModels.length,
              itemBuilder: (context, index) => Card(
                color: index % 2 == 0
                    ? Colors.lime.shade100
                    : Colors.lime.shade400,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      MyStyle().showTitleH2(
                          'ຊື່ຮ້ານ: ${orderModels[index].nameShop}'),
                      MyStyle().showTitleH3(
                          'ວັນທີ່: ${orderModels[index].orderDateTime}'),
                      buildTitle(),
                      ListView.builder(
                        itemCount: listNameFoods[index].length,
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemBuilder: (context, index2) => Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: <Widget>[
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
                              children: <Widget>[
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
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                MyStyle().showTitleH2('ຄ່າສົ່ງ :'),
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
                      StepsIndicator(
                        selectedStepColorIn: Colors.red,
                        unselectedStepColorIn: Colors.white,
                        lineLength: 95,
                        nbSteps: 4,
                        selectedStep: showStep(orderModels[index].status),
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
                  ),
                ),
              ),
            ),
    );
  }

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
      case 'OrderFish':
        return 3;
        break;
      default:
        return 0;
    }
  }

  Future<Null> readSQLite() async {
    var object = await SQLiteHelper().readAllDataFromSQLite();
    print('object length ==> ${object.length}');
    if (object.length != 0) {
      for (var model in object) {
        String sumString = model.sum;
        int sumInt = int.parse(sumString);
        setState(() {
          status = false;
          cartModels = object;
          total = total + sumInt;
        });
      }
    } else {
      setState(() {
        status = true;
      });
    }
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
