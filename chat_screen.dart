import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../services/chat_service.dart';
import 'call_screen.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String chatName;
  final bool isGroup;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.chatName,
    required this.isGroup,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  void _sendText() {
    if (_messageController.text.trim().isEmpty) return;
    final chatService = Provider.of<ChatService>(context, listen: false);
    chatService.sendTextMessage(widget.chatId, _messageController.text.trim());
    _messageController.clear();
  }

  Future<void> _pickAndSendImage() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;
    final chatService = Provider.of<ChatService>(context, listen: false);
    await chatService.sendFileMessage(
      chatId: widget.chatId,
      file: File(picked.path),
      fileName: picked.name,
      messageTypeIndex: 1, // image
    );
  }

  Future<void> _pickAndSendFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.single.path == null) return;
    final chatService = Provider.of<ChatService>(context, listen: false);
    final file = File(result.files.single.path!);
    await chatService.sendFileMessage(
      chatId: widget.chatId,
      file: file,
      fileName: result.files.single.name,
      messageTypeIndex: 3, // file
    );
  }

  void _startCall(bool isVideo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          channelName: widget.chatId,
          isVideoCall: isVideo,
          remoteUserName: widget.chatName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context, listen: false);
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chatName),
        backgroundColor: const Color(0xFF128C7E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.call), onPressed: () => _startCall(false)),
          IconButton(icon: const Icon(Icons.videocam), onPressed: () => _startCall(true)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chatService.getChatMessages(widget.chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == currentUid;
                    final type = data['type'] ?? 0;
                    final timestamp = DateTime.fromMillisecondsSinceEpoch(data['timestamp']);

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.isGroup && !isMe)
                              Text(
                                data['senderName'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color(0xFF128C7E),
                                ),
                              ),
                            if (type == 0)
                              Text(data['text'] ?? '')
                            else if (type == 1)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: data['mediaUrl'],
                                  width: 200,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => const CircularProgressIndicator(),
                                ),
                              )
                            else
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.insert_drive_file, size: 20),
                                  const SizedBox(width: 6),
                                  Flexible(child: Text(data['fileName'] ?? 'File')),
                                ],
                              ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('hh:mm a').format(timestamp),
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.attach_file), onPressed: _pickAndSendFile),
                IconButton(icon: const Icon(Icons.photo), onPressed: _pickAndSendImage),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Message likhein...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                CircleAvatar(
                  backgroundColor: const Color(0xFF128C7E),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _sendText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
