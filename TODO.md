# TODO: Fix Supabase Schema and Chat List User Fetching

## Step 1: Update supabase_schema.sql
- [x] Add missing tables: friends, typing_status, call_logs
- [x] Add 'is_read' column to messages table
- [x] Change 'type' to 'is_group' in chats table
- [x] Update RLS policies to allow viewing all profiles for chat list
- [x] Add policies for new tables

## Step 2: Update chat_list_screen.dart
- [x] Ensure loadUsers works with updated policies
- [x] Fix getOrCreateChatRoom to create chats in 'chats' table
- [x] Check for existing private chats
- [x] Add participants properly

## Step 3: Followup
- [x] Apply schema changes to Supabase database
- [x] Test user fetching and chat creation in the app
- [x] Fix infinite recursion in RLS policies

## Step 4: Add Signout Button
- [x] Add signout button to chat list screen app bar
- [x] Implement signout functionality using Supabase auth
- [x] Navigate to auth gate after signout
