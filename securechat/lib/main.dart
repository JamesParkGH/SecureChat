import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:securechat/Screens/splash_screen.dart';
import 'package:securechat/controller/auth_controller.dart';
import 'package:securechat/services/auth/auth_manager.dart';
import 'firebase_options.dart';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(ChangeNotifierProvider(
      create: (context) => AuthManager(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Theme.of(context).colorScheme.background,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
        ),
        body: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: SizedBox(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Sign In', style: TextStyle(fontSize: 32)),
              ),
              const Text('with your employee email'),
              const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: TextField(
                      decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ))),
              const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ))),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FilledButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ContactsPage();
                        }));
                      },
                      child: const Text('Login')),
                ),
              ),
            ],
          ),
        )));
  }
}

class ContactsPage extends StatelessWidget {
  var messages = [
    'Alphonso',
    'Jeff',
    'Rodney',
    'Bob',
    'Donald',
    'Trevor',
    'Jolene',
    'Kate'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Theme.of(context).colorScheme.background,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: const Text('Messages'),
        ),
        body: ListView(children: <Widget>[
          for (var msg in messages) ...{
            ListTile(
              leading: CircleAvatar(child: Text(msg.characters.first)),
              trailing: Text('${Random().nextInt(5) + 2} days ago'),
              title: Text(msg),
              subtitle: Text('${Random().nextInt(10) + 1} unread messages'),
              enableFeedback: true,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return MessagePage(recipient: msg);
                }));
              },
            ),
            // Divider(),
          }
        ]));
  }
}

class Message {
  /// Text of the message
  String text;

  /// Whether the message was sent by us or recieved from the other person
  bool sent;
  Message(this.text, this.sent);
}

class MessagePage extends StatefulWidget {
  final String recipient;
  const MessagePage({
    required this.recipient,
  });

  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  List<Message> messages = [
    Message('yeah dog', true),
    Message('yeah I love 3a04', false),
    Message('yeah dog i agree', true),
    Message('awesome', true),
  ];

  // Apparently we need to use this just to clear the text field on submit lol
  final messageTextController = TextEditingController();

  void sendMessage(msg) {
    setState(() {
      messages.add(Message(msg, true));
    });
    messageTextController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.background,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.recipient),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              reverse: true,
              children: <Widget>[
                for (var msg in messages) ...{
                  Align(
                      alignment: msg.sent
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 200),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(msg.text),
                          ),
                        ),
                      ))
                }
              ].reversed.toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: messageTextController,
              // onEditingComplete: () {}, // Stops the keyboard from closing
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  hintText: 'Text message',
                  contentPadding: const EdgeInsets.all(12)),
              onSubmitted: sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
