import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:smlao/model/food_model.dart';
import 'package:smlao/model/groupfood_model.dart';
import 'package:smlao/shop/list_groupfood_menu_shop.dart';
import 'package:smlao/utility/my_constant.dart';
import 'package:smlao/utility/normal_dialog.dart';

class EditGoupFoodMenu extends StatefulWidget {
  final GroupFoodModel groupFoodModel;
  EditGoupFoodMenu(
      {Key key, this.groupFoodModel, GroupFoodModel GroupFoodModels})
      : super(key: key);

  @override
  _EditGoupFoodMenuState createState() => _EditGoupFoodMenuState();
}

class _EditGoupFoodMenuState extends State<EditGoupFoodMenu> {
  GroupFoodModel groupFoodModel;
  File file;
  String name, pathImage;

  @override
  void initState() {
    super.initState();
    groupFoodModel = widget.groupFoodModel;
    name = groupFoodModel.nameGroup;
    pathImage = groupFoodModel.pathImage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: uploadButton(),
      appBar: AppBar(
        title: Text('ແກ້ໄຂສິນຄ້າ ${groupFoodModel.nameGroup}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            nameGroupFood(),
            groupFoodImage(),
          ],
        ),
      ),
    );
  }

  // FloatingActionButton uploadButton() {
  //   return FloatingActionButton(
  //     onPressed: () {
  //       if (name.isEmpty) {
  //         normalDialog(context, 'ກະລຸກາໃສ່ຂ້ມູນໃຫ້ຄົບ');
  //       } else {
  //         confirmEditGroup();
  //       }
  //     },
  //     child: Icon(Icons.cloud_upload),
  //   );
  // }

  FloatingActionButton uploadButton() {
    return FloatingActionButton(
      onPressed: () {
        // file == null ? Text('No image selected') : Image.file(file);
        if (file == null) {
          confirmEditGroups();
        } else {
          confirmEditGroup();
        }
      },
      child: Icon(Icons.cloud_upload),
    );
  }

  Future<Null> confirmEditGroup() async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('ທ່ານຕ້ອງການຈະປ່ນແປງຂໍ້ມູນໝວດສິນຄ້ານີ້ແທ້ບໍ ?'),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  editValueOnMySQL();
                },
                icon: Icon(
                  Icons.check,
                  color: Colors.green,
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

  Future<Null> confirmEditGroups() async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('ທ່ານຕ້ອງການຈະປ່ນແປງຂໍ້ມູນໝວດສິນຄ້ານີ້ແທ້ບໍ ?'),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  editValueOnMySQLs();
                },
                icon: Icon(
                  Icons.check,
                  color: Colors.green,
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

  Future<Null> editValueOnMySQL() async {
    Random random = Random();
    int i = random.nextInt(100000);
    String nameFile = 'editGroupFood$i.jpg';

    Map<String, dynamic> map = Map();
    map['file'] = await MultipartFile.fromFile(file.path, filename: nameFile);
    FormData formData = FormData.fromMap(map);
    String urlUpload = '${MyConstant().domain}/smlao/saveGroupFood.php';
    await Dio().post(urlUpload, data: formData).then((value) async {
      pathImage = '/smlao/GroupFood/$nameFile';
      String id = groupFoodModel.id;
      // print('id = $id');
      String url =
          '${MyConstant().domain}/smlao/editGroupFoodWhereId.php?isAdd=true&id=$id&NameGroup=$name&PathImage=$pathImage';
      Response response = await Dio().get(url);
      if (response.toString() == 'true') {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListGroupFoodMenu(
                  // groupFoodModel: groupFoodModel,
                  // userModel: userModel,
                  ),
            ));
      } else {
        normalDialog(context, 'ຍັງແກ້ໄຂບໍ່ໄດ້ ກະລຸນາແກ້ໄຂໄໝ່');
      }
    });
  }

  Future<Null> editValueOnMySQLs() async {
    String id = groupFoodModel.id;
    // print('id = $id');
    String url =
        '${MyConstant().domain}/smlao/editGroupFoodWhereId.php?isAdd=true&id=$id&NameGroup=$name';
    Response response = await Dio().get(url);
    if (response.toString() == 'true') {
      Navigator.pop(context);
    } else {
      normalDialog(context, 'ຍັງແກ້ໄຂບໍ່ໄດ້ ກະລຸນາແກ້ໄຂໄໝ່');
    }
  }

  Widget groupFoodImage() => Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.add_a_photo),
            onPressed: () => chooseImage(ImageSource.camera),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            width: 250.0,
            height: 250,
            child: file == null
                ? Image.network(
                    '${MyConstant().domain}${groupFoodModel.pathImage}',
                    fit: BoxFit.cover,
                  )
                : Image.file(file),
          ),
          IconButton(
            icon: Icon(Icons.add_photo_alternate),
            onPressed: () => chooseImage(ImageSource.gallery),
          ),
        ],
      );

  Future<Null> chooseImage(ImageSource source) async {
    try {
      var object = await ImagePicker().getImage(
        source: source,
        maxWidth: 800.0,
        maxHeight: 800.0,
      );
      setState(() {
        file = File(object.path);
      });
    } catch (e) {}
  }

  Widget nameGroupFood() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 16.0),
            width: 250.0,
            child: TextFormField(
              onChanged: (value) => name = value.trim(),
              initialValue: name,
              decoration: InputDecoration(
                labelText: 'ຊື່ໝວດສິນຄ້າ',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      );
}
