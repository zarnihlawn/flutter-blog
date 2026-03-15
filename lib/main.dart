import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/message_repository.dart';
import 'screens/messages_home_screen.dart';
import 'state/message_controller.dart';
import 'theme/brutal_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        Provider<MessageRepository>(create: (_) => MessageRepository()),
        ChangeNotifierProvider<MessageController>(
          create: (context) => MessageController(
            repository: context.read<MessageRepository>(),
          )..initialize(),
        ),
      ],
      child: const BlogApp(),
    ),
  );
}

class BlogApp extends StatelessWidget {
  const BlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brutal Blog',
      debugShowCheckedModeBanner: false,
      theme: buildBrutalTheme(),
      home: const MessagesHomeScreen(),
    );
  }
}
