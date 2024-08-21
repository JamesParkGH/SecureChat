// import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securechat/Screens/message_screen.dart';
import 'package:securechat/controller/user_controller.dart';
import 'package:securechat/entities/user.dart';
import 'package:securechat/services/auth/auth_manager.dart';

//used code format from https://www.youtube.com/watch?v=G0rsszX4E9Q
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final userController = UserController();

  bool isOutOfOffice = false;

  void signOut() {
    final authService = Provider.of<AuthManager>(context, listen: false);
    authService.signOut();
  }

  //https://stackoverflow.com/questions/68494359/type-jsonquerysnapshot-is-not-a-subtype-of-type-mapstring-dynamic-in-typ
  Future<void> outOfOfficeState() async {
    String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    try {
      UserModel updatedUser = UserModel(
        email: currentUserEmail ?? '',
        isOutOfOffice: isOutOfOffice,
      );
      //https://firebase.flutter.dev/docs/firestore/usage
      final userref = FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: currentUserEmail)
          .limit(1)
          .get()
          .then((snapshot) =>
              {snapshot.docs.first.reference.update(updatedUser.toJson())});
              
    } on Exception catch (e) {
      print('ERROR!!!!!!');
    }
  }

  Widget buildUserList() {
    return SafeArea(
      child: Column(
        children: [
          userListView(),
        ],
      ),
    );
  }

  Widget userListView() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder(
        stream: userController.getUsers(),
        builder: (context, snapshot) {
          List users = snapshot.data?.docs ?? [];
          String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;

          if (users.isEmpty) {
            return const Center(
              child: Text("NO ONE IS IN YOUR COMPANY"),
            );
          }

          // Filter out the current user from the list
          List<UserModel> otherUsers = users
              .map((userDoc) => userDoc.data() as UserModel)
              .where((user) => user.email != currentUserEmail)
              .toList();

          if (otherUsers.isEmpty) {
            return const Center(
              child: Text("NO ONE ELSE IS IN YOUR COMPANY"),
            );
          }
          print(users);
          return ListView.builder(
            itemCount: otherUsers.length,
            itemBuilder: (context, index) {
              UserModel user = otherUsers[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                //adapted from Jack re imagined by pranav
                child: ListTile(
                  selectedTileColor: Color.fromARGB(255, 255, 255, 255),
                  leading: CircleAvatar(child: Text(user.email[0])),
                  title: Text(user.email),
                  enableFeedback: true,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return MessageScreen(recipient: user.email);
                    }));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        title: const Text("Home Screen"),
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        foregroundColor: Color.fromARGB(255, 255, 255, 255),
        titleTextStyle: TextStyle(fontFamily: 'Orbitron', fontSize: 25),
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Column(
        children: [
          Row(
            // Add the new row for the Switch widget
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Out of Office', style: TextStyle(fontSize: 18.0)),
              Switch(
                value: isOutOfOffice,
                activeColor: Color.fromARGB(255, 33, 33, 32),
                onChanged: (value) => setState(() {
                  isOutOfOffice = value;
                  outOfOfficeState();
                }),
              ),
            ],
          ),
          buildUserList()
        ],
      ),
    );
  }
}
