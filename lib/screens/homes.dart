import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:smlao/model/groupfood_model.dart';
import 'package:smlao/model/photo_model.dart';
import 'package:smlao/model/user_model.dart';
import 'package:smlao/utility/my_style.dart';
import 'package:shimmer/shimmer.dart';

class Homes extends StatefulWidget {
  final UserModel userModel;
  Homes({Key key, this.userModel}) : super(key: key);
  @override
  _HomesState createState() => _HomesState();
}

class _HomesState extends State<Homes> {
  List<Widget> widgets = [];
  List<String> nameimage = [
    // 'images/1111.png',
    'images/3333.jpg',
    'images/4444.jpg',
  ];
  List<PhotoModel> photoModels = [];
  PhotoModel photoModel;
  UserModel userModel;
  String idShop;
  int amount = 1;
  double lat1, lng1, lat2, lng2;
  Location location = Location();
  // ignore: deprecated_member_use
  List<GroupFoodModel> groupFoodModels = List();

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    userModel = widget.userModel;
    buildWidgets();
  }

  void buildWidgets() {
    for (var item in nameimage) {
      widgets.add(Image.asset(item));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Wrap(children: <Widget>[
        // buildAddress(),
        buildCarouselSlider(),
        Shimmer.fromColors(
          highlightColor: Colors.white,
          baseColor: Colors.grey[300],
          child: Column(
            children: <Widget>[
              // SizedBox(
              //   height: 8,
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyStyle().showImagess(),
                  MyStyle().mySizeboxs(),
                  MyStyle().showImagess(),
                  MyStyle().mySizeboxs(),
                  MyStyle().showImagess(),
                  MyStyle().mySizeboxs(),
                  MyStyle().showImagess(),
                  MyStyle().mySizeboxs(),
                  MyStyle().showImagess(),
                  MyStyle().mySizeboxs(),
                  MyStyle().showImagess(),
                ],
              )
            ],
          ),
        ),
        ListTile(
          leading: Icon(Icons.fastfood),
          title: Text(' ເລຶອກຮ້ານຄ້າທີໃກ້ບ້ານທ່ານ'),
          // onTap: () {
          //   currentWidget = ShowListShopAll();
          // },
        ),
      ]),
    );
  }

  CarouselSlider buildCarouselSlider() {
    return CarouselSlider(
      items: widgets,
      options: CarouselOptions(
        autoPlay: true,
        autoPlayAnimationDuration: Duration(seconds: 2),
        aspectRatio: 16 / 9,
        enlargeCenterPage: true,
      ),
    );
  }

  Widget buildAddress() {
    return ListView(
      children: [
        CarouselSlider(
          items: [
            //1st Image of Slider
            Container(
              margin: EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: NetworkImage("ADD IMAGE URL HERE"),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            //2nd Image of Slider
            Container(
              margin: EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: NetworkImage("ADD IMAGE URL HERE"),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            //3rd Image of Slider
            Container(
              margin: EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: NetworkImage("ADD IMAGE URL HERE"),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            //4th Image of Slider
            Container(
              margin: EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: NetworkImage("ADD IMAGE URL HERE"),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            //5th Image of Slider
            Container(
              margin: EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: NetworkImage("ADD IMAGE URL HERE"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],

          //Slider Container properties
          options: CarouselOptions(
            height: 180.0,
            enlargeCenterPage: true,
            autoPlay: true,
            aspectRatio: 16 / 9,
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: true,
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            viewportFraction: 0.8,
          ),
        ),
      ],
    );
  }
}
