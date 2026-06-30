import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import '../models/chat_model.dart';
import 'chat_screen.dart';
import 'contacts_screen.dart';
import 'new_group_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detoo'),
        backgroundColor: const Color(0xFF128C7E),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'new_group') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NewGroupScreen()));
              } else if (value == 'logout') {
                Provider.of<AuthService>(context, listen: false).signOut();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'new_group', child: Text('Naya Group')),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<ChatModel>>(
        stream: chatService.getUserChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final chats = snapshot.data ?? [];
          if (chats.isEmpty) {
            return const Center(
              child: Text('Koi chat nahi hai. Naya chat shuru karein!'),
            );
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF128C7E),
                  child: Icon(
                    chat.isGroup ? Icons.group : Icons.person,
                    color: Colors.white,
                  ),
                ),
                title: Text(chat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(chat.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Text(
                  DateFormat('hh:mm a').format(chat.lastMessageTime),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        chatId: chat.id,
                        chatName: chat.name,
                        isGroup: chat.isGroup,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF128C7E),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactsScreen()));
        },
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }
}
