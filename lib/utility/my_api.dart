import 'dart:math';

class MyAPI {
  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    double distance = 0;

    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lng2 - lng1) * p)) / 2;
    distance = 12742 * asin(sqrt(a));

    return distance;
  }

  int calculateTransport(double distance) {
    int transport;
    if (distance < 3.0) {
      transport = 10000;
      return transport;
    } else {
      transport = 10000 + (distance - 3).round() * 2000;
      return transport;
    }
  }

  List<String> createStringArray(String string) {
    String resultString = string.substring(1, string.length - 1);
    List<String> list = resultString.split(',');

    int index = 0;
    for (var item in list) {
      list[index] = item.trim();

      index++;
    }
    return list;
  }

  // List<String> createStringArray(String string) {
  //   List<String> list = [];
  //   String myString = string.substring(1, string.length - 1);
  //   // print('myString = $myString');
  //   list = myString.split(',');
  //   int index = 0;
  //   for (var string in list) {
  //     list[index] = string.trim();
  //     index++;
  //   }
  //   // print('list *****=>> $list');
  //   return list;
  // }
}
