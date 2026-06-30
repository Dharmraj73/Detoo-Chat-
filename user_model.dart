class UserModel {
  final String uid;
  final String phoneNumber; // +91 format
  final String name;
  final String? photoUrl;
  final String status;
  final bool isOnline;
  final DateTime lastSeen;

  UserModel({
    required this.uid,
    required this.phoneNumber,
    required this.name,
    this.photoUrl,
    this.status = "Hey there! I am using Detoo",
    this.isOnline = false,
    required this.lastSeen,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      phoneNumber: map['phoneNumber'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'],
      status: map['status'] ?? "Hey there! I am using Detoo",
      isOnline: map['isOnline'] ?? false,
      lastSeen: DateTime.fromMillisecondsSinceEpoch(
        map['lastSeen'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'name': name,
      'photoUrl': photoUrl,
      'status': status,
      'isOnline': isOnline,
      'lastSeen': lastSeen.millisecondsSinceEpoch,
    };
  }
}
