class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String image;
  const UserModel({required this.uid, required this.name,
    required this.email, this.phone = '', this.image = ''});
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    uid: (json['uid'] ?? '').toString(),
    name: (json['name'] ?? '').toString(),
    email: (json['email'] ?? '').toString(),
    phone: (json['phone'] ?? '').toString(),
    image: (json['image'] ?? '').toString(),
  );
  Map<String, dynamic> toMap() => {
    'uid': uid, 'name': name, 'email': email,
    'phone': phone, 'image': image,
  };
}
