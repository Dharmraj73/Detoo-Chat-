import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_model.dart';

class ChatService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  /// Get or create a 1-on-1 chat between current user and another user
  Future<String> getOrCreateOneOnOneChat(String otherUserId, String otherUserName) async {
    final currentUid = _auth.currentUser!.uid;
    final chatId = _generateChatId(currentUid, otherUserId);

    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    if (!chatDoc.exists) {
      await _firestore.collection('chats').doc(chatId).set({
        'name': otherUserName,
        'isGroup': false,
        'participants': [currentUid, otherUserId],
        'lastMessage': '',
        'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
      });
    }
    return chatId;
  }

  String _generateChatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// Create a new group chat
  Future<String> createGroupChat({
    required String groupName,
    required List<String> participantIds,
    String? groupPhotoUrl,
  }) async {
    final currentUid = _auth.currentUser!.uid;
    participantIds.add(currentUid);

    final docRef = await _firestore.collection('chats').add({
      'name': groupName,
      'isGroup': true,
      'participants': participantIds,
      'lastMessage': 'Group bana diya gaya',
      'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
      'groupPhotoUrl': groupPhotoUrl,
      'createdBy': currentUid,
    });
    return docRef.id;
  }

  /// Send a text message
  Future<void> sendTextMessage(String chatId, String text) async {
    final user = _auth.currentUser!;
    final messageId = _uuid.v4();

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .set({
      'senderId': user.uid,
      'senderName': user.displayName ?? '',
      'text': text,
      'type': 0, // text
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'isRead': false,
    });

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Upload and send a file/photo/video message
  Future<void> sendFileMessage({
    required String chatId,
    required File file,
    required String fileName,
    required int messageTypeIndex, // 1=image, 2=video, 3=file
  }) async {
    final user = _auth.currentUser!;
    final messageId = _uuid.v4();

    final ref = _storage.ref().child('chat_files/$chatId/$messageId-$fileName');
    final uploadTask = await ref.putFile(file);
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .set({
      'senderId': user.uid,
      'senderName': user.displayName ?? '',
      'text': '',
      'type': messageTypeIndex,
      'mediaUrl': downloadUrl,
      'fileName': fileName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'isRead': false,
    });

    final lastMsgLabel = messageTypeIndex == 1
        ? '📷 Photo'
        : messageTypeIndex == 2
            ? '🎥 Video'
            : '📎 File';

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': lastMsgLabel,
      'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Stream of all chats for current user (inbox list)
  Stream<List<ChatModel>> getUserChats() {
    final currentUid = _auth.currentUser!.uid;
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Stream of messages within a chat
  Stream<QuerySnapshot> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
