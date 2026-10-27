class ProductModel {
  String? productId;
  List<dynamic>? images;
  String? title;
  String? price;
  String? category;
  String? currency;
  String? description;
  String? countryName;
  String? countryCode;
  String? phoneNumber;
  String? uid;
  String? dateTime;

  ProductModel({this.productId, this.images, this.title, this.price,
    this.category, this.currency, this.description, this.countryName,
    this.countryCode, this.phoneNumber, this.uid, this.dateTime});

  ProductModel.fromJson(Map<String, dynamic> json)
      : productId = json['productId'],
        images = json['images'] is List ? json['images'] : [],
        title = json['title'],
        price = json['price']?.toString(),
        category = json['category'],
        currency = json['currency'],
        description = json['description'],
        countryName = json['countryName'],
        countryCode = json['countryCode'],
        phoneNumber = json['phoneNumber'],
        uid = json['uid'],
        dateTime = json['dateTime'];

  Map<String, dynamic> toMap() => {
    'productId': productId, 'images': images, 'title': title,
    'price': price, 'category': category, 'currency': currency,
    'description': description, 'countryName': countryName,
    'countryCode': countryCode, 'phoneNumber': phoneNumber,
    'uid': uid, 'dateTime': dateTime,
  };
}
