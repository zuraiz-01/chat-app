// ---------------------------------------------------------------------------
// IMPORTS
// ---------------------------------------------------------------------------

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/services/zego_cloud_service.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------------------------------------------------------------------
// CHAT ROOM SCREEN
// ---------------------------------------------------------------------------

class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final bool? isVideoCall;

  const ChatRoomScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    this.isVideoCall,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final FlutterSoundRecorder _rec = FlutterSoundRecorder();
  final ImagePicker _picker = ImagePicker();

  bool _isRecording = false;
  bool _showEmoji = false;
  bool _isTyping = false;

  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _participants = [];

  final _supabase = Supabase.instance.client;
  final ZegoCloudService _zego = ZegoCloudService();

  late RealtimeChannel _msgChannel;
  late RealtimeChannel _typingChannel;

  // ---------------------------------------------------------------------------
  // INIT
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _loadParticipants();
    _loadMessages();
    _listenToMessages(); // FIXED
    _listenToTyping(); // FIXED
    _initCallIfNeeded();
  }

  Future<void> _initRecorder() async {
    await _rec.openRecorder();
  }

  // ---------------------------------------------------------------------------
  // LOAD CHAT PARTICIPANTS
  // ---------------------------------------------------------------------------

  Future<void> _loadParticipants() async {
    try {
      final result = await _supabase
          .from('chat_participants')
          .select('*, profiles(id, username, avatar_url)')
          .eq('chat_id', widget.chatId);

      setState(() => _participants = List<Map<String, dynamic>>.from(result));
    } catch (e) {
      debugPrint('Error loading participants: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // LOAD CHAT MESSAGES
  // ---------------------------------------------------------------------------

  Future<void> _loadMessages() async {
    try {
      final result = await _supabase
          .from('messages')
          .select('*, profiles(id, username, avatar_url)')
          .eq('chat_id', widget.chatId)
          .order('created_at', ascending: true);

      setState(() => _messages = List<Map<String, dynamic>>.from(result));
      _scrollToBottom();
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // REALTIME MESSAGE LISTENER — FULL FIXED
  // ---------------------------------------------------------------------------

  // void _listenToMessages() {
  //   _msgChannel = _supabase.channel(
  //     'public:messages:chat_id=eq.${widget.chatId}', // Listen to messages for a specific chat
  //   );

  //   _msgChannel.onPostgresChanges(
  //     event: PostgresChangeEvent.insert, // Listen for insert events
  //     schema: 'public', // Target schema
  //     table: 'messages', // Target table
  //     callback: (payload) async {
  //       if (!mounted) return;

  //       final data = payload.newRecord;
  //       if (data == null) return;

  //       // Only process if the message belongs to the current chat
  //       if (data['chat_id'] != widget.chatId) return;

  //       final newMsg = Map<String, dynamic>.from(data);

  //       // Attach profile to message (Fetch the sender's profile)
  //       final profile = await _supabase
  //           .from('profiles')
  //           .select()
  //           .eq('id', newMsg['sender_id'])
  //           .maybeSingle();

  //       if (profile != null) {
  //         newMsg['profiles'] = profile;
  //       }

  //       // Update the state with the new message
  //       setState(() {
  //         // _messages.add(newMsg);
  //         _messages.insert(
  //           0,
  //           newMsg,
  //         ); // Add the new message at the start of the list (or use .add() for end)
  //       });

  //       // Scroll to the bottom of the list after adding a new message
  //       _scrollToBottom();
  //     },
  //   );

  //   // Subscribe to the channel to start listening
  //   _msgChannel.subscribe();
  // }
  void _listenToMessages() {
    _msgChannel = _supabase.channel(
      'public:messages:chat_id=eq.${widget.chatId}', // Listen to messages for a specific chat
    );

    _msgChannel.onPostgresChanges(
      event: PostgresChangeEvent.insert, // Listen for insert events
      schema: 'public', // Target schema
      table: 'messages', // Target table
      callback: (payload) async {
        if (!mounted) return;

        final data = payload.newRecord;
        if (data == null) return;

        // Only process if the message belongs to the current chat
        if (data['chat_id'] != widget.chatId) return;

        final newMsg = Map<String, dynamic>.from(data);

        // Attach profile to message (Fetch the sender's profile)
        final profile = await _supabase
            .from('profiles')
            .select()
            .eq('id', newMsg['sender_id'])
            .maybeSingle();

        if (profile != null) {
          newMsg['profiles'] = profile;
        }

        // Update the state with the new message
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _messages.add(newMsg);
              // _messages.insert(
              //   0,
              //   newMsg,
              // ); // Add the new message at the start of the list
            });
            _scrollToBottom(); // Scroll to bottom after adding the new message
          }
        });
      },
    );

    // Subscribe to the channel to start listening
    _msgChannel.subscribe();
  }

  // ---------------------------------------------------------------------------
  // REALTIME TYPING — FIXED & IMPROVED
  // ---------------------------------------------------------------------------

  void _listenToTyping() {
    _typingChannel = _supabase.channel("typing_${widget.chatId}");

    _typingChannel.onBroadcast(
      event: 'typing',
      callback: (payload) {
        if (!mounted) return;
        if (payload['chat_id'] != widget.chatId) return;

        bool isTypingNow = payload['isTyping'] == true;

        setState(() => _isTyping = isTypingNow);

        /// If typing stops, scroll to bottom
        if (!isTypingNow) _scrollToBottom();
      },
    );

    _typingChannel.subscribe();
  }

  void _sendTyping(bool isTyping) async {
    await RefreshLocalizations;
    _typingChannel.sendBroadcastMessage(
      event: 'typing',
      payload: {'chat_id': widget.chatId, 'isTyping': isTyping},
    );
  }

  // ---------------------------------------------------------------------------
  // SEND MESSAGE
  // ---------------------------------------------------------------------------

  Future<void> _sendMessage(String text) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final msg = {
      'chat_id': widget.chatId,
      'sender_id': user.id,
      'content': text,
      'message_type': 'text',
      'media_url': null,
      'is_read': false,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'profiles': {'id': user.id, 'username': user.email, 'avatar_url': null},
    };

    setState(() {
      _messages.add(msg);
      _scrollToBottom();
    });

    _msgCtrl.clear();

    await _supabase.from('messages').insert({
      'chat_id': widget.chatId,
      'sender_id': user.id,
      'content': text,
      'message_type': 'text',
      'media_url': null,
      'is_read': false,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });

    _sendTyping(false);
  }

  // ---------------------------------------------------------------------------
  // SCROLL TO BOTTOM
  // ---------------------------------------------------------------------------

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ---------------------------------------------------------------------------
  // PICK IMAGE
  // ---------------------------------------------------------------------------

  Future<void> _pickImage() async {
    final img = await _picker.pickImage(source: ImageSource.gallery);
    if (img == null) return;

    final file = File(img.path);
    final fileName = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';

    await _supabase.storage.from('media').upload(fileName, file);
    final publicUrl = _supabase.storage.from('media').getPublicUrl(fileName);

    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final msg = {
      'chat_id': widget.chatId,
      'sender_id': user.id,
      'content': null,
      'message_type': 'image',
      'media_url': publicUrl,
      'is_read': false,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'profiles': {'id': user.id, 'username': user.email, 'avatar_url': null},
    };

    setState(() {
      _messages.add(msg);
      _scrollToBottom();
    });

    await _supabase.from('messages').insert(msg);
  }

  // ---------------------------------------------------------------------------
  // VOICE RECORD
  // ---------------------------------------------------------------------------

  Future<void> _startRecording() async {
    await _rec.startRecorder(toFile: 'voice.aac');
    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    final path = await _rec.stopRecorder();
    setState(() => _isRecording = false);

    if (path == null) return;

    final user = _supabase.auth.currentUser!;
    final file = File(path);
    final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _supabase.storage.from('media').upload(fileName, file);
    final url = _supabase.storage.from('media').getPublicUrl(fileName);

    final msg = {
      'chat_id': widget.chatId,
      'sender_id': user.id,
      'content': null,
      'message_type': 'voice',
      'media_url': url,
      'is_read': false,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'profiles': {'id': user.id, 'username': user.email, 'avatar_url': null},
    };

    setState(() {
      _messages.add(msg);
      _scrollToBottom();
    });

    await _supabase.from('messages').insert(msg);
  }

  // ---------------------------------------------------------------------------
  // INIT VIDEO CALL
  // ---------------------------------------------------------------------------

  Future<void> _initCallIfNeeded() async {
    if (widget.isVideoCall == true) {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _zego.initZegoCloud(user.id, user.email ?? "User");
      }
    }
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scroll.dispose();
    _rec.closeRecorder();
    _supabase.removeChannel(_msgChannel);
    _supabase.removeChannel(_typingChannel);
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          if (_showEmoji)
            SizedBox(
              height: 260,
              child: EmojiPicker(
                onEmojiSelected: (cat, emoji) {
                  _msgCtrl.text += emoji.emoji;
                },
              ),
            ),
          _buildInputBar(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(widget.otherUserName),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam),
          onPressed: () {
            Get.toNamed(
              '/chatRoom',
              parameters: {
                'chatId': widget.chatId,
                'otherUserId': widget.otherUserId,
                'otherUserName': widget.otherUserName,
                'isVideoCall': 'true',
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scroll,
      padding: EdgeInsets.all(12.sp),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isTyping && index == _messages.length) {
          return _typingIndicator();
        }
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _typingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: Text("typing...", style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final isMe = msg['sender_id'] == _supabase.auth.currentUser?.id;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.sp),
        padding: EdgeInsets.all(10.sp),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(12.sp),
        ),
        child: _renderMessageContent(msg, isMe),
      ),
    );
  }

  Widget _renderMessageContent(Map<String, dynamic> msg, bool isMe) {
    switch (msg['message_type']) {
      case 'image':
        return CachedNetworkImage(
          imageUrl: msg['media_url'],
          width: 50.w,
          height: 30.h,
          fit: BoxFit.cover,
        );

      case 'voice':
        return IconButton(
          icon: Icon(
            Icons.play_circle,
            size: 26.sp,
            color: isMe ? Colors.white : Colors.black,
          ),
          onPressed: () {},
        );

      default:
        return Text(
          msg['content'] ?? '',
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
            fontSize: 15.sp,
          ),
        );
    }
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(12.sp),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.emoji_emotions),
              onPressed: () {
                setState(() => _showEmoji = !_showEmoji);
              },
            ),
            Expanded(
              child: TextField(
                controller: _msgCtrl,
                onChanged: (val) => _sendTyping(val.isNotEmpty),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: "Message",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22.sp),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: _isRecording ? Colors.red : null,
              ),
              onPressed: _isRecording ? _stopRecording : _startRecording,
            ),
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _pickImage,
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                if (_msgCtrl.text.trim().isNotEmpty) {
                  _sendMessage(_msgCtrl.text.trim());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
