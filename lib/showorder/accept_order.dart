import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smlao/model/cart_model.dart';
import 'package:smlao/model/order_model.dart';
import 'package:smlao/model/user_model.dart';
import 'package:smlao/screens/main_shop.dart';

import 'package:smlao/utility/my_api.dart';
import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/my_style.dart';
import 'package:smlao/utility/normal_dialog.dart';
import 'package:smlao/utility/sqlite_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AcceptOrder extends StatefulWidget {
  final OrderModel orderModel;
  const AcceptOrder({Key key, this.orderModel}) : super(key: key);
  @override
  _AcceptOrderState createState() => _AcceptOrderState();
}

class _AcceptOrderState extends State<AcceptOrder> {
  final money = NumberFormat('#,##0', 'en_US');
  int showTime = 0;
  String idUser;
  OrderModel orderModel;
  String idShop;
  String id;
  List<CartModel> cartModels = [];
  List<OrderModel> orderModels = [];
  List<List<String>> listNameFoods = [];
  List<List<String>> listPrices = [];
  List<List<String>> listAmounts = [];
  List<List<String>> listDetails = [];
  List<List<String>> listSums = [];
  List<int> totals = [];
  List<int> totalInts = [];
  List<int> statusInts = [];
  List<int> totalAllInts = [];
  List<List<String>> listMenuFoods = [];
  int total = 0;
  bool statusOrder = true;
  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    findUser();
    orderModel = widget.orderModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('ຜູ້ສັ່ງສິນຄ້າແມ່ນ :'),
            Text(orderModel.nameUser),
          ],
        ),
      ),
      // bottomNavigationBar: Padding(
      //   padding: EdgeInsets.all(8.0),
      //   // ignore: deprecated_member_use
      //   child: RaisedButton(
      //     onPressed: () {
      //       // confirmOrder();
      //       // }
      //     },
      //     color: Colors.green,
      //     textColor: Colors.white,
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceAround,
      //       children: <Widget>[
      //         Text(
      //           "ສັ່ງຊື້ສິນຄ້າ",
      //           style: TextStyle(
      //             color: Colors.white,
      //             // fontWeight: FontWeight.bold,
      //             fontSize: 16,
      //           ),
      //           textAlign: TextAlign.center,
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
      body: statusOrder ? MyStyle().showProgress() : buildContent(),
    );
  }

  Widget buildContent() => ListView.builder(
        // padding: EdgeInsets.all(8),
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: orderModels.length,
        itemBuilder: (context, index) => Card(
          color: index % 2 == 0 ? Colors.lime.shade50 : Colors.lime.shade200,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // MyStyle().mySizebox(),
                buildId(index),
                buildNameShop(index),

                buildDatatimeOrder(index),
                buildDatatimeSend(index),
                // buildTransport(index),
                Divider(),
                buildHead(),
                buildListViewMenuFood(index),
                Divider(),
                buildTotal(index),
                // finish(),
                // cancel(),
                // Row(
                //   children: <Widget>[
                //     Expanded(
                //         child: ElevatedButton(
                //       // color: Colors.green,
                //       onPressed: () {},
                //       child: finish(),
                //     )),
                //     SizedBox(
                //       width: 10,
                //     ),
                //     Expanded(
                //         child: ElevatedButton(
                //       onPressed: () {},
                //       child: cancel(),
                //     )),
                //   ],
                // )
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      // flex: 1,
                      child: finish(),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      // flex: 1,
                      child: cancel(),
                    ),
                  ],
                ),
                // MyStyle().mySizebox(),
              ],
            ),
          ),
        ),
      );
  Widget buildTotal(int index) => Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyStyle().showTitleH4('ລາຄາລວມ:  '),
              ],
            ),
          ),
          Expanded(
            flex: 0,
            child:
                //  MyStyle().showTitleH3Red('${total.toString()} ກີບ'),
                Text(
              money.format(int.parse(totalInts[index].toString())),
              style: MyStyle().mainTitleGreen,
            ),
          ),
          Expanded(
            flex: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                MyStyle().showTitleH4(' ກີບ'),
              ],
            ),
          ),
          Expanded(
            flex: 0,
            child: MyStyle().mySizebox(),
          )
        ],
      );
  ListView buildListViewMenuFood(int index) => ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: listMenuFoods[index].length,
        itemBuilder: (context, index2) => Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(listMenuFoods[index][index2]),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Text(listPrices[index][index2]),
                  Text(
                    money.format(
                      int.parse(listPrices[index][index2]),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 0,
              child: Text(listAmounts[index][index2]),
            ),
            Expanded(
              flex: 1,
              child: Text('/ ${listDetails[index][index2]}'),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    money.format(
                      int.parse(listSums[index][index2]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Container buildHead() {
    return Container(
      padding: EdgeInsets.only(left: 8),
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        children: [
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
            flex: 1,
            child: MyStyle().showTitleH3('ລວມ'),
          ),
        ],
      ),
    );
  }

  Row buildId(int index) {
    return Row(
      children: [
        MyStyle().showTitleH2('ເລກທີ່ບິນ ${orderModels[index].id} '),
      ],
    );
  }

  Row buildDatatimeOrder(int index) {
    return Row(
      children: [
        MyStyle()
            .showTitleH3('ວັນທີ່ ອໍເດີ ${orderModels[index].orderDateTime}'),
      ],
    );
  }

  Row buildDatatimeSend(int index) {
    return Row(
      children: [
        MyStyle().showTitleH3(
            'ວັນທີ່ ແລະ ເວລາສົ່ງ ${orderModels[index].dateTimeSent}'),
      ],
    );
  }

  Row buildNameShop(int index) {
    return Row(
      children: [
        MyStyle().showTitleH2('ບ່ອນສົ່ງ ${orderModels[index].address}'),
      ],
    );
  }

  Center buildNonOrder() =>
      Center(child: Text('ທ່ານຍັງບໍ່ເຄີຍສັ່ງສິນຄ້າມາກ່່ອນ'));

  Future<Null> findUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    idUser = preferences.getString('id');
    // print('idUser = $idUser');
    readOrderFromIdUser();
  }

  Future<Null> readOrderFromIdUser() async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    // id = preferences.getString(MyConstant().keyId);
    String id = orderModel.id;
    String apiGetOrderWhereIdUser =
        '${MyConstant().domain}/smlao/getOrderWhereId.php?isAdd=true&id=$id';
    await Dio().get(apiGetOrderWhereIdUser).then((value) {
      // print('value ==>> $value');
      var result = json.decode(value.data);
      // print('result ==>> $result');

      for (var item in result) {
        OrderModel model = OrderModel.fromJson(item);
        List<String> menuFoods = MyAPI().createStringArray(model.nameFood);
        List<String> prices = MyAPI().createStringArray(model.price);
        List<String> amounts = MyAPI().createStringArray(model.amount);
        List<String> details = MyAPI().createStringArray(model.detail);
        List<String> sums = MyAPI().createStringArray(model.sum);

        int total = 0;

        for (var item in sums) {
          total = total + int.parse(item);
        }

        print('total = $total');
        setState(
          () {
            statusOrder = false;
            orderModels.add(model);
            listMenuFoods.add(menuFoods);
            listPrices.add(prices);
            listAmounts.add(amounts);
            listDetails.add(details);
            listSums.add(sums);

            totalInts.add(total);
            // statusInts.add(status);
          },
        );
      }
    });
  }

  Widget finish() => Container(
        // width: MediaQuery.of(context).size.width,
        child: ElevatedButton.icon(
          // color: MyStyle().primaryColor,
          onPressed: () => confirmDialog(),
          icon: Icon(
            Icons.offline_pin_outlined,
            color: Colors.white,
          ),
          label: Text(
            'ກະກຽມ ສຳເລັດ',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
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
  Future<Null> confirmCancel() async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        // title: Text('ຊື່ລູກຄ້າ: ${orderModels[0].id}'),
        title: Text('ທ່ານຕ້ອງການຈະປະຕິເສດສິນຄ້າໃນບິນນີ້ບໍ ?'),

        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () {
                  // Navigator.pop(context);
                  // cancelOrderThread(index);
                  cancelOrder();
                  print('####===>>>  ');
                },
                icon: Icon(
                  Icons.check,
                  color: Colors.white,
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

  Future<Null> cancelOrder() async {
    String id = orderModel.id;
    String apiEditStatus =
        '${MyConstant().domain}/smlao/editOrderWhereIdAnStatus.php?isAdd=true&id=$id&Status=CancelOrder';
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

  Future<Null> confirmDialog() async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('ສິນຄ້າໃນບິນນີ້ກະກຽມ ແລ້ວລະບໍ?'),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () {
                  // Navigator.pop(context);
                  // cancelOrderThread(index);
                  editorderThread();
                  print('####===>>>  ');
                },
                icon: Icon(
                  Icons.check,
                  color: Colors.white,
                ),
                label: Text('ແລ້ວໆ'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.clear,
                  color: Colors.red,
                ),
                label: Text('ຍັງລໍຖ້າ'),
              )
              // ElevatedButton.icon(
              //     Navigator.pop(context);
              //     editorderThread();
              //   },
              //   icon: Icon(
              //     Icons.check,
              //     color: Colors.white,
              //   ),
              //   label: Text('ຍອມຮັບ'),
              // ),
              // ElevatedButton(
              //   onPressed: () => Navigator.pop(context),
              //   child: Text('ຍັງລໍຖ້າ'),
              // ),
            ],
          )
        ],
      ),
    );
  }

  Future<Null> editorderThread() async {
    String id = orderModel.id;
    String apiEditStatus =
        '${MyConstant().domain}/smlao/editOrderWhereIdAnStatus.php?isAdd=true&id=$id&Status=ReceiveOrder';
    Response response = await Dio().get(apiEditStatus);
    if (response.toString() == 'true') {
      clearAllSQLite();
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

  Future<Null> readSQLite() async {
    var object = await SQLiteHelper().readAllDataFromSQLite();
    print('object length ==> ${object.length}');
  }

  Future<Null> notificationToShop(String idUser) async {
    String urlFindToken =
        '${MyConstant().domain}/smlao/getUserWhereId.php?isAdd=true&id=$idUser';
    await Dio().get(urlFindToken).then((value) {
      var result = json.decode(value.data);
      print('result ==> $result');
      for (var json in result) {
        UserModel model = UserModel.fromJson(json);
        String tokenUser = model.token;
        print('tokenUser ==>> $tokenUser');

        String title = 'ສິຄ້າຂອງທ່ານໄດ້ກະກຽມແລ້ວໆ ຂອບໃຈທີໃຊ້ບໍລິການ';
        String body = 'ຖ້າມີຫຍັງບໍ່ຖຶກໃຈ ຕ້ອງຂໍອະໄພແອບຂອງພວກເຮົາກຳລັງພັດທະນາ';
        String urlSendToken =
            '${MyConstant().domain}/smlao/apiNotification.php?isAdd=true&token=$tokenUser&title=$title&body=$body';

        sendNotificationToShop(urlSendToken);
      }
    });
  }

  Future<Null> sendNotificationToShop(String urlSendToken) async {
    await Dio().get(urlSendToken).then(
          (value) => normalDialog(context, 'ສົ່ງ ອໍເດີ ໄປໃຫ້ໄລເດີແລ້ວ'),
        );
  }
}
