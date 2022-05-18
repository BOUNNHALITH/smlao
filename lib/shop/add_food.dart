import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smlao/model/food_model.dart';
import 'package:smlao/model/groupfood_model.dart';
import 'package:smlao/model/user_model.dart';
import 'package:smlao/shop/food_shop.dart';
import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/my_style.dart';
import 'package:smlao/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddFood extends StatefulWidget {
  final UserModel userModel;
  final GroupFoodModel groupFoodModel;
  AddFood({Key key, this.groupFoodModel, this.userModel}) : super(key: key);
  @override
  _AddFoodState createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  UserModel userModel;
  GroupFoodModel groupFoodModel;
  String idShop, idGrp, status;
  List<GroupFoodModel> groupFoodModels = [];
  List<FoodModel> foodModels = [];
  File file;
  String nameFood, price, detail, nameGroup;
  // String idShop;
  // ignore: deprecated_member_use
  List<UserModel> userModels = List();
  int total = 0;
  int amount = 1;
  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    groupFoodModel = widget.groupFoodModel;
    userModel = widget.userModel;
    readFoodMenu();
  }

  Future<Null> readFoodMenu() async {
    idGrp = groupFoodModel.id;
    idShop = groupFoodModel.idShop;
    String url =
        '${MyConstant().domain}/smlao/getGroupFoodWhereIdGrp.php?isAdd=true&idGrp=$idGrp&idShop=2';

    Response response = await Dio().get(url);
    if (response.toString() != 'null') {
      var result = json.decode(response.data);
      for (var map in result) {
        FoodModel foodModel = FoodModel.fromJson(map);
        setState(() {
          foodModels.add(foodModel);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // actions: <Widget>[MyStyle().iconShowCart(context, amount)],
        title: Row(
          children: [
            Text(groupFoodModel.nameGroup),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(8.0),

        // ignore: deprecated_member_use
        child: ElevatedButton(
          onPressed: () {
            if (file == null) {
              normalDialog(context,
                  'ກະລຸນາເລືອກຮູບພາບອາຫານ ໂດຍການ ເລຶອກທີ່ Camera ຫລື Gallery');
            } else if (nameFood == null ||
                nameFood.isEmpty ||
                price == null ||
                price.isEmpty ||
                detail == null ||
                detail.isEmpty ||
                idGrp == null ||
                idGrp.isEmpty) {
              normalDialog(context, 'ກະລຸນາໃສ່ຂໍ້ມູນໃຫ້ຄົບ');
            } else {
              uploadFoodAndInsertData();
            }
          },
          // icon: Icon(
          //   Icons.save,
          //   color: Colors.white,
          // ),
          // label: Text(
          //   'ບັນທຶກ',
          //   style: TextStyle(color: Colors.white),
          // ),
          // },
          style: ElevatedButton.styleFrom(
              primary: Colors.green,
              onPrimary: Colors.white
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                "ບັນທຶກ",
                style: TextStyle(
                  color: Colors.white,
                  // fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              // addMenuButton(),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MyStyle().showTitleH2('ຮູບພາບສິນຄ່າ'),
              ],
            ),
            // showTitleFood('ຮູບພາບສິນຄ່າ'),
            pathImage(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                MyStyle().showTitleH2('ລາຍລະອຽດສິນຄ້າ'),
              ],
            ),
            // showTitleFood('ລາຍລະອຽດສິນຄ້າ'),
            groupFood(),
            MyStyle().mySizebox(),
            nameForm(),
            MyStyle().mySizebox(),
            priceForm(),
            MyStyle().mySizebox(),
            detailForm(),

            // MyStyle().mySizebox(),
            // groupForm(),
            MyStyle().mySizebox(),
            //
            // MyStyle().showTitleH2('ຊະນິດຂອງຜູ້ໃຊ້ງານ :'),
            // MyStyle().mySizebox(),
            // mee(),
            // bormee(),
            //
          ],
        ),
      ),
    );
  }

  Widget groupFood() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 16.0),
            width: 250.0,
            child: TextFormField(
              // onChanged: (value) => idGrp = value.trim(),
              // keyboardType: TextInputType.multiline,
              initialValue: idGrp,
              decoration: InputDecoration(
                labelText: 'ໝວດສິນຄ້າ',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      );
  Widget saveButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton.icon(
        onPressed: () {
          if (file == null) {
            normalDialog(context,
                'ກະລຸນາເລືອກຮູບພາບອາຫານ ໂດຍການ ເລຶອກທີ່ Camera ຫລື Gallery');
          } else if (nameFood == null ||
              nameFood.isEmpty ||
              price == null ||
              price.isEmpty ||
              detail == null ||
              detail.isEmpty ||
              idGrp == null ||
              idGrp.isEmpty) {
            normalDialog(context, 'ກະລຸນາໃສ່ຂໍ້ມູນໃຫ້ຄົບ');
          } else {
            uploadFoodAndInsertData();
          }
        },
        icon: Icon(
          Icons.save,
          color: Colors.white,
        ),
        label: Text(
          'ບັນທຶກ',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<Null> uploadFoodAndInsertData() async {
    String urlUpload = '${MyConstant().domain}/smlao/saveFood.php';

    Random random = Random();
    int i = random.nextInt(1000000);
    String nameFile = 'food$i.jpg';

    try {
      Map<String, dynamic> map = Map();
      map['file'] = await MultipartFile.fromFile(file.path, filename: nameFile);
      FormData formData = FormData.fromMap(map);

      await Dio().post(urlUpload, data: formData).then((value) async {
        String urlPathImage = '/smlao/Food/$nameFile';
        print('urlPathImage = ${MyConstant().domain}$urlPathImage');

        SharedPreferences preferences = await SharedPreferences.getInstance();
        String idShop = preferences.getString('id');

        String urlInsertData =
            '${MyConstant().domain}/smlao/addFood.php?isAdd=true&idShop=$idShop&NameFood=$nameFood&idGrp=$idGrp&PathImage=$urlPathImage&Price=$price&Detail=$detail&idGrp=$idGrp&Status=mee';
        // await Dio().get(urlInsertData).then((value)

        // => Navigator.pop(context));
        // // ListFoodMenuShop();
        await Dio().get(urlInsertData).then((value) {
          if (value.toString() == 'true') {
            // Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodShop(
                    groupFoodModel: groupFoodModel,
                    userModel: userModel,
                  ),
                ));
          } else {
            normalDialog(context, 'ບໍ່ສາມາດເພີ່ມໄດ້ ກະລຸນາລອງໄໝ່');
          }
        });
      });
    } catch (e) {}
  }

  Widget nameForm() => Container(
        width: 250.0,
        child: TextField(
          onChanged: (value) => nameFood = value.trim(),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.fastfood),
            labelText: 'ຊື່ສິນຄ້າ',
            border: OutlineInputBorder(),
          ),
        ),
      );

  Widget priceForm() => Container(
        width: 250.0,
        child: TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) => price = value.trim(),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.attach_money),
            labelText: 'ລາຄາ',
            border: OutlineInputBorder(),
          ),
        ),
      );

  Widget detailForm() => Container(
        width: 250.0,
        child: TextField(
          onChanged: (value) => detail = value.trim(),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.merge_type),
            labelText: 'ຫົວໜ່ວຍ',
            border: OutlineInputBorder(),
          ),
        ),
      );
  Widget statusForm() => Container(
        width: 250.0,
        child: TextField(
          onChanged: (value) => status = value.trim(),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.star_outline_sharp),
            labelText: 'ສະຖານະ',
            border: OutlineInputBorder(),
          ),
        ),
      );

  Row pathImage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.add_a_photo),
          onPressed: () => chooseImage(ImageSource.camera),
        ),
        Container(
          width: 250.0,
          height: 250.0,
          child: file == null
              ? Image.asset('images/foodmenu.png')
              : Image.file(file),
        ),
        IconButton(
          icon: Icon(Icons.add_photo_alternate),
          onPressed: () => chooseImage(ImageSource.gallery),
        ),
      ],
    );
  }

  Future<Null> chooseImage(ImageSource source) async {
    try {
      var object = await ImagePicker().getImage(
        source: source,
        maxWidth: 400.0,
        maxHeight: 400.0,
      );
      setState(() {
        file = File(object.path);
      });
    } catch (e) {}
  }

  Widget showTitleFood(String string) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          MyStyle().showTitleH2(string),
        ],
      ),
    );
  }

  Widget bormee() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            width: 250.0,
            child: Row(
              children: <Widget>[
                Radio(
                  value: 'bormee',
                  groupValue: status,
                  onChanged: (value) {
                    setState(() {
                      status = value;
                    });
                  },
                ),
                Text(
                  'ສິນຄ້າໝົດຊົ່ວຄາວ',
                  style: TextStyle(color: MyStyle().darkColor),
                )
              ],
            ),
          ),
        ],
      );
  Widget mee() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            width: 250.0,
            child: Row(
              children: <Widget>[
                Radio(
                  value: 'on',
                  groupValue: status,
                  onChanged: (value) {
                    setState(() {
                      status = value;
                    });
                  },
                ),
                Text(
                  'ມີສິນຄ້າ',
                  style: TextStyle(color: MyStyle().darkColor),
                )
              ],
            ),
          ),
        ],
      );
}
