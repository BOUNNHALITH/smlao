import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:smlao/model/cart_model.dart';
import 'package:smlao/model/user_model.dart';
import 'package:smlao/user/wait_shop_check_order.dart';
import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/my_style.dart';
import 'package:smlao/utility/normal_dialog.dart';
import 'package:smlao/utility/sqlite_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SendOrder extends StatefulWidget {
  final UserModel userModel;

  const SendOrder({Key key, this.userModel, List<CartModel> cartModel})
      : super(key: key);
  @override
  _SendOrderState createState() => _SendOrderState();
}

class _SendOrderState extends State<SendOrder> {
  final money = NumberFormat('#,##0', 'en_US');
  UserModel userModel;
  String address, addressAround, phone, payment, transport, idUser;
  String nameShop, urlPicture;
  Location location = Location();
  List<CartModel> cartModels = [];
  double lat, lng;
  int totalalls = 0;
  int total = 0;
  File file;
  bool statususer = true;
  @override
  void initState() {
    super.initState();
    readCurrentInfo();
    readSQLite();
    // findLatLng();
    location.onLocationChanged.listen((event) {
      setState(() {
        lat = event.latitude;
        lng = event.longitude;
        // print('lat = $lat, lng = $lng');
      });
    });
  }

  Future<Null> readCurrentInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idUser = preferences.getString('id');
    print('idShop ==>> $idUser');

    String url =
        '${MyConstant().domain}/smlao/getUserWhereId.php?isAdd=true&id=$idUser';

    Response response = await Dio().get(url);
    // print('response ==>> $response');

    var result = json.decode(response.data);
    // print('result ==>> $result');
    for (var map in result) {
      print('map ==>> $map');
      setState(() {
        userModel = UserModel.fromJson(map);
        nameShop = userModel.nameShop;
        address = userModel.address;
        addressAround = userModel.addressAround;
        phone = userModel.phone;
        urlPicture = userModel.urlPicture;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(8.0),
        // ignore: deprecated_member_use
        child: ElevatedButton(
          onPressed: () {
            if (address == null ||
                address.isEmpty ||
                addressAround == null ||
                addressAround.isEmpty ||
                // payment == null ||
                // payment.isEmpty ||
                phone == null ||
                phone.isEmpty) {
              normalDialog(context, 'ກະລຸນາປ່ອນຂໍ້ມູນໃຫ້ຄົບ');
            } else {
              // infoAddress();
              fromSendOrder();
              updateAdress();
            }
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.green,
            onPrimary: Colors.white
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                "ຢັ້ງຢືນຂໍ້ມູນທີ່ຢູ່",
                style: TextStyle(
                  color: Colors.white,
                  // fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      body: userModel == null ? MyStyle().showProgress() : showContent(),
      appBar: AppBar(
        // title: Text('ແກ້ໄຂ ລາຍລະອຽດຮ້ານ'),
        //  userModel: userModels.namshop,
        title: Text(cartModels[0].nameShop),
      ),
    );
  }

  Future<Null> fromSendOrder() async {
    DateTime dateTime = DateTime.now();
    String orderDateTime = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);

    String idShop = cartModels[0].idShop;
    String nameShop = cartModels[0].nameShop;
    String distance = cartModels[0].distance;
    String transport = cartModels[0].transport;
    List<String> idFoods = [];
    List<String> nameFoods = [];
    List<String> prices = [];
    List<String> amounts = [];
    List<String> sums = [];
    for (var model in cartModels) {
      idFoods.add(model.idFood);
      nameFoods.add(model.nameFood);
      prices.add(model.price);
      amounts.add(model.amount);
      // sums.add(model.sum);
      sums.add(model.sum);
    }
    String idFood = idFoods.toString();
    String nameFood = nameFoods.toString();
    String price = prices.toString();
    String amount = amounts.toString();
    String sum = sums.toString();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idUser = preferences.getString('id');
    String nameUser = preferences.getString('Name');
    String url =
        '${MyConstant().domain}/smlao/addOrder.php?isAdd=true&OrderDateTime=$orderDateTime&idUser=$idUser&NameUser=$nameUser&idShop=$idShop&NameShop=$nameShop&Distance=$distance&Transport=$transport&idFood=$idFood&NameFood=$nameFood&Price=$price&Amount=$amount&Sum=$sum&idRider=none&Status=UserOrder&Address=$address&AddressAround=$addressAround&Phone=$phone&Lat=$lat&Lng=$lng';

    print('###### urlAddOrder ===>>> $url');
    await Dio().get(url).then((value) {
      if (value.toString() == 'true') {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WaitShopCheckOrder(),
            ));
        clearAllSQLite();
        notificationToShop(idShop);
      } else {
        normalDialog(context, 'ບໍ່ສາມາດ Order ໄດ້ ກະລຸນາລອງໄໝ່');
      }
    });
  }

  Future<Null> clearAllSQLite() async {
    await SQLiteHelper().deleteAllData().then((value) {
      readSQLite();
    });
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
          (value) => normalDialog(context, 'ສົ່ງ ອໍເດີ ໄປທີ່ຮ້ານຄ້າສຳເລັດແລ້ວ'),
        );
  }

  Future<Null> readSQLite() async {
    var object = await SQLiteHelper().readAllDataFromSQLite();
    print('object length ==> ${object.length}');
    if (object.length != 0) {
      for (var model in object) {
        String khasong = model.transport;
        String sumString = model.sum;
        int sumInt = int.parse(sumString);
        int transport = int.parse(khasong);

        setState(() {
          statususer = false;
          cartModels = object;
          total = total + sumInt;
          totalalls = total + transport;
        });
      }
    } else {
      setState(() {
        statususer = true;
      });
    }
  }

  Widget showContent() => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Container(
              child: Column(
                children: <Widget>[
                  MyStyle().mySizebox(),
                  MyStyle().showTitleH3('ຂໍ້ມູນສຳລັບຈັດສົ່ງ'),
                  // Divider(),

                  // editButton(),
                  buildAddress(),
                  buildPayment(),
                  buildListOrder(),
                ],
              ),
            ),
          ),
        ),
      );
  Widget buildListOrder() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Card(
          child: Column(
            children: <Widget>[
              MyStyle().showTitleH3('ສະຫລູບການສັ່ງຊື້ສິນຄ້າ :'),
              Divider(),
              buildListFood(),
              Divider(),
              buildTotals(),
              buildKhasong(),
              Divider(),
              MyStyle().mySizebox1(),
              buildTotalAll(),
              MyStyle().mySizebox1(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPayment() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Card(
          child: Column(
            children: <Widget>[
              // Divider(),
              MyStyle().mySizebox(),
              MyStyle().showTitleH3('ວິທີການຊຳລະຄ່າສິນຄ້າ :'),
              Divider(),
              paymentsod(),
            ],
          ),
        ),
      ),
    );
  }

  Widget paymentsod() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            width: 250.0,
            child: Row(
              children: <Widget>[
                Radio(
                  value: 'moneysod',
                  groupValue: payment,
                  onChanged: (value) {
                    setState(() {
                      payment = value;
                    });
                  },
                ),
                Text(
                  'ເງິນສົດ',
                  style: TextStyle(color: MyStyle().darkColor),
                )
              ],
            ),
          ),
        ],
      );
  Widget buildAddress() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Card(
          child: Column(
            children: <Widget>[
              // Divider(),
              // MyStyle().mySizebox(),
              lat == null ? MyStyle().showProgress() : showMap(),
              // MyStyle().mySizebox(),
              addressForm(),
              // MyStyle().mySizebox(),
              addressAroundForm(),
              // MyStyle().mySizebox(),
              phoneForm(),
              MyStyle().mySizebox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListFood() => ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: cartModels.length,
        itemBuilder: (context, index) => Column(
          children: [
            Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Text('   ${cartModels[index].nameFood}'),
                ),
                Expanded(
                    flex: 0,
                    child: Text(money.format(
                      int.parse(cartModels[index].sum),
                    ))),
                Expanded(
                  flex: 0,
                  child: MyStyle().showTitleH11(' ກີບ'),
                ),
              ],
            ),
          ],
        ),
      );
  Widget buildTotalAll() => Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                MyStyle().showTitleH2('ລວມມູນຄ່າ: '),
              ],
            ),
          ),
          Expanded(
            flex: 0,
            child: Text(
              money.format(int.parse(totalalls.toString())),
              style: MyStyle().mainTitleRedd,
            ),
          ),
          Expanded(
            flex: 0,
            child: MyStyle().showTitleH3Red(' ກີບ'),
          )
        ],
      );
  Widget buildKhasong() => Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                MyStyle().showTitleH3('  ຄ່າຈັດສົ່ງ : '),
              ],
            ),
          ),
          Expanded(
            flex: 0,
            child: Text(
              money.format(int.parse(cartModels[0].transport)),
              style: MyStyle().mainTitle,
            ),
          ),
          Expanded(
            flex: 0,
            child: MyStyle().showTitleH3(' ກີບ'),
          )
        ],
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
            flex: 0,
            child: Text(
              money.format(int.parse(total.toString())),
              style: MyStyle().mainTitleGreen,
            ),
          ),
          Expanded(
            flex: 0,
            child: MyStyle().showTitleH4(' ກີບ'),
          )
          // Expanded(
          //   flex: 1,
          //   child: MyStyle().showTitleH4('${total.toString()} ກີບ'),
          // )
        ],
      );

  Future<Null> updateAdress() async {
    String id = userModel.id;
    String url =
        '${MyConstant().domain}/smlao/updateAdress.php?isAdd=true&id=$id&Address=$address&AddressAround=$addressAround&Phone=$phone&Lat=$lat&Lng=$lng';
    // Response response =
    await Dio().get(url);
    // if (response.toString() == 'true') {
    //   Navigator.pop(context);
    // } else {
    //   normalDialog(context, 'ຍັງແກ້ໄຂບໍ່ໄດ້ ກະລຸນາແກ້ໄຂໄໝ່');
    // }
    // });
  }

  Set<Marker> currentMarker() {
    return <Marker>[
      Marker(
          markerId: MarkerId('myMarker'),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
              title: 'ທີ່ຢູ່ຮ້ານ', snippet: 'Lat = $lat, Lng = $lng'))
    ].toSet();
  }

  Container showMap() {
    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 16.0,
    );
    return Container(
      margin: EdgeInsets.only(top: 16.0),
      height: 150,
      width: 350.0,
      child: GoogleMap(
        initialCameraPosition: cameraPosition,
        mapType: MapType.normal,
        onMapCreated: (controller) {},
        markers: currentMarker(),
      ),
    );
  }

  Widget addressAroundForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 16.0),
            width: 250.0,
            child: TextFormField(
              onChanged: (value) => addressAround = value,
              initialValue: userModel.addressAround,
              // keyboardType: TextInputType.streetAddress,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.location_on,
                  color: MyStyle().darkColor,
                ),
                labelText: 'ຈຸດສັງເກດຂອງບ່ອນຈັດສົ່ງ :',
              ),
            ),
          ),
        ],
      );

  Widget addressForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 16.0),
            width: 250.0,
            child: TextFormField(
              onChanged: (value) => address = value,
              initialValue: userModel.address,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.home,
                  color: MyStyle().darkColor,
                ),
                labelText: 'ບ້ານ/ຮ່ອມ/ທີ່ຈະໃຫ້ໄປສົ່ງ:',
              ),
            ),
          ),
        ],
      );

  Widget phoneForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 16.0),
            width: 250.0,
            child: TextFormField(
              onChanged: (value) => phone = value,
              initialValue: userModel.phone,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'ເບີ້ຕິດຕໍ່',
              ),
            ),
          ),
        ],
      );
  Future<LocationData> findLocationData() async {
    Location location = Location();
    try {
      return location.getLocation();
    } catch (e) {
      return null;
    }
  }
}
