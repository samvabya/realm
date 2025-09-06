class PostModel {
  int? idx;
  int? id;
  String? createdAt;
  String? body;
  String? file;
  String? userId;

  PostModel(
      {this.idx, this.id, this.createdAt, this.body, this.file, this.userId});

  PostModel.fromJson(Map<String, dynamic> json) {
    idx = json['idx'];
    id = json['id'];
    createdAt = json['created_at'];
    body = json['body'];
    file = json['file'];
    userId = json['userId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idx'] = idx;
    data['id'] = id;
    data['created_at'] = createdAt;
    data['body'] = body;
    data['file'] = file;
    data['userId'] = userId;
    return data;
  }
}
