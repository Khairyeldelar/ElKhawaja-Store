class CategoryModel {
  String? categoryName;
  String? image;
  CategoryModel({required this.categoryName, required this.image});
  CategoryModel.fromJson(Map<String, dynamic> json)
      : categoryName = json['categoryName'], image = json['image'];
  Map<String, dynamic> toMap() => {
    'categoryName': categoryName, 'image': image,
  };
}
