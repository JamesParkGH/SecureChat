// import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securechat/controller/message_controller.dart';
import 'package:securechat/controller/user_controller.dart';
import 'package:securechat/entities/message.dart';
import 'package:securechat/entities/user.dart';
import 'package:securechat/services/KDC.dart';
import 'package:securechat/services/auth/auth_manager.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
//used code format from https://www.youtube.com/watch?v=G0rsszX4E9Q

class MessageScreen extends StatefulWidget {
  final String recipient;

  const MessageScreen({required this.recipient});

  @override
  State<MessageScreen> createState() => _MessageScreenState(this.recipient);
}

class _MessageScreenState extends State<MessageScreen> {
  final String recipient;
  final messageController = MessageController();
  final inputTextController = TextEditingController();

  _MessageScreenState(this.recipient);

  //message controller

  void signOut() {
    final authService = Provider.of<AuthManager>(context, listen: false);
    authService.signOut();
  }

  //encrypt
  Future<String> encrypting(
      String theMessage, String sender, String reciever) async {
    Future<String> futurekey = KDC().getKey(sender, reciever);
    debugPrint('hi!');
    String key = await futurekey;

    final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromUtf8(key),
        mode: encrypt.AESMode.ecb, padding: 'PKCS7'));
    final encrypted = encrypter.encrypt(theMessage);
    return encrypted.base64;
  }

  Future<String> decrypting(
      String encryptedMessage, String sender, String reciever) async {
    Future<String> futurekey = KDC().getKey(sender, reciever);

    String key = await futurekey;
    final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromUtf8(key),
        mode: encrypt.AESMode.ecb, padding: 'PKCS7'));
    final decrypted =
        encrypter.decrypt(encrypt.Encrypted.fromBase64(encryptedMessage));
    debugPrint("decrypted thing is: $decrypted");
    return decrypted;
  }

  void sendMessage(String theMessage) async {
    String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    String recipient = this.recipient;

    if (currentUserEmail != null && recipient != null) {
      MessageModel message = MessageModel(
          sender: currentUserEmail,
          receipient: recipient,
          message: await encrypting(theMessage, currentUserEmail, recipient),
          date: DateTime.now());
      messageController.sendMessage(message);

      MessageModel ooo = MessageModel(
          sender: recipient,
          receipient: currentUserEmail,
          message: await encrypting(
              'I am out of office', currentUserEmail, recipient),
          date: DateTime.now());
      //see readme
      final userref = FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: recipient)
          .limit(1)
          .get()
          .then((snapshot) => {
                if (UserModel.fromJson(
                        snapshot.docs.first.data() as Map<String, dynamic>)
                    .isOutOfOffice)
                  {
                        messageController.sendMessage(ooo)

                  }else{
                    print('FALSEEEEEEEEEEEEEEEEEEEEEEEEEEE')
                  }
              });
    } else {
      print("you're not even logged in");
    }
  }

  Future<List<MessageModel>> decryptMyMessages(
      List<MessageModel> messages) async {
    if (messages.isEmpty) {
      return [];
    }
    List<MessageModel> decryptedMessages = [];

    for (int i = 0; i < messages.length; i++) {
      MessageModel cMessage = messages[i];

      decryptedMessages.add(MessageModel(
          sender: cMessage.sender,
          receipient: cMessage.receipient,
          message: await decrypting(
              cMessage.message, cMessage.sender, cMessage.receipient),
          date: cMessage.date));
    }

    return decryptedMessages;
  }

  void organizeMessages(List<MessageModel> messages) {
    messages.sort((a, b) => a.date.compareTo(b.date));
  }

  Future<Widget> displayMessages() async {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder(
        stream: messageController.getMessages(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          List messages = snapshot.data?.docs ?? [];

          String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;

          if (messages.isEmpty) {
            return const Center(
              child: Text("You guys haven't talked lol"),
            );
          } else {
            for (MessageModel m in messages
                .map((messageDoc) => messageDoc.data() as MessageModel)
                .toList()) {
              print(m.sender + ' ' + m.receipient + ' ' + m.message);
            }
          }

          List<MessageModel> otherMessages = messages
              .map((messageDoc) => messageDoc.data() as MessageModel)
              .where((message) =>
                  (message.sender == currentUserEmail &&
                      message.receipient == this.recipient) ||
                  (message.receipient == currentUserEmail &&
                      message.sender == this.recipient))
              .toList();

          if (otherMessages.isEmpty) {
            return const Center(
              child: Text("you guys haven't talked lolol"),
            );
          }

          return FutureBuilder<List<MessageModel>>(
            future: decryptMyMessages(otherMessages),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<MessageModel> decrypted = snapshot.data!;
                organizeMessages(decrypted);
                return ListView.builder(
                  itemCount: decrypted.length,
                  itemBuilder: (context, index) {
                    MessageModel message = decrypted[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 5),
                      //Jack Created template pranav edited
                      child: Align(
                          alignment: message.sender == currentUserEmail
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            color: message.sender == currentUserEmail
                                ? Color.fromARGB(255, 184, 211, 255)
                                : Color.fromARGB(255, 242, 162, 200),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 200),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  message.message,
                                  style: const TextStyle(fontSize: 24.0),
                                ),
                              ),
                            ),
                          )),
                    );
                  },
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          );
        },
      ),
    );
  }

  //UI Adapted from: https://www.freecodecamp.org/news/build-a-chat-app-ui-with-flutter/
  //And https://www.youtube.com/watch?v=G0rsszX4E9Q
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.recipient),
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          //start
          FutureBuilder<Widget>(
            future: displayMessages(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (!snapshot.hasData) {
                return Center(
                    child: CircularProgressIndicator()); // Loading indicator
              }

              return snapshot.data!; // Build the UI with messages
            },
          ),
          //end

          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  // SizedBox(
                  //   width: 15,
                  // ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                      controller: inputTextController,
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      String text = inputTextController.text;
                      inputTextController.text = '';

                      sendMessage(text);
                    },
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                    backgroundColor: Colors.black,
                    elevation: 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
