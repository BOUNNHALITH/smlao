import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smlao/model/cart_model.dart';
import 'package:smlao/model/order_model.dart';
import 'package:smlao/user/detailorder.dart';
import 'package:smlao/utility/my_api.dart';
import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/my_style.dart';
import 'package:smlao/utility/sqlite_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steps_indicator/steps_indicator.dart';
import '../screens/main_user.dart';

class WaitShopCheckOrder extends StatefulWidget {
  const WaitShopCheckOrder({Key key}) : super(key: key);
  @override
  _WaitShopCheckOrderState createState() => _WaitShopCheckOrderState();
}

class _WaitShopCheckOrderState extends State<WaitShopCheckOrder> {
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
  int totalalls = 0;
  int totalallss = 0;
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
      body: statusOrder ? buildNonOrder() : buildContent(),
    );
  }

  Future<Null> readSQLite() async {
    var object = await SQLiteHelper().readAllDataFromSQLite();
    print('object length ==> ${object.length}');
    if (object.length != 0) {
      for (var model in object) {
        String khasong = model.transport;
        String sumString = model.sum;
        String luam = model.sum;
        int sumInt = int.parse(sumString);
        int transport = int.parse(khasong);
        int totalIntss = int.parse(luam);

        setState(() {
          status = false;
          cartModels = object;
          total = total + sumInt;
          totalalls = totalIntss + transport;
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
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                buildNameShop(index),
                buildDatatimeOrder(index),
                // Divider(),
                // buildOrderButton(index),
                // Divider(),
                // buildTotal(index),
                buildStepIndicator(statusInts[index]),
                // MyStyle().mySizebox(),
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
          // width: 160,
          // padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: () {
              MaterialPageRoute route = MaterialPageRoute(
                builder: (context) => DetailOrder(
                  // builder: (context) => Order(
                  orderModel: orderModels[index],
                ),
              );
              Navigator.push(context, route).then((value) => MainUser());
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

  Future<Null> confirmOrder(int index) async {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MyStyle().showTitleH3black('ຂໍ້ມູນ'),
              //
              buildHead(),
              buildListViewMenuFood(index),
              MyStyle().mySizebox(),
            ],
          ),
        ),
      ),
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
              Text('ກຳລັງມາສົ່ງ'),
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
        MyStyle().showTitleH2('ບໍລິສັດ ເມືອງລາວ'),
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
    SharedPreferences preferences = await SharedPreferences.getInstance();
    idUser = preferences.getString(MyConstant().keyId);
    String apiGetOrderWhereIdUser =
        '${MyConstant().domain}/smlao/getOrderWhereIdUserLast.php?isAdd=true&idUser=$idUser';
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
          if (!((model.status == 'OrderFinish') ||
              (model.status == 'CancelOrder')))
            setState(
              () {
                statusOrder = false;
                orderModels.add(model);
                listMenuFoods.add(menuFoods);
                listPrices.add(prices);
                listAmounts.add(amounts);
                listSums.add(sums);
                totalAllInts.add(totalalls);
                totalInts.add(total);
                statusInts.add(status);
              },
            );
        }
      }
    });
  }
}
