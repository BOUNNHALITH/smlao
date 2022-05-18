import 'package:flutter/material.dart';
import 'package:smlao/providers/amount_cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:smlao/screens/splashPage.dart';

main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static String title;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) {
              return AmountCartProvider();
            },
          )
        ],
        child: MaterialApp(
          title: 'SMLAO',
          theme: ThemeData(
              primarySwatch: Colors.green,
              fontFamily: 'NotoSerifLao',
              visualDensity: VisualDensity.adaptivePlatformDensity),
          home: SplashPage(),
          // home: SendAdress(),
          debugShowCheckedModeBanner: false,
        ));
  }
}
