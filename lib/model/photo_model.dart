class PhotoModel {
  String id;
  String nameimage;
  String image;

  PhotoModel({
    this.id,
    this.image,
    this.nameimage,
  });

  PhotoModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['nameimage'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nameimage'] = this.nameimage;
    data['image'] = this.image;
    return data;
  }
}
