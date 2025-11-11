# TODO: Build Friends / Contacts Screen

## Step 1: Add missing packages to pubspec.yaml
- Add flutter_slidable and pull_to_refresh dependencies.
- ✅ Done

## Step 2: Create UserProvider
- Create lib/providers/user_provider.dart for current user data (name, avatar, etc.).
- ✅ Done

## Step 3: Create FriendProvider
- Create lib/providers/friend_provider.dart with friends, online friends, requests, suggestions, realtime updates via Supabase.
- ✅ Done

## Step 4: Add /otherProfile/:userId route and screen
- Add route in app_routes.dart.
- Create lib/screens/profile/other_profile_screen.dart.
- ✅ Done

## Step 5: Update SearchScreen
- Update lib/screens/search/search_screen.dart to handle searching users and sending friend requests.
- ✅ Done

## Step 6: Implement FriendsScreen
- Fully implement lib/screens/friends/friends_screen.dart with AppBar, Tabs, Lists, FAB, BottomNav, etc.
- Include empty states, context menus, realtime updates.
- ✅ Done

## Step 7: Test and verify
- Run the app, check UI, realtime, notifications.
- TODO: Test the implementation
