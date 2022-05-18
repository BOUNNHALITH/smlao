import 'package:flutter/material.dart';
import 'package:smlao/rider/order_reciepts.dart';
import 'package:smlao/rider/order_riding.dart';
import 'package:smlao/utility/my_style.dart';
import 'package:smlao/utility/signout_process.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainRider extends StatefulWidget {
  @override
  _MainRiderState createState() => _MainRiderState();
}

class _MainRiderState extends State<MainRider> {
  String nameUser;
  Widget currentWidget = OrderAll();
  @override
  void initState() {
    super.initState();

    findUser();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nameUser == null ? 'Main Rider' : 'login  $nameUser'),
        // title: Text('Main Rider'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => signOutProcess(context),
          )
        ],
      ),
      drawer: showDrawer(),
      body: currentWidget,
    );
  }

  Drawer showDrawer() => Drawer(
        child: ListView(
          children: <Widget>[
            showHead(),
            orderRiding(),
          ],
        ),
      );

  Future<Null> findUser() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      nameUser = preferences.getString('Name');
    });
  }

  Widget orderRiding() {
    return ListTile(
      leading: Icon(Icons.shopping_cart),
      title: Text('ສິນຄ້າທີ່ກຳລັງໄປສົ່ງ'),
      subtitle: Text('ສິຄ້າທີເລຶອກ ກຳລັງໄປສົ່ງ'),
      onTap: () {
        setState(() {
          currentWidget = OrderRiding();
        });
        Navigator.pop(context);
      },
    );
  }

  UserAccountsDrawerHeader showHead() {
    return UserAccountsDrawerHeader(
      decoration: MyStyle().myBoxDecoration('rider.jpg'),
      currentAccountPicture: MyStyle().showLogo(),
      accountName: Text(
        'Name Rider',
        style: TextStyle(color: MyStyle().darkColor),
      ),
      accountEmail: Text(
        'Login',
        style: TextStyle(color: MyStyle().primaryColor),
      ),
    );
  }
}
