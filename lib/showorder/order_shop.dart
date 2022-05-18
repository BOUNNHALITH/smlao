import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smlao/model/cart_model.dart';
import 'package:smlao/screens/main_shop.dart';
import 'package:smlao/user/detail_shop_order.dart';
import 'package:smlao/utility/sqlite_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smlao/model/order_model.dart';
import 'package:smlao/utility/my_api.dart';
import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/my_style.dart';
import 'package:steps_indicator/steps_indicator.dart';

class OrderShop extends StatefulWidget {
  final OrderModel orderModels;

  const OrderShop({Key key, this.orderModels}) : super(key: key);
  @override
  _OrderShopState createState() => _OrderShopState();
}

class _OrderShopState extends State<OrderShop> {
  final money = NumberFormat('#,##0', 'en_US');
  int showTime = 0;
  String idUser;
  String idShop;
  bool status = true;
  List<CartModel> cartModels = [];
  List<OrderModel> orderModels = [];
  List<List<String>> listNameFoods = [];
  List<List<String>> listPrices = [];
  List<List<String>> listAmounts = [];
  List<List<String>> listSums = [];
  List<int> totals = [];
  List<int> totalInts = [];
  List<int> totalAllInts = [];
  List<int> statusInts = [];
  List<List<String>> listMenuFoods = [];
  int total = 0;

  bool statusOrder = true;
  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    findUser();
    readSQLite();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('ສິນຄ້າທີ່ກຳລັງສັ່ງ'),
      //   actions: <Widget>[
      //     IconButton(
      //       icon: Icon(Icons.close),
      //       onPressed: () => Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) => MainUser(),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
      body: statusOrder ? buildNonOrder() : buildContent(),
    );
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
                buildId(index),

                buildNameShop(index),
                buildDatatimeOrder(index),
                buildDatatimeSend(index),
                // buildTransport(index),
                // Divider(),
                // buildHead(),
                // buildListViewMenuFood(index),
                buildOrderButton(index),
                Divider(),
                buildTotal(index),
                // buildTransport(index),
                // buildTotalAll(index),
                buildStepIndicator(statusInts[index]),
                MyStyle().mySizebox(),
              ],
            ),
          ),
        ),
      );
  Widget buildOrderButton(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 160,
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: () {
              MaterialPageRoute route = MaterialPageRoute(
                builder: (context) => DetailShopOrder(
                  // builder: (context) => Order(
                  orderModel: orderModels[index],
                ),
              );
              Navigator.push(context, route).then((value) => MainShop());
            },
            icon: Icon(
              Icons.source,
              color: Colors.white,
            ),
            label: Text('ເບີ່ງລາຍການ'),
          ),
        ),
      ],
    );
  }

  Widget buildStepIndicator(int index) => Column(
        children: [
          StepsIndicator(
            selectedStepColorIn: Colors.red,
            unselectedStepColorIn: Colors.white,
            lineLength: 80,
            selectedStep: index,
            nbSteps: 4,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('ອໍເດີ'),
              Text('ກະກຽມ'),
              Text('ກຳລັງໄປສົ່ງ'),
              Text('ສຳເລັດ'),
            ],
          ),
        ],
      );
  Widget buildTotal(int index) => Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyStyle().showTitleH3Red('ລວມ: '),
              ],
            ),
          ),
          Expanded(
            flex: 0,
            child: Text(
              money.format(int.parse(totalInts[index].toString())),
              style: MyStyle().mainTitleRedd,
            ),
          ),
          Expanded(
            flex: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                MyStyle().showTitleH3Red(' ກີບ'),
              ],
            ),
          ),
        ],
      );

  // Widget buildTotal(int index) => Row(
  //       children: [
  //         Expanded(
  //           flex: 2,
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.end,
  //             children: [
  //               MyStyle().showTitleH3Red('ລວມ:'),
  //             ],
  //           ),
  //         ),
  //         Expanded(
  //           flex: 1,
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               // MyStyle().showTitleH4('${total.toString()} ກີບ'),
  //               MyStyle().showTitleH3Red('${totalInts[index].toString()} ກີບ'),
  //             ],
  //           ),
  //         ),
  //       ],
  //     );

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

  Container buildHead() {
    return Container(
      padding: EdgeInsets.only(left: 8),
      decoration: BoxDecoration(color: Colors.white54),
      child: Row(
        children: [
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
            flex: 1,
            child: MyStyle().showTitleH3('ລວມ'),
          ),
        ],
      ),
    );
  }

  Row buildDatatimeOrder(int index) {
    return Row(
      children: [
        MyStyle()
            .showTitleH3('ວັນທີ່ Order ${orderModels[index].orderDateTime}'),
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

  Row buildId(int index) {
    return Row(
      children: [
        MyStyle().showTitleH2('ຊື່ລູກຄ້າ: ${orderModels[index].nameUser}'),
      ],
    );
  }

  Row buildNameShop(int index) {
    return Row(
      children: [
        MyStyle().showTitleH3('ບ່ອນສົ່ງ: ${orderModels[index].address}'),
      ],
    );
  }

  Center buildNonOrder() =>
      Center(child: Text('ຮ້ານຄ້າຂອງທ່ານຍັງບໍ່ເຄີຍມີໃຜສັ່ງສິນຄ້າມາກ່ອນ'));

  Future<Null> findUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    idUser = preferences.getString('id');
    // print('idUser = $idUser');
    readOrderFromIdUser();
  }

  Future<Null> readOrderFromIdUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    idShop = preferences.getString(MyConstant().keyId);
    String apiGetOrderWhereIdUser =
        '${MyConstant().domain}/smlao/getOrderWhereIdShop.php?isAdd=true&idShop=$idShop';
    await Dio().get(apiGetOrderWhereIdUser).then((value) {
      // print('value ==>> $value');
      if (value.toString() != 'null') {
        var result = json.decode(value.data);
        // print('result ==>> $result');

        for (var item in result) {
          OrderModel model = OrderModel.fromJson(item);
          List<String> menuFoods = MyAPI().createStringArray(model.nameFood);
          List<String> prices = MyAPI().createStringArray(model.price);
          List<String> amounts = MyAPI().createStringArray(model.amount);
          List<String> sums = MyAPI().createStringArray(model.sum);

          int total = 0;

          for (var item in sums) {
            total = total + int.parse(item);
            ;
          }

          int status = 0;
          switch (model.status) {
            case 'UserOrder':
              status = 0;
              break;
            case 'ReceiveOrder':
              status = 1;
              break;
            case 'RiderOrder':
              status = 2;
              break;
            case 'OrderFinish':
              status = 3;
              break;
            default:
          }

          // print('total = $total');
          if (!((model.status == 'UserOrder') ||
              (model.status == 'CancelOrder')))
            setState(
              () {
                statusOrder = false;
                orderModels.add(model);
                listMenuFoods.add(menuFoods);
                listPrices.add(prices);
                listAmounts.add(amounts);
                listSums.add(sums);

                totalInts.add(total);
                statusInts.add(status);
              },
            );
        }
      }
    });
  }
}
