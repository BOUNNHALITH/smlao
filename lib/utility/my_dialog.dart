import 'package:flutter/material.dart';
import 'package:smlao/screens/main_user.dart';

class MyDialog {
  Future<void> noTimeDialog(BuildContext context, String message) async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(message),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              ElevatedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainUser(),
                      ),
                      (route) => false),
                  child: Text(
                    'OK',
                    style: TextStyle(color: Colors.red),
                  )),
            ],
          )
        ],
      ),
    );
  }

  // Future<Null> alertLocationService(
  //     BuildContext context, String title, String message) async {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: ListTile(
  //         // leading: ShowImage(path: MyConstants().image4),
  //         title: ShowTitle(
  //           title: title,
  //           textStyle: MyConstants().h2Style(),
  //         ),
  //         subtitle:
  //             ShowTitle(title: message, textStyle: MyConstants().h3Style()),
  //       ),
  //       actions: [
  //         TextButton(
  //             onPressed: () async {
  //               // Navigator.pop(context);
  //               await Geolocator.openLocationSettings();
  //               // exit(0);
  //             },
  //             child: Text('OK'))
  //       ],
  //     ),
  //   );
  // }
}
