import 'package:chat_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _userProvider = Get.find<UserProvider>();
  bool _isEditing = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    if (_userProvider.userProfile.value.isNotEmpty) {
      _usernameController.text = _userProvider.userProfile.value['name'] ?? '';
      _bioController.text = _userProvider.userProfile.value['bio'] ?? '';
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadAvatar() async {
    if (_selectedImage == null) return;

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final fileBytes = await _selectedImage!.readAsBytes();

      // Upload to Supabase Storage (use 'messages' bucket as per existing code)
      await Supabase.instance.client.storage
          .from('messages')
          .uploadBinary(
            fileName,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      // Get public URL
      final avatarUrl = Supabase.instance.client.storage
          .from('messages')
          .getPublicUrl(fileName);

      // Update profile with new avatar URL
      await _userProvider.updateProfile({'avatar_url': avatarUrl});

      setState(() {
        _selectedImage = null;
      });

      Get.snackbar('Success', 'Profile picture updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image: $e');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        actions: [
          if (!_isEditing)
            TextButton(
              onPressed: () => setState(() => _isEditing = true),
              child: const Text('Edit'),
            )
          else
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() => _isEditing = false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    // Upload avatar if selected
                    if (_selectedImage != null) {
                      await _uploadAvatar();
                    }

                    // Update profile info
                    await _userProvider.updateProfile({
                      'name': _usernameController.text,
                      'bio': _bioController.text,
                    });

                    setState(() => _isEditing = false);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            GestureDetector(
              onTap: _isEditing ? _pickImage : null,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (_userProvider.userProfile.value['avatar_url'] !=
                                  null &&
                              _userProvider
                                  .userProfile
                                  .value['avatar_url']
                                  .isNotEmpty)
                        ? NetworkImage(
                            _userProvider.userProfile.value['avatar_url'],
                          )
                        : null,
                    backgroundColor: Colors.blue[100],
                    child:
                        (_selectedImage == null &&
                            (_userProvider.userProfile.value['avatar_url'] ==
                                    null ||
                                _userProvider
                                    .userProfile
                                    .value['avatar_url']
                                    .isEmpty))
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Username
            TextField(
              controller: _usernameController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Bio
            TextField(
              controller: _bioController,
              enabled: _isEditing,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // User Info
            if (!_isEditing)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Account Info',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Status:'),
                          Obx(
                            () => Text(
                              _userProvider.isOnline.value
                                  ? 'Online'
                                  : 'Offline',
                              style: TextStyle(
                                color: _userProvider.isOnline.value
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
