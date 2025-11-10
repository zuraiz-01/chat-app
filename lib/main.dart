import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://vfvvoxumctiaugtqfkbq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZmdnZveHVtY3RpYXVndHFma2JxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI3NzgxODAsImV4cCI6MjA3ODM1NDE4MH0.1WnKWMkfJRAKqKZsgGreOd3pMs0YOe6Xq8zpKH50sv8',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Text('Hello Chat App!'), // Placeholder for now
    );
  }
}
