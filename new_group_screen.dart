import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({super.key});

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final Set<String> _selectedUserIds = {};

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final chatService = Provider.of<ChatService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Naya Group Banayein'),
        backgroundColor: const Color(0xFF128C7E),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: 'Group ka naam',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Members chunein:', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final users = snapshot.data!.docs.where((doc) => doc.id != currentUid).toList();

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final userData = users[index].data() as Map<String, dynamic>;
                    final userId = users[index].id;
                    final name = userData['name'] ?? 'Unknown';

                    return CheckboxListTile(
                      title: Text(name),
                      value: _selectedUserIds.contains(userId),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedUserIds.add(userId);
                          } else {
                            _selectedUserIds.remove(userId);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF128C7E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  if (_groupNameController.text.trim().isEmpty || _selectedUserIds.length < 2) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Group name aur kam se kam 2 members chunein')),
                    );
                    return;
                  }
                  final chatId = await chatService.createGroupChat(
                    groupName: _groupNameController.text.trim(),
                    participantIds: _selectedUserIds.toList(),
                  );
                  if (!context.mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        chatId: chatId,
                        chatName: _groupNameController.text.trim(),
                        isGroup: true,
                      ),
                    ),
                  );
                },
                child: const Text('Group Banayein'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
