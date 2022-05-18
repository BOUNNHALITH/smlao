import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:smlao/model/order_model.dart';
// import 'package:smlao/model/groupfood_model.dart';
import 'package:smlao/model/user_model.dart';
import 'package:smlao/screens/main_rider.dart';
import 'package:smlao/utility/my_api.dart';
import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/my_style.dart';
import 'package:smlao/utility/normal_dialog.dart';
import 'package:smlao/utility/sqlite_helper.dart';

class MapOrder extends StatefulWidget {
  final UserModel userModel;
  final OrderModel orderModel;
  MapOrder({Key key, this.userModel, this.orderModel}) : super(key: key);
  @override
  _MapOrderState createState() => _MapOrderState();
}

class _MapOrderState extends State<MapOrder> {
  UserModel userModel;
  OrderModel orderModel;
  double lat1, lng1, lat2, lng2, distance;
  String distanceString;
  int transport;
  CameraPosition position;
  String idUser;
  String idShop, id, status;
  @override
  void initState() {
    super.initState();
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
              showMap(),
              orderFinish(),
            ],
          ),
        ));
  }

  Widget orderFinish() => Container(
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
        infoWindow: InfoWindow(title: orderModel.nameShop),
      );
    }

    Set<Marker> mySet() {
      return <Marker>[userMarker(), shopMarker()].toSet();
    }

    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 32),
      // color: Colors.grey,
      height: 250,
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
}
