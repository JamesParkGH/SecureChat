import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:securechat/entities/user.dart';

//used code format from https://www.youtube.com/watch?v=G0rsszX4E9Q

const String USER_COLLECTIONS = 'users';

class UserController {
  final db = FirebaseFirestore.instance;

  late final CollectionReference userref;

  UserController() {
    userref = db.collection(USER_COLLECTIONS).withConverter<UserModel>(
        fromFirestore: (snapshots, _) => UserModel.fromJson(
              snapshots.data()!,
            ),
        toFirestore: (user, _) => user.toJson());
  }

  Stream<QuerySnapshot> getUsers() {
    return userref.snapshots();
  }

  void addUser(UserModel user) async {
    userref.add(user);
  }

  void updateUser(String userId, UserModel updatedUser) {
    userref.doc(userId).update(updatedUser.toJson());
  }
}
