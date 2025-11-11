import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final ImagePicker _picker = ImagePicker();

  bool _isRecording = false;
  bool _showEmojiPicker = false;
  bool _isTyping = false; // Simulate typing indicator
  List<Map<String, dynamic>> _messages = []; // Mock messages

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _loadMessages();
    _setupRealtime();
  }

  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
  }

  void _loadMessages() {
    // Mock data
    _messages = [
      {
        'id': 1,
        'sender': 'friend',
        'message': 'Hey there!',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
        'type': 'text',
      },
      {
        'id': 2,
        'sender': 'me',
        'message': 'Hi! How are you?',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 3)),
        'type': 'text',
      },
    ];
  }

  void _setupRealtime() {
    // Supabase realtime for messages and typing
    Supabase.instance.client
        .channel('messages')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            // Handle new message
            setState(() {
              _messages.add(payload.newRecord);
            });
          },
        )
        .subscribe();

    Supabase.instance.client
        .channel('typing')
        .onBroadcast(
          event: 'typing',
          callback: (payload) {
            setState(() {
              _isTyping = payload['isTyping'];
            });
          },
        )
        .subscribe();
  }

  void _sendMessage(String message, {String type = 'text'}) {
    final newMessage = {
      'sender': 'me',
      'message': message,
      'timestamp': DateTime.now(),
      'type': type,
    };
    setState(() {
      _messages.add(newMessage);
    });
    // Insert to Supabase
    Supabase.instance.client.from('messages').insert(newMessage);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Upload to Supabase Storage and send message
      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(image.path);
      await Supabase.instance.client.storage
          .from('media')
          .upload(fileName, file);
      final url = Supabase.instance.client.storage
          .from('media')
          .getPublicUrl(fileName);
      _sendMessage(url, type: 'image');
    }
  }

  Future<void> _startRecording() async {
    await _recorder.startRecorder(toFile: 'voice.aac');
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });
    if (path != null) {
      // Upload voice note
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.aac';
      final file = File(path);
      await Supabase.instance.client.storage
          .from('media')
          .upload(fileName, file);
      final url = Supabase.instance.client.storage
          .from('media')
          .getPublicUrl(fileName);
      _sendMessage(url, type: 'voice');
    }
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18.sp,
                  backgroundImage: const AssetImage('assets/logo.png'),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10.sp,
                    height: 10.sp,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 8.sp),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Friend Name',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text(
                  'Online',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call, size: 20.sp),
            onPressed: () => Get.toNamed('/call/audio/1'), // Assume userId 1
          ),
          IconButton(
            icon: Icon(Icons.videocam, size: 20.sp),
            onPressed: () => Get.toNamed('/call/video/1'),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle menu actions
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'block', child: Text('Block')),
              const PopupMenuItem(value: 'report', child: Text('Report')),
              const PopupMenuItem(value: 'clear', child: Text('Clear Chat')),
            ],
            icon: Icon(Icons.more_vert, size: 20.sp),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF5F5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Text(
                        'Say hi 👋',
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: EdgeInsets.all(12.sp),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_isTyping && index == 0) {
                          return _buildTypingIndicator();
                        }
                        final message = _messages[_messages.length - 1 - index];
                        return _buildMessageBubble(message);
                      },
                    ),
            ),
            if (_showEmojiPicker)
              SizedBox(
                height: 250.sp,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    _messageController.text += emoji.emoji;
                  },
                ),
              ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.sp),
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(18.sp),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'typing...',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
            SizedBox(width: 8.sp),
            SizedBox(
              width: 20.sp,
              height: 10.sp,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, i) =>
                    Container(
                          width: 4.sp,
                          height: 4.sp,
                          margin: EdgeInsets.symmetric(horizontal: 1.sp),
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .fadeIn(
                          duration: 500.ms,
                          delay: Duration(milliseconds: i * 200),
                        )
                        .fadeOut(duration: 500.ms),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['sender'] == 'me';
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.sp),
        padding: EdgeInsets.all(12.sp),
        constraints: BoxConstraints(maxWidth: 70.w),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.sp),
            topRight: Radius.circular(18.sp),
            bottomLeft: isMe ? Radius.circular(18.sp) : Radius.zero,
            bottomRight: isMe ? Radius.zero : Radius.circular(18.sp),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4.sp,
              offset: Offset(0, 2.sp),
            ),
          ],
        ),
        child: message['type'] == 'text'
            ? Text(
                message['message'] ?? '',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isMe ? Colors.white : Colors.black,
                ),
              )
            : message['type'] == 'image'
            ? CachedNetworkImage(
                imageUrl: message['message'] ?? '',
                width: 200.sp,
                height: 200.sp,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )
            : IconButton(
                icon: Icon(Icons.play_arrow, size: 30.sp),
                onPressed: () {
                  // Play voice note
                },
              ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(12.sp),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.emoji_emotions, size: 20.sp),
              onPressed: _toggleEmojiPicker,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.sp),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.sp,
                    vertical: 10.sp,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                size: 20.sp,
                color: _isRecording ? Colors.red : null,
              ),
              onPressed: _isRecording ? _stopRecording : _startRecording,
              onLongPress: _startRecording,
            ),
            IconButton(
              icon: Icon(Icons.attach_file, size: 20.sp),
              onPressed: _pickImage,
            ),
            IconButton(
              icon: Icon(Icons.send, size: 20.sp),
              onPressed: () {
                if (_messageController.text.isNotEmpty) {
                  _sendMessage(_messageController.text);
                  _messageController.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
