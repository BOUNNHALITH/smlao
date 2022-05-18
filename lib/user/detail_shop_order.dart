import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smlao/model/cart_model.dart';
import 'package:smlao/model/order_model.dart';
import 'package:smlao/utility/my_api.dart';
import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/my_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailShopOrder extends StatefulWidget {
  final OrderModel orderModel;
  const DetailShopOrder({Key key, this.orderModel}) : super(key: key);
  @override
  _DetailShopOrderState createState() => _DetailShopOrderState();
}

class _DetailShopOrderState extends State<DetailShopOrder> {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // MyStyle().mySizebox(),
                buildId(index),
                MyStyle()
                    .showTitleH2('ຊື່ລູກຄ້າ: ${orderModels[index].nameUser}'),
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
                MyStyle().mySizebox(),
              ],
            ),
          ),
        ),
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
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Text(listPrices[index][index2]),
                  Text(money.format(int.parse(listPrices[index][index2]))),
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
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(money.format(int.parse(listSums[index][index2]))),
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
            'ວັນທີ່ແລະເວລາສົ່ງ ${orderModels[index].dateTimeSent}'),
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
}
