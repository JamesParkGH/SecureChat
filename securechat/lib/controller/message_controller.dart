import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:securechat/entities/message.dart';


//used code format from https://www.youtube.com/watch?v=G0rsszX4E9Q

const String USER_COLLECTIONS = 'messages';

class MessageController {
  final db = FirebaseFirestore.instance;

  late final CollectionReference messageref;

  MessageController() {
    messageref = db.collection(USER_COLLECTIONS).withConverter<MessageModel>(
        fromFirestore: (snapshots, _) => MessageModel.fromJson(
              snapshots.data()!,
            ),
        toFirestore: (message, _) => message.toJson());
  }

  Stream<QuerySnapshot> getMessages() {
    return messageref.snapshots();
  }

  void sendMessage(MessageModel message) async {
    messageref.add(message);
  }
}
