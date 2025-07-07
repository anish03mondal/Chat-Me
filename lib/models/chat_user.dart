class ChatUser {
  ChatUser({
    required this.about,
    required this.createdAt,
    required this.email,
    required this.id,
    required this.image,
    required this.isOnline,
    required this.lastActive,
    required this.name,
    required this.pushToken,
  });
  late final String about;
  late final String createdAt;
  late final String email;
  late final String id;
  late final String image;
  late final bool isOnline;
  late final String lastActive;
  late final String name;
  late final String pushToken;
  
  // this function will conver .json to dart object
  ChatUser.fromJson(Map<String, dynamic> json){
    about = json['about'] ?? '';
    createdAt = json['created_at'] ?? '';
    email = json['email'] ?? '';
    id = json['id'] ?? '';
    image = json['image'] ?? '';
    isOnline = json['is_online'] ?? '';
    lastActive = json['last_active'] ?? '';
    name = json['name'] ?? '';
    pushToken = json['push_token'] ?? '';
  }

  //this will convert dart object to json data
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['about'] = about;
    data['created_at'] = createdAt;
    data['email'] = email;
    data['id'] = id;
    data['image'] = image;
    data['is_online'] = isOnline;
    data['last_active'] = lastActive;
    data['name'] = name;
    data['push_token'] = pushToken;
    return data;
  }
}