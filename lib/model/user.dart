class UserModel {
  int? idx;
  String? id;
  String? createdAt;
  String? name;
  String? image;
  String? bio;
  String? email;

  UserModel(
      {this.idx,
      this.id,
      this.createdAt,
      this.name,
      this.image,
      this.bio,
      this.email});

  UserModel.fromJson(Map<String, dynamic> json) {
    idx = json['idx'];
    id = json['id'];
    createdAt = json['created_at'];
    name = json['name'];
    image = json['image'];
    bio = json['bio'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idx'] = idx;
    data['id'] = id;
    data['created_at'] = createdAt;
    data['name'] = name;
    data['image'] = image;
    data['bio'] = bio;
    data['email'] = email;
    return data;
  }
}
