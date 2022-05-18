import 'package:flutter/material.dart';
import 'package:smlao/screens/main_user.dart';
import 'package:smlao/showorder/show_cart.dart';

import 'my_constant.dart';

class MyStyle {
  Color darkColor = Colors.green;
  Color primaryColor = Colors.green;
  Widget iconShowCart(BuildContext context, int amounts) {
    return Container(
      child: Row(children: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {},
        ),
        SizedBox(width: 15),
        Stack(
          // ignore: deprecated_member_use
          // overflow: Overflow.visible,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                // Navigator.push(context, route).then(onGoBack);

                // Navigator.push(context, route).then(
                //   (value) => checkAmunt(),
                // );

                MaterialPageRoute route = MaterialPageRoute(
                  builder: (context) => ShowCart(),
                );
                // Navigator.push(context, route);
                Navigator.push(context, route).then((value) => MainUser());
              },
            ),
            shownumber(amounts)
          ],
        )
      ]),
    );
  }

  Widget shownumber(int amounts) {
    return Positioned(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                border: Border.all(color: Colors.white, width: 1.5)),
            child: Text(
              '$amounts',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget showCart(BuildContext context, int amounts) {
    return Container(
      child: Row(children: <Widget>[
        shownumber1(amounts),
      ]),
    );
  }

  Widget shownumber1(int amounts) {
    return Positioned(
      child: Container(
        width: 18,
        height: 18,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
            border: Border.all(color: Colors.white, width: 1.5)),
        child: Text(
          '$amounts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget shownumbers(BuildContext context, int amounts) {
    return Positioned(
      child: Container(
        width: 25,
        height: 25,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
            border: Border.all(color: Colors.white, width: 1.5)),
        child: Text(
          '$amounts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  ButtonStyle myButtonStyle() => ElevatedButton.styleFrom(
        primary: MyConstant.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      );
  Widget showProgress() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget showwarng() {
    return Center(
      child: Text('ຍັງບໍ່ມີອໍເດີຈາກລູກຄ້າ'),
    );
  }

  TextStyle mainTitle = TextStyle(
    fontSize: 16.0,
    // fontWeight: FontWeight.bold,
    color: Colors.green,
  );
  TextStyle mainTitleRedd = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Colors.red,
  );
  TextStyle mainTitleGreen = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
    color: Colors.green,
  );
  TextStyle h2Style() => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.green.shade700,
      );
  TextStyle mainH2Title = TextStyle(
    fontSize: 14.0,
    // fontWeight: FontWeight.bold,
    color: Colors.green.shade700,
  );

  TextStyle h1Style() => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.green.shade700,
      );
  BoxDecoration myBoxDecoration(String namePic) {
    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage('images/$namePic'),
        fit: BoxFit.cover,
      ),
    );
  }

  SizedBox mySizeboxs() => SizedBox(
        width: 3.0,
        // height: 16.0,
      );
  SizedBox mySizebox() => SizedBox(
        width: 8.0,
        height: 16.0,
      );
  SizedBox mySizebox1() => SizedBox(
        width: 8.0,
        height: 8.0,
      );
  Widget titleCenter(BuildContext context, String string) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        child: Text(
          string,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Text showTitle(String title) => Text(
        title,
        style: TextStyle(
          fontSize: 20.0,
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      );
  Text showTitleH11(String title) => Text(
        title,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.green,
        ),
      );

  Text showTitleH2(String title) => Text(
        title,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      );
  Text showTitleH4(String title) => Text(
        title,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      );
  Text showTitleH1(String title) => Text(
        title,
        style: TextStyle(
          fontSize: 12.0,
          color: Colors.green,
        ),
      );

  Text showTitleH3(String title) => Text(
        title,
        style: TextStyle(
          fontSize: 15.0,
          color: Colors.green,
          fontWeight: FontWeight.w500,
        ),
      );
  Text showTitleH5(String title) => Text(
        title,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      );
  Text showTitleH3White(String title) => Text(
        title,
        style: TextStyle(
          fontSize: 14.0,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      );
  Text showTitleH3Red(String title) => Text(
        title,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.red.shade900,
          // fontWeight: FontWeight.w500,
          fontWeight: FontWeight.bold,
        ),
      );
  Text showTitleH3black(String title) => Text(
        title,
        style: TextStyle(
          fontSize: 16.0,
          // color: Colors.red.shade900,
          // fontWeight: FontWeight.w500,
          fontWeight: FontWeight.bold,
        ),
      );
  Text showTitleH3green(String title) => Text(
        title,
        style: TextStyle(
          fontSize: 14.0,
          color: Colors.green.shade700,
          // fontWeight: FontWeight.w500,
          fontWeight: FontWeight.bold,
        ),
      );
  Text showTitleH3Purple(String title) => Text(
        title,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.purple.shade700,
          fontWeight: FontWeight.w500,
        ),
      );

  Container showLogo() {
    return Container(
      width: 120.0,
      child: Image.asset('images/logo2.png'),
    );
  }

  Container showImagess() {
    return Container(
      height: 8,
      width: 8,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
    );
  }

  Container showImages() {
    return Container(
      // height: 60,
      child: Image.asset('images/1111.png'),
    );
  }

  // MyStyle();
}
