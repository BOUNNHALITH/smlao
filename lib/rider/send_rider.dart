import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'package:location/location.dart';
import 'package:smlao/model/order_model.dart';
import 'package:smlao/model/user_model.dart';
import 'package:smlao/screens/main_rider.dart';
import 'package:smlao/utility/my_api.dart';
import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/my_style.dart';
import 'package:smlao/utility/normal_dialog.dart';
import 'package:smlao/utility/sqlite_helper.dart';

class SendRider extends StatefulWidget {
  final OrderModel orderModel;

  const SendRider({Key key, this.orderModel}) : super(key: key);
  @override
  _SendRiderState createState() => _SendRiderState();
}

class _SendRiderState extends State<SendRider> {
  // Location location = Location();
  // double lat, lng;
  File file;
  UserModel userModel;
  OrderModel orderModel;
  String idUser;
  String idShop, id, status;
  String address, addressAround, phone, payment;
  List<OrderModel> orderModels = [];
  List<List<String>> listNameFoods = [];
  List<List<String>> listPrices = [];
  List<List<String>> listAmounts = [];
  List<List<String>> listSums = [];
  List<int> totals = [];
  double lat, lng;
  int total = 0;
  int totalall = 0;
  double lat1, lng1, lat2, lng2, distance;
  // bool status = true;
  bool loadStatus = true;
  String distanceString;
  int transport;
  CameraPosition position;
  // Process Load JSON
  @override
  void initState() {
    super.initState();
    readOrder();
    orderModel = widget.orderModel;
    findLat1Lng1();
  }

  Future<Null> findLat1Lng1() async {
    LocationData locationData = await findLocationData();
    setState(() {
      lat1 = locationData.latitude;
      lng1 = locationData.longitude;
      lat2 = double.parse(orderModel.lat);
      lng2 = double.parse(orderModel.lng);
      print('lat1 = $lng1, lng1 = $lng1, lat2 = $lat2, lng2 = $lng2');
      distance = MyAPI().calculateDistance(lat1, lng1, lat2, lng2);

      var myFormat = NumberFormat('#0.0#', 'en_US');
      distanceString = myFormat.format(distance);

      transport = MyAPI().calculateTransport(distance);

      print('distance = $distance');
      print('transport = $transport');
    });
  }

  Future<LocationData> findLocationData() async {
    Location location = Location();
    try {
      return await location.getLocation();
    } catch (e) {
      return null;
    }
  }

  Future<Null> readOrder() async {
    String id = orderModel.id;
    String url =
        '${MyConstant().domain}/smlao/getOrderWhereId.php?isAdd=true&id=$id';
    Response response = await Dio().get(url);
    print('response ==>> $response');

    var result = json.decode(response.data);
    print('result ==>> $result');

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Text(orderModel.nameShop),
            Text('ຂໍ້ມູນລາຍການສົ່ງສິນຄ້າ'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            MyStyle().showTitleH2('ຊະນິດຂອງຜູ້ໃຊ້ງານ :'),
            MyStyle().showTitleH2(orderModel.nameShop),
            MyStyle().showTitleH2(orderModel.nameUser),
            buildListFood(),
            buildTotals(),
            editButton(),
            boxMap(),
          ],
        ),
      ),
    );
  }

  Widget boxMap() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Card(
          child: Column(
            children: <Widget>[
              lat == null ? MyStyle().showProgress() : showMap(),
            ],
          ),
        ),
      ),
    );
  }

  Container showMap() {
    if (lat1 != null) {
      LatLng latLng1 = LatLng(lat1, lng2);
      position = CameraPosition(
        target: latLng1,
        zoom: 16.0,
      );
    }

    Marker userMarker() {
      return Marker(
        markerId: MarkerId('userMarker'),
        position: LatLng(lat1, lng1),
        icon: BitmapDescriptor.defaultMarkerWithHue(60.0),
        infoWindow: InfoWindow(title: 'ທ່ານຢູ່ທີ່ນີ້'),
      );
    }

    Marker shopMarker() {
      return Marker(
        markerId: MarkerId('shopMarker'),
        position: LatLng(lat2, lng2),
        icon: BitmapDescriptor.defaultMarkerWithHue(150.0),
        infoWindow: InfoWindow(title: orderModel.nameUser),
      );
    }

    Set<Marker> mySet() {
      return <Marker>[userMarker(), shopMarker()].toSet();
    }

    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 32),
      // color: Colors.grey,
      height: 250,
      width: 350.0,
      child: lat1 == null
          ? MyStyle().showProgress()
          : GoogleMap(
              initialCameraPosition: position,
              mapType: MapType.normal,
              onMapCreated: (controller) {},
              markers: mySet(),
            ),
    );
  }

  Widget buildListFood() => ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: orderModels.length,
        itemBuilder: (context, index) => Column(
          children: [
            Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Text('   ${orderModels[index].nameFood}'),
                ),
                Expanded(
                  flex: 1,
                  child: Text('${orderModels[index].sum} ກີບ'),
                ),
              ],
            ),
          ],
        ),
      );
  Widget buildTotals() => Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Row(
              children: <Widget>[
                MyStyle().showTitleH4('  ລວມ : '),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: MyStyle().showTitleH4('${total.toString()} ກີບ'),
          )
        ],
      );
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

  Widget showContent() => SingleChildScrollView(
        child: Column(
          children: <Widget>[
            phoneForm(),
            editButton(),
          ],
        ),
      );

  Widget editButton() => Container(
        // width: MediaQuery.of(context).size.width,
        child: ElevatedButton.icon(
          // color: MyStyle().primaryColor,
          onPressed: () => confirmDialog(),
          icon: Icon(
            Icons.offline_pin_outlined,
            color: Colors.white,
          ),
          label: Text(
            'ການສົ່ງ ສຳເລັດ ',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );

  Future<Null> confirmDialog() async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('ທ່ານຕ້ອງການຈະແກ້ໄຂ ລາຍລະອຽດຮ້ານນີ້ແທ້ບໍ?'),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  editorderThread();
                },
                child: Text('ຍອມຮັບ'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('ປະຕິເສດ'),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<Null> editorderThread() async {
    String id = orderModel.id;
    String apiEditStatus =
        '${MyConstant().domain}/smlao/editOrderWhereIdAnStatus.php?isAdd=true&id=$id&Status=OrderFinish';
    Response response = await Dio().get(apiEditStatus);
    if (response.toString() == 'true') {
      clearAllSQLite();
      notificationToShop(idShop);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MainRider(),
          ));
    } else {
      normalDialog(context, 'ບໍ່ສາມາດ Order ໄດ້ ກະລຸນາລອງໄໝ່');
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
    // if (object.length != 0) {
    //   for (var model in object) {
    //     // String sumString = model.sum;
    //     // int sumInt = int.parse(sumString);
    //     // String khasongString = model.transport;
    //     // int khasong = int.parse(khasongString);
    //     // double.parse(khasong);
    //     setState(() {
    //       // status = false;
    //       // cartModels = object;
    //       // total = total + sumInt;
    //       // totalall = khasong + sumInt;
    //     });
    //   }
    // } else {
    //   setState(() {
    //     // status = true;
    //   });
    // }
  }

  Future<Null> notificationToShop(String idShop) async {
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

        sendNotificationToShop(urlSendToken);
      }
    });
  }

  Future<Null> sendNotificationToShop(String urlSendToken) async {
    await Dio().get(urlSendToken).then(
          (value) => normalDialog(context, 'ສົ່ງ Order ໄປທີ່ຮ້ານຄ້າສຳເລັດແລ້ວ'),
        );
  }

  Widget phoneForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 16.0),
            width: 250.0,
            child: TextFormField(
              // onChanged: (value) => status = value,
              initialValue: orderModel.id,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'ສະຖານະ',
              ),
            ),
          ),
        ],
      );
}
