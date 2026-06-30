import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final chatService = Provider.of<ChatService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Naya Chat'),
        backgroundColor: const Color(0xFF128C7E),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Shows all registered Detoo users.
        // In production: cross-reference with user's phone contacts for "WhatsApp-style" contact matching.
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!.docs.where((doc) => doc.id != currentUid).toList();

          if (users.isEmpty) {
            return const Center(child: Text('Koi aur Detoo user nahi mila'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final userId = users[index].id;
              final name = userData['name'] ?? 'Unknown';
              final phone = userData['phoneNumber'] ?? '';

              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF128C7E),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(name),
                subtitle: Text(phone),
                onTap: () async {
                  final chatId = await chatService.getOrCreateOneOnOneChat(userId, name);
                  if (!context.mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(chatId: chatId, chatName: name, isGroup: false),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
