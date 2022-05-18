class OrderModel {
  String id;
  String orderDateTime;
  String dateTimeSent;
  String idUser;
  String nameUser;
  String idShop;
  String nameShop;
  String distance;
  String transport;
  String idFood;
  String nameFood;
  String price;
  String amount;
  String detail;
  String sum;
  String idRider;
  String status;
  String idGrp;
  String nameGroup;
  String address;
  String addressAround;
  String phone;
  String lat;
  String lng;
  OrderModel(
      {this.id,
      this.orderDateTime,
      this.dateTimeSent,
      this.idUser,
      this.nameUser,
      this.idShop,
      this.nameShop,
      this.distance,
      this.transport,
      this.idFood,
      this.nameFood,
      this.price,
      this.amount,
      this.detail,
      this.sum,
      this.idRider,
      this.status,
      this.idGrp,
      this.nameGroup,
      this.address,
      this.addressAround,
      this.phone,
      this.lat,
      this.lng});

  OrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderDateTime = json['OrderDateTime'];
    dateTimeSent = json['DateTimeSent'];
    idUser = json['idUser'];
    nameUser = json['NameUser'];
    idShop = json['idShop'];
    nameShop = json['NameShop'];
    distance = json['Distance'];
    transport = json['Transport'];
    idFood = json['idFood'];
    nameFood = json['NameFood'];
    price = json['Price'];
    amount = json['Amount'];
    detail = json['Detail'];
    sum = json['Sum'];
    idRider = json['idRider'];
    status = json['Status'];
    idGrp = json['idGrp'];
    phone = json['NameGroup'];
    address = json['Address'];
    addressAround = json['AddressAround'];
    phone = json['Phone'];
    lat = json['Lat'];
    lng = json['Lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['OrderDateTime'] = this.orderDateTime;
    data['DateTimeSent'] = this.dateTimeSent;
    data['idUser'] = this.idUser;
    data['NameUser'] = this.nameUser;
    data['idShop'] = this.idShop;
    data['NameShop'] = this.nameShop;
    data['Distance'] = this.distance;
    data['Transport'] = this.transport;
    data['idFood'] = this.idFood;
    data['NameFood'] = this.nameFood;
    data['Price'] = this.price;
    data['Amount'] = this.amount;
    data['Detail'] = this.detail;
    data['Sum'] = this.sum;
    data['idRider'] = this.idRider;
    data['Status'] = this.status;
    data['idGrp'] = this.idGrp;
    data['NameGroup'] = this.nameGroup;
    data['Address'] = this.address;
    data['AddressAround'] = this.addressAround;
    data['Phone'] = this.phone;
    data['Lat'] = this.lat;
    data['Lng'] = this.lng;

    return data;
  }
}
