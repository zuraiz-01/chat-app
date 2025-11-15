import 'package:flutter/material.dart';

class CallLogsScreen extends StatefulWidget {
  const CallLogsScreen({Key? key}) : super(key: key);

  @override
  State<CallLogsScreen> createState() => _CallLogsScreenState();
}

class _CallLogsScreenState extends State<CallLogsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calls'), elevation: 0),
      body: const Center(child: Text('No call history yet')),
    );
  }
}
