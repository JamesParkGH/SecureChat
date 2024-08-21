//used code format from https://www.youtube.com/watch?v=G0rsszX4E9Q
class MessageModel {
  final String sender;
  final String receipient;
  final String message;
  final DateTime date;
  const MessageModel(
      {required this.sender, required this.receipient, required this.message, required this.date});

  MessageModel.fromJson(Map<String, Object?> json)
      : this(
          sender: json['sender'] as String,
          receipient: json['recipient'] as String,
          message: json['message'] as String,
          date: DateTime.parse(json['date'] as String)
        );

  toJson() {
    return {
      "sender": sender,
      "recipient": receipient,
      "message": message,
      "date" : date.toString()
    }; 
  }
}
