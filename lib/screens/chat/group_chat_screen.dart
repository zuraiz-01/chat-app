import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/providers/group_provider.dart';
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

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  const GroupChatScreen({super.key, required this.groupId});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final ImagePicker _picker = ImagePicker();

  late GroupProvider groupProvider;
  bool _isRecording = false;
  bool _showEmojiPicker = false;
  bool _showMentionSuggestions = false;
  String _mentionQuery = '';
  List<String> _mentionSuggestions = [];

  @override
  void initState() {
    super.initState();
    groupProvider = Get.put(GroupProvider(widget.groupId), tag: widget.groupId);
    _initRecorder();
    _setupMessageListener();
  }

  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
  }

  void _setupMessageListener() {
    _messageController.addListener(() {
      final text = _messageController.text;
      if (text.endsWith('@')) {
        setState(() {
          _showMentionSuggestions = true;
          _mentionQuery = '';
        });
        _mentionSuggestions = groupProvider.getMentionSuggestions('');
      } else if (_showMentionSuggestions && text.contains('@')) {
        final lastAtIndex = text.lastIndexOf('@');
        _mentionQuery = text.substring(lastAtIndex + 1);
        _mentionSuggestions = groupProvider.getMentionSuggestions(
          _mentionQuery,
        );
      } else {
        setState(() {
          _showMentionSuggestions = false;
        });
      }
    });
  }

  void _sendMessage(
    String message, {
    String type = 'text',
    List<String> mentions = const [],
  }) {
    if (message.trim().isEmpty) return;
    groupProvider.sendMessage(message, type: type, mentions: mentions);
    _messageController.clear();
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
      final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(image.path);
      await Supabase.instance.client.storage
          .from('group_media')
          .upload(fileName, file);
      final url = Supabase.instance.client.storage
          .from('group_media')
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
      final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.aac';
      final file = File(path);
      await Supabase.instance.client.storage
          .from('group_media')
          .upload(fileName, file);
      final url = Supabase.instance.client.storage
          .from('group_media')
          .getPublicUrl(fileName);
      _sendMessage(url, type: 'voice');
    }
  }

  void _toggleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });
  }

  void _onMentionSelected(String name) {
    final text = _messageController.text;
    final lastAtIndex = text.lastIndexOf('@');
    final newText = text.substring(0, lastAtIndex) + '@$name ';
    _messageController.text = newText;
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: newText.length),
    );
    setState(() {
      _showMentionSuggestions = false;
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
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF5F5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Obx(() {
          if (groupProvider.hasLeftGroup.value) {
            return _buildLeftGroupView();
          }
          return Column(
            children: [
              if (groupProvider.pinnedMessages.isNotEmpty)
                _buildPinnedMessagesStrip(),
              Expanded(
                child: groupProvider.messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: EdgeInsets.all(12.sp),
                        itemCount:
                            groupProvider.messages.length +
                            (groupProvider.typingUsers.isNotEmpty ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (groupProvider.typingUsers.isNotEmpty &&
                              index == 0) {
                            return _buildTypingIndicator();
                          }
                          final message =
                              groupProvider.messages[groupProvider
                                      .messages
                                      .length -
                                  1 -
                                  index];
                          return _buildMessageBubble(message);
                        },
                      ),
              ),
              if (_showEmojiPicker) _buildEmojiPicker(),
              if (_showMentionSuggestions) _buildMentionSuggestions(),
              _buildMessageInput(),
            ],
          );
        }),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, size: 20.sp),
        onPressed: () => Get.back(),
      ),
      title: Obx(() {
        final group = groupProvider.groupInfo;
        final members = groupProvider.members;
        return Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18.sp,
                  backgroundImage: AssetImage(
                    group['avatar'] ?? 'assets/logo.png',
                  ),
                ),
                // Stacked avatars for group
                if (members.length > 1)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 8.sp,
                      backgroundImage: AssetImage(
                        members[1]['avatar'] ?? 'assets/logo.png',
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
                  group['name'] ?? 'Group',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text(
                  '${members.length} members',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
          ],
        );
      }),
      actions: [
        IconButton(
          icon: Icon(Icons.group, size: 20.sp),
          onPressed: () => Get.toNamed('/groupMembers/${widget.groupId}'),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'leave':
                groupProvider.leaveGroup();
                break;
              case 'mute':
                groupProvider.toggleMute();
                break;
              case 'invite':
                // Invite logic
                break;
              case 'edit':
                // Edit group logic
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit Group')),
            const PopupMenuItem(value: 'invite', child: Text('Invite')),
            const PopupMenuItem(
              value: 'mute',
              child: Text('Mute Notifications'),
            ),
            const PopupMenuItem(value: 'leave', child: Text('Leave Group')),
          ],
          icon: Icon(Icons.more_vert, size: 20.sp),
        ),
      ],
    );
  }

  Widget _buildPinnedMessagesStrip() {
    return Container(
      padding: EdgeInsets.all(8.sp),
      color: Colors.yellow[100],
      child: Row(
        children: [
          Icon(Icons.push_pin, size: 16.sp),
          SizedBox(width: 8.sp),
          Expanded(
            child: Text(
              groupProvider.pinnedMessages
                  .map((m) => m['message'] ?? '')
                  .join(' | '),
              style: TextStyle(fontSize: 12.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 16.sp),
            onPressed: () => groupProvider.pinnedMessages.clear(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'Start the conversation',
        style: TextStyle(fontSize: 16.sp, color: Colors.grey),
      ),
    );
  }

  Widget _buildLeftGroupView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'You have left this group.',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
          SizedBox(height: 16.sp),
          ElevatedButton(
            onPressed: () {
              // Rejoin logic
            },
            child: const Text('Rejoin Group'),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    final typingText = groupProvider.typingUsers.length == 1
        ? '${groupProvider.typingUsers[0]} is typing...'
        : '${groupProvider.typingUsers.join(' and ')} are typing...';
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
              typingText,
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
    final isMe =
        message['senderId'] == Supabase.instance.client.auth.currentUser!.id;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                message['senderName'] ?? 'Unknown',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            SizedBox(height: 4.sp),
            message['type'] == 'text'
                ? _buildTextMessage(
                    message['message'] ?? '',
                    (message['mentions'] as List<dynamic>?)?.cast<String>() ??
                        [],
                  )
                : message['type'] == 'image'
                ? CachedNetworkImage(
                    imageUrl: message['message'] ?? '',
                    width: 200.sp,
                    height: 200.sp,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  )
                : IconButton(
                    icon: Icon(Icons.play_arrow, size: 30.sp),
                    onPressed: () {
                      // Play voice note
                    },
                  ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildTextMessage(String text, List<String> mentions) {
    // Simple mention highlighting
    return Text(
      text,
      style: TextStyle(fontSize: 14.sp, color: Colors.black),
    );
  }

  Widget _buildEmojiPicker() {
    return SizedBox(
      height: 250.sp,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          _messageController.text += emoji.emoji;
        },
      ),
    );
  }

  Widget _buildMentionSuggestions() {
    return Container(
      constraints: BoxConstraints(maxHeight: 150.sp),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _mentionSuggestions.length,
        itemBuilder: (context, index) {
          final name = _mentionSuggestions[index];
          return ListTile(
            title: Text(name),
            onTap: () => _onMentionSelected(name),
          );
        },
      ),
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
                  final mentions = _extractMentions(_messageController.text);
                  _sendMessage(_messageController.text, mentions: mentions);
                }
              },
              onLongPress: () {
                // Quick actions: mention, etc.
              },
            ),
          ],
        ),
      ),
    );
  }

  List<String> _extractMentions(String text) {
    final mentionRegex = RegExp(r'@(\w+)');
    return mentionRegex
        .allMatches(text)
        .map((m) => m.group(1)!)
        .toList()
        .cast<String>();
  }
}
