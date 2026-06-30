enum MessageType { text, image, video, file, voice }

class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final MessageType type;
  final String? mediaUrl;
  final String? fileName;
  final DateTime timestamp;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.type = MessageType.text,
    this.mediaUrl,
    this.fileName,
    required this.timestamp,
    this.isRead = false,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      text: map['text'] ?? '',
      type: MessageType.values[map['type'] ?? 0],
      mediaUrl: map['mediaUrl'],
      fileName: map['fileName'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'type': type.index,
      'mediaUrl': mediaUrl,
      'fileName': fileName,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
    };
  }
}

class ChatModel {
  final String id;
  final String name; // group name or other user's name
  final bool isGroup;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String? groupPhotoUrl;
  final String? createdBy;

  ChatModel({
    required this.id,
    required this.name,
    required this.isGroup,
    required this.participants,
    this.lastMessage = '',
    required this.lastMessageTime,
    this.groupPhotoUrl,
    this.createdBy,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatModel(
      id: id,
      name: map['name'] ?? '',
      isGroup: map['isGroup'] ?? false,
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: DateTime.fromMillisecondsSinceEpoch(
        map['lastMessageTime'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      groupPhotoUrl: map['groupPhotoUrl'],
      createdBy: map['createdBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isGroup': isGroup,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
      'groupPhotoUrl': groupPhotoUrl,
      'createdBy': createdBy,
    };
  }
}
