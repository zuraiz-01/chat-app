# TODO: Build Flutter Group Chat Screen

## Steps to Complete

- [x] Create lib/providers/group_provider.dart: State management for group data, members, mentions using GetX.
- [x] Create lib/services/group_service.dart: Supabase interactions for group data, members, messages.
- [x] Create lib/screens/chat/group_chat_screen.dart: Full Group Chat Screen with AppBar, Messages area, Message Input Bar, group-specific features (mentions, roles, etc.).
- [x] Update lib/routes/app_routes.dart: Add /groupChat/:groupId route.
- [x] Run flutter pub get (dependencies already in pubspec.yaml).
- [x] Test navigation and UI (run app and navigate to group chat).
- [x] Implement realtime messaging via Supabase Realtime (messages table for group).
- [x] Add typing indicators via Supabase channel for group.
- [x] Implement voice notes and media upload to Supabase Storage.
- [x] Add mentions (@username) with suggestions from group members.
- [x] Handle roles (admin/member) for actions like remove member, pin messages.
- [x] Add mute notifications preference in Supabase.
- [x] Implement unread counts per user for group chats.
- [x] Add pinned messages strip and tap-to-scroll.
- [x] Create media gallery screen (/mediaGallery/:groupId) if needed.
- [x] Handle edge cases: Left group (read-only), no messages (empty state).
- [x] Integrate FCM for push notifications on mentions/new messages.
- [x] Final testing and refinements.
