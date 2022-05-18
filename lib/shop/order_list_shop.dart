import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smlao/model/cart_model.dart';
import 'package:smlao/model/user_model.dart';
import 'package:smlao/screens/main_shop.dart';
import 'package:smlao/showorder/accept_order.dart';
import 'package:smlao/utility/normal_dialog.dart';
import 'package:smlao/utility/sqlite_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smlao/model/order_model.dart';
import 'package:smlao/utility/my_api.dart';
import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/my_style.dart';

class OrderListShop extends StatefulWidget {
  final OrderModel orderModel;

  const OrderListShop({Key key, this.orderModel}) : super(key: key);
  @override
  _OrderListShopState createState() => _OrderListShopState();
}

class _OrderListShopState extends State<OrderListShop> {
  final money = NumberFormat('#,##0', 'en_US');
  UserModel userModel;
  OrderModel orderModel;
  String idUser;
  String idShop, idOder;
  String id, address, addressAround, phone, payment;
  List<OrderModel> orderModels = [];
  List<List<String>> listNameFoods = [];
  List<List<String>> listPrices = [];
  List<List<String>> listAmounts = [];
  List<List<String>> listDetails = [];
  List<List<String>> listSums = [];
  List<int> totals = [];
  List<CartModel> cartModels = [];
  int total = 0;
  int totalall = 0;
  bool status = true;
  bool statusOrder = true;
  @override
  void initState() {
    super.initState();
    // findIdShopAndReadOrder();
    findUser();
    orderModel = widget.orderModel;
  }

  Future<Null> findIdShopAndReadOrder() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    idShop = preferences.getString(MyConstant().keyId);
    print('idShop = $idShop');

    String path =
        '${MyConstant().domain}/smlao/getOrderWhereIdShopAndStatus.php?isAdd=true&idShop=$idShop&Status=UserOrder';
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
        List<String> details = MyAPI().createStringArray(model.detail);
        List<String> sums = MyAPI().createStringArray(model.sum);

        int total = 0;
        for (var item in sums) {
          total = total + int.parse(item);
        }

        setState(() {
          statusOrder = false;
          orderModels.add(model);
          listNameFoods.add(nameFoods);
          listPrices.add(prices);
          listAmounts.add(amounts);
          listDetails.add(details);
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
          ? MyStyle().showProgress()
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
                      MyStyle()
                          .showTitleH2('ເລກທີ່ບິນ: ${orderModels[index].id}'),
                      MyStyle().showTitleH2(
                          'ຊື່ລູກຄ້າ: ${orderModels[index].nameUser}'),
                      // MyStyle().showTitleH3(
                      //     'ບ່ອນສົ່ງ: ${orderModels[index].address}'),
                      MyStyle().showTitleH3(
                          'ວັນທີ່ ອໍເດີ: ${orderModels[index].orderDateTime}'),
                      MyStyle().showTitleH3(
                          'ວັນທີ່ ແລະ ເວລາສົ່ງ ${orderModels[index].dateTimeSent}'),
                      MyStyle().showTitleH5(
                          'ເບ້ຕິດຕໍ່: ${orderModels[index].phone}'),
                      Divider(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              MaterialPageRoute route = MaterialPageRoute(
                                builder: (context) => AcceptOrder(
                                  // builder: (context) => Order(
                                  orderModel: orderModels[index],
                                ),
                              );
                              Navigator.push(context, route)
                                  .then((value) => MainShop());
                            },
                            icon: Icon(
                              Icons.source,
                              color: Colors.white,
                            ),
                            label: Text('ເບີ່ງລາຍການ'),
                          ),
                          // cancel(),
                          // ElevatedButton.icon(
                          //     onPressed: () => confirmCancel(index),
                          //     // cancelOrder(idOder),
                          //     icon: Icon(
                          //       Icons.cancel,
                          //       color: Colors.red,
                          //     ),
                          //     label: Text(
                          //       'ປະຕິເສດ',
                          //       style: TextStyle(color: Colors.white),
                          //     )),
                          // ElevatedButton.icon(
                          //   onPressed: () {
                          //     MaterialPageRoute route = MaterialPageRoute(
                          //       builder: (context) => AcceptOrder(
                          //         // builder: (context) => Order(
                          //         orderModel: orderModels[index],
                          //       ),
                          //     );
                          //     Navigator.push(context, route)
                          //         .then((value) => MainShop());
                          //   },
                          //   // onPressed: () =>
                          //   // confirmOrder(index),
                          //   // icon: Icon(
                          //   //   Icons.check_circle,
                          //   //   color: Colors.white,
                          //   // ),
                          //   // label: Text(
                          //   //   'ກຽມສິນຄ້າ',
                          //   //   style: TextStyle(color: Colors.white),
                          //   // ),
                          // ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<Null> confirmOrder(int index) async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        // title: Text('ຊື່ລູກຄ້າ: ${orderModels[0].nameUser}'),
        title: Text('ທ່ານຕ້ອງການຈະຈະຮັບອໍເດີນີ້ແທ້ບໍ ?'),

        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () {
                  MaterialPageRoute route = MaterialPageRoute(
                    builder: (context) => AcceptOrder(
                      // builder: (context) => Order(
                      orderModel: orderModels[index],
                    ),
                  );
                  Navigator.push(context, route).then((value) => MainShop());
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

  Container buildTitle() {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.lime.shade700),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
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

  Future<Null> confirmCancel() async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('ຊື່ລູກຄ້າ: ${orderModels[0].id}'),
        // title: Text('ທ່ານຕ້ອງການຈະປະຕິເສດສິນຄ້າໃນບິນນີ້ບໍ ?'),

        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () {
                  // Navigator.pop(context);
                  // cancelOrderThread(index);
                  cancelOrder(idOder);
                  print('####===>>>  ');
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

  Widget cancel() => Container(
        // width: MediaQuery.of(context).size.width,
        child: ElevatedButton.icon(
          // color: MyStyle().primaryColor,
          onPressed: () => confirmCancel(),
          icon: Icon(
            Icons.clear,
            color: Colors.red,
          ),
          label: Text(
            'ປະຕິເສດ',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
  Future<Null> cancelOrder(String idOder) async {
    String idOder = orderModel.id;
    String apiEditStatus =
        '${MyConstant().domain}/smlao/editOrderWhereIdAnStatus.php?isAdd=true&id=$idOder&Status=CancelOrder';
    Response response = await Dio().get(apiEditStatus);
    if (response.toString() == 'true') {
      // clearAllSQLite();
      // notificationToShop(idUser);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainShop(),
          ));
    } else {
      normalDialog(context, 'ບໍ່ສາມາດ ສົ່ງ ໄດ້ ກະລຸນາລອງໄໝ່');
    }
  }

  Future<Null> cancelOrderThread(int index) async {
    String nameShop = userModel.nameShop;
    String idFood = orderModels[index].id;
    String nameFood = orderModels[index].nameFood;
    String price = orderModels[index].price;
    String id = orderModel.id;

    String apiEditStatus =
        '${MyConstant().domain}/smlao/editOrderWhereIdAnStatus.php?isAdd=true&id=$id&Status=CancelOrder';
    Response response = await Dio().get(apiEditStatus);
    if (response.toString() == 'true') {
      print(
          '####===>>>  idShop = $idShop, nameShop = $nameShop, idFood = $idFood, nameFood = $nameFood, price = $price,');
      clearAllSQLites();
      notificationToShops(idShop);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainShop(),
          ));
    } else {
      normalDialog(context, 'ບໍ່ສາມາດ ປະຕິເສດ ໄດ້ ກະລຸນາລອງໄໝ່');
    }
  }

  Future<Null> clearAllSQLites() async {
    // Toast.show(
    //   'Order เรียบร้อยแล้ว คะ',
    //   context,
    //   duration: Toast.LENGTH_LONG,
    // );
    await SQLiteHelper().deleteAllData().then((value) {
      readSQLites();
    });
  }

  Future<Null> readSQLites() async {
    var object = await SQLiteHelper().readAllDataFromSQLite();
    print('object length ==> ${object.length}');
  }

  Future<Null> notificationToShops(String idShop) async {
    String urlFindToken =
        '${MyConstant().domain}/smlao/getUserWhereId.php?isAdd=true&id=$idShop';
    await Dio().get(urlFindToken).then((value) {
      var result = json.decode(value.data);
      print('result ==> $result');
      for (var json in result) {
        UserModel model = UserModel.fromJson(json);
        String tokenShop = model.token;
        print('tokenShop ==>> $tokenShop');

        String title = 'ມີ ອໍເດີ ຈາກລູກຄ້າ';
        String body = 'ມີການສັ່ງສິນຄ້າ ຈາກລູກຄ້າ ';
        String urlSendToken =
            '${MyConstant().domain}/smlao/apiNotification.php?isAdd=true&token=$tokenShop&title=$title&body=$body';

        sendNotificationToShopCancel(urlSendToken);
      }
    });
  }

  Future<Null> findUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    idUser = preferences.getString('id');
    // print('idUser = $idUser');
    findIdShopAndReadOrder();
  }

  Future<Null> sendNotificationToShopCancel(String urlSendToken) async {
    await Dio().get(urlSendToken).then(
          (value) => normalDialog(context, 'ສົ່ງ Order ໄປທີ່ຮ້ານຄ້າສຳເລັດແລ້ວ'),
        );
  }
}
