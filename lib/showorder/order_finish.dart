import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smlao/model/cart_model.dart';
import 'package:smlao/model/order_model.dart';
import 'package:smlao/screens/main_user.dart';
import 'package:smlao/user/detailorder.dart';
import 'package:smlao/utility/my_api.dart';
import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steps_indicator/steps_indicator.dart';

class OrderFinish extends StatefulWidget {
  const OrderFinish({Key key}) : super(key: key);

  @override
  _OrderFinishState createState() => _OrderFinishState();
}

class _OrderFinishState extends State<OrderFinish> {
  final money = NumberFormat('#,##0', 'en_US');
  int showTime = 0;
  String idUser;
  String idShop;
  List<CartModel> cartModels = [];
  List<OrderModel> orderModels = [];
  List<List<String>> listNameFoods = [];
  List<List<String>> listPrices = [];
  List<List<String>> listAmounts = [];
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ສິນຄ້າທີ່ທ່ານເຄີຍສັ່ງ'),
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

  Widget buildTotalAll(int index) => Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                MyStyle().showTitleH2('ລວມມູນຄ່າ:'),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyStyle()
                    .showTitleH3Red('${totalAllInts[index].toString()} ກີບ'),
              ],
            ),
          ),
        ],
      );
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
                MyStyle().showTitleH3Red('ລາຄາລວມ:'),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyStyle().showTitleH3Red('${totalInts[index].toString()} ກີບ'),
              ],
            ),
          ),
        ],
      );
  Widget buildTransport(int index) => Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyStyle().showTitleH3Red('ຄ່າສົ່ງ:'),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyStyle()
                    .showTitleH3Purple(' ${orderModels[index].transport} ກີບ'),
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

  Container buildHead() {
    return Container(
      padding: EdgeInsets.only(left: 8),
      decoration: BoxDecoration(color: Colors.white),
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

  // Row buildTransport(int index) {
  //   return Row(
  //     children: [
  //       MyStyle()
  //           .showTitleH3Purple('ຄ່າສົ່ງ ${orderModels[index].transport} ກີບ'),
  //     ],
  //   );
  // }

  Row buildDistance(int index) {
    return Row(
      children: [
        MyStyle()
            .showTitleH3Red('ໄລຍະທາງ ${orderModels[index].distance} ກິໂລແມັດ'),
      ],
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
        '${MyConstant().domain}/smlao/getOrderWhereStatus.php?isAdd=true&idUser=$idUser&Status=OrderFinish';
    await Dio().get(apiGetOrderWhereIdUser).then((value) {
      // print('value ==>> $value');
      var result = json.decode(value.data);
      // print('result ==>> $result');

      for (var item in result) {
        OrderModel model = OrderModel.fromJson(item);
        // if (!((model.status == 'UserOrder') ||
        //     (model.status == 'CancelOrder') ||
        //     (model.status == 'ReceiveOrder') ||
        //     (model.status == 'RiderOrder'))) {
        //   setState(() {
        //     orderModels.add(model);
        //   });
        // }

        List<String> menuFoods = MyAPI().createStringArray(model.nameFood);
        List<String> prices = MyAPI().createStringArray(model.price);
        List<String> amounts = MyAPI().createStringArray(model.amount);
        List<String> sums = MyAPI().createStringArray(model.sum);
        String khasong = model.transport;
        int total = 0;
        int totalalls = 0;
        for (var item in sums) {
          total = total + int.parse(item);
          totalalls = total + int.parse(khasong);
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

        print('total = $total');
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
    });
  }
}
