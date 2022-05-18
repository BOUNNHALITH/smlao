import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smlao/model/user_model.dart';
import 'package:smlao/screens/main_user.dart';
import 'package:smlao/user/wait_shop_check_order.dart';
import 'package:smlao/model/cart_model.dart';
import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/my_style.dart';
import 'package:smlao/utility/normal_dialog.dart';
import 'package:smlao/utility/sqlite_helper.dart';

class ShowCart extends StatefulWidget {
  @override
  _ShowCartState createState() => _ShowCartState();
}

class _ShowCartState extends State<ShowCart> {
  DateTime selectedDate = DateTime.now();
  DateTime selectedDateTime = DateTime.now();

  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  final money = NumberFormat('#,##0', 'en_US');
  UserModel userModel;
  CartModel cartModel;
  List<CartModel> cartModels = [];
  int total = 0;
  bool status = true;
  int id;
  String address, nameUser, phone, payment, transport, idUser;
  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    // readSQLite();
    readCurrentInfo();
  }

  Future<Null> readCurrentInfo() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idUser = preferences.getString('id');
    print('idUser ==>> $idUser');

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
        nameUser = userModel.name;
        address = userModel.address;
        phone = userModel.phone;
        readSQLite();
        // clearAllSQLite();
      });
    }
  }

  Future<Null> readSQLite() async {
    var object = await SQLiteHelper().readAllDataFromSQLite();
    print('object length ==> ${object.length}');
    if (object.length != 0) {
      for (var model in object) {
        String sumString = model.sum;
        int sumInt = int.parse(sumString);

        setState(
          () {
            status = false;
            cartModels = object;
            total = total + sumInt;
          },
        );
        String idUserSQLite = object[0].idUser;
        if (!((idUser == idUserSQLite))) {
          await SQLiteHelper().readAllDataFromSQLite();
        } else {
          // Text('ທ່ານຍັງບໍ່ທັນໄດ້ເພີ່ມຫຍັງເຂົ້າໃນກະຕ່າ');
          // }

        }
      }
    } else {
      setState(() {
        status = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ກະຕ່າ'),
        actions: <Widget>[
          // IconButton(
          //   icon: Icon(Icons.close),
          //   onPressed: () => Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => MainUser(),
          //     ),
          //   ),
          // ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(8.0),
        // ignore: deprecated_member_use
        child: ElevatedButton(
          onPressed: () {
            confirmOrder();
            // }
          },
          style: ElevatedButton.styleFrom(
              primary: Colors.green,
              onPrimary: Colors.white
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                "ສັ່ງຊື້ສິນຄ້າ",
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
      body: status
          ? Center(
              child: Text('ທ່ານຍັງບໍ່ທັນໄດ້ເພີ່ມຫຍັງເຂົ້າໃນກະຕ່າ'),
            )
          : buildContent(),
    );
  }

  Widget buildContent() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              buildNameShop(),
              buildHeadTitle(),
              buildListFood(),
              Divider(),
              buildTotal(),
              // buildClearCartButton(),
              // buildOrderButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildClearCartButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          height: 30,
          width: 120,
          child: ElevatedButton.icon(
              // shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(30)),
              // color: MyStyle().primaryColor,
              onPressed: () {
                confirmDeleteAllData();
              },
              icon: Icon(
                Icons.delete_outline,
                color: Colors.white,
              ),
              label: Text(
                'ລົບ ກະຕ່າ',
                style: TextStyle(color: Colors.redAccent),
              )),
        ),
      ],
    );
  }

  Widget buildOrderButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 150,
          child: ElevatedButton.icon(
              onPressed: () {
                confirmOrder();
                // }
                // fromSendOrder();
              },
              icon: Icon(
                Icons.send_rounded,
                color: Colors.white,
              ),
              label: Text(
                'ສັ່ງຊື້ສິນຄ້າ',
                style: TextStyle(color: Colors.white),
              )),
        ),
      ],
    );
  }

  Future<Null> confirmOrder() async {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MyStyle().showTitleH3black('ຂໍ້ມູນການຈັດສົ່ງ'),
              dateTimesentForm(),
              nameForm(),
              addressForm(),
              phoneForm(),
              MyStyle().mySizebox(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                    width: 110,
                    child: ElevatedButton(
                      onPressed: () {
                        fromSendOrder();
                        Navigator.pop(context);
                        // }
                      },
                      child: Text(
                        'ຕົກລົງ',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget nameForm() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 16.0),
            width: 200.0,
            child: TextFormField(
              onChanged: (value) => nameUser = value,
              initialValue: userModel.name,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.home,
                  color: MyStyle().darkColor,
                ),
                labelText: 'ສັ່ງຈາກຮ້ານ:',
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
            width: 200.0,
            child: TextFormField(
              onChanged: (value) => address = value,
              initialValue: userModel.address,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.location_city,
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
            width: 200.0,
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
  Widget dateTimesentForm() => SingleChildScrollView(
        // child: Padding(
        //   padding: const EdgeInsets.all(10.0),
        child: Container(
          margin: EdgeInsets.only(top: 16.0),
          width: 200.0,
          child: Card(
            child: Column(
              children: <Widget>[
                MyStyle().showTitleH3green('ເລືອກວັນທີ່ ແລະ ເວລາສົ່ງ'),
                // Divider(),
                dateTime(),
              ],
            ),
          ),
        ),
      );

  Widget dateTime() => Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ElevatedButton(
            child: Text(dateFormat.format(selectedDate)),
            onPressed: () async {
              // Navigator.pop(context);
              final selectedDate = await _selectDateTime(context);
              if (selectedDate == null) return;

              print(selectedDate);

              final selectedTime = await _selectTime(context);
              if (selectedTime == null) return;
              print(selectedTime);
              // Navigator.pop(context);
              setState(
                () {
                  this.selectedDate = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                  print(selectedDate);
                  // Navigator.pop(context);
                },
              );
            },
          ),
        ],
      );

  Future<TimeOfDay> _selectTime(BuildContext context) {
    final now = DateTime.now();
    // print(selectedDate);
    Navigator.pop(context);
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now.hour, minute: now.minute),
    );
  }

  Future<DateTime> _selectDateTime(BuildContext context) => showDatePicker(
        context: context,
        initialDate: DateTime.now().add(Duration(seconds: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );

  Future<Null> fromSendOrder() async {
    DateTime dateTime = DateTime.now();
    String orderDateTime = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    String dateTimeSent = DateFormat('yyyy-MM-dd HH:mm').format(selectedDate);
    String idShop = cartModels[0].idShop;
    String nameShop = cartModels[0].nameShop;
    List<String> idFoods = [];
    List<String> nameFoods = [];
    List<String> prices = [];
    List<String> amounts = [];
    List<String> details = [];
    List<String> sums = [];
    for (var model in cartModels) {
      idFoods.add(model.idFood);
      nameFoods.add(model.nameFood);
      prices.add(model.price);
      amounts.add(model.amount);
      details.add(model.detail);
      sums.add(model.sum);
    }
    String idFood = idFoods.toString();
    String nameFood = nameFoods.toString();
    String price = prices.toString();
    String amount = amounts.toString();
    String detail = details.toString();
    String sum = sums.toString();

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String idUser = preferences.getString('id');
    String nameUser = preferences.getString('Name');
    String url =
        '${MyConstant().domain}/smlao/addOrder.php?isAdd=true&OrderDateTime=$orderDateTime&DateTimeSent=$dateTimeSent&idUser=$idUser&NameUser=$nameUser&idShop=$idShop&NameShop=$nameShop&idFood=$idFood&NameFood=$nameFood&Price=$price&Amount=$amount&Detail=$detail&Sum=$sum&idRider=none&Status=UserOrder&Address=$address&Phone=$phone';

    print('###### urlAddOrder ===>>> $url');
    await Dio().get(url).then((value) {
      if (value.toString() == 'true') {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WaitShopCheckOrder(),
              // builder: (context) => WaitOrder(),
            ));
        clearAllSQLite();
        notificationToShop(idShop);
      } else {
        normalDialog(context, 'ບໍ່ສາມາດ Order ໄດ້ ກະລຸນາລອງໄໝ່');
      }
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
        String body = 'ມີການສັ່ງສິນຄ້າຈາກ $nameUser ';
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

  Future<Null> clearAllSQLite() async {
    await SQLiteHelper().deleteAllData().then((value) {
      readSQLite();
      // readAllDataFromSQLite();
    });
  }

  Widget buildTotal() => Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                MyStyle().showTitleH2('ລວມລາຄາ : '),
              ],
            ),
          ),
          Expanded(
            flex: 0,
            child:
                //  MyStyle().showTitleH3Red('${total.toString()} ກີບ'),
                Text(
              money.format(int.parse(total.toString())),
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
        ],
      );
  Widget buildNameShop() {
    return Container(
      margin: EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              MyStyle().showTitleH2('ບໍລິສັດ ເມືອງລາວ'),
            ],
          ),
          // Row(
          //   children: <Widget>[
          //     MyStyle()
          //         .showTitleH3('ໄລຍະທາງ = ${cartModels[0].distance} ກິໂລແມັດ'),
          //   ],
          // ),
          Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    MyStyle().showTitleH3(
                        'ວັນທີ່: ${dateFormat.format(selectedDateTime)}'),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: buildClearCartButton(),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget buildHeadTitle() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade300),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: MyStyle().showTitleH3('ລາຍການສິນຄ້າ'),
          ),
          Expanded(
            flex: 1,
            child: MyStyle().showTitleH3('ລາຄາ'),
          ),
          Expanded(
            flex: 1,
            child: MyStyle().showTitleH3('ຈຳນວນ'),
          ),
          Expanded(
            flex: 1,
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

  Widget buildListFood() => ListView.builder(
        shrinkWrap: true,
        physics: ScrollPhysics(),
        itemCount: cartModels.length,
        itemBuilder: (context, index) => Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Text(cartModels[index].nameFood),
            ),
            Expanded(
              flex: 1,
              child: Text(money.format(int.parse(cartModels[index].price))),
            ),
            Expanded(
              flex: 1,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text(
                    money.format(int.parse(cartModels[index].amount)),
                    style: MyStyle().mainTitle,
                  ),
                  new Text(
                    '/ ${cartModels[index].detail}',
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(money.format(int.parse(cartModels[index].sum))),
              // child: Text(cartModels[index].sum),
            ),
            Expanded(
                flex: 1,
                child: IconButton(
                  icon: Icon(Icons.delete_forever),
                  onPressed: () async {
                    int id = cartModels[index].id;
                    print('You Click Delete id = $id');
                    await SQLiteHelper().deleteDataWhereId(id).then((value) {
                      print('Success Delete id = $id');
                      MyStyle().showProgress();
                      Navigator.pop(context);
                      // readSQLite();
                      readCurrentInfo();
                    });
                  },
                )),
          ],
        ),
      );

  Future<Null> confirmDeleteAllData() async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('ທ່ານຕ້ອງການຈະລົບ ລາຍການສິນຄ້າທັງໝົດ ແທ້ບໍ ?'),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              // ignore: deprecated_member_use
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: MyStyle().primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                // color: MyStyle().primaryColor,
                onPressed: () async {
                  // readSQLite();
                  await SQLiteHelper().deleteAllData().then((value) {
                    // Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainUser(),
                        ));
                    readSQLite();
                  });
                },
                icon: Icon(
                  Icons.check,
                  color: Colors.white,
                ),
                label: Text(
                  'ຍອມຮັບ',
                  style: TextStyle(color: Colors.white),
                ),
              ),

              // ignore: deprecated_member_use
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: MyStyle().primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                // color: MyStyle().primaryColor,
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
                label: Text(
                  'ປະຕິເສດ',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
