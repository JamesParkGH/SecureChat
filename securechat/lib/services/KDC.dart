import 'package:http/http.dart' as http;

/// Gets the key for the communication between [user1] and [user2] from the local node server (run that first)
///
/// Example:
/// ```dart
/// getKey('username1', 'username2').then((key) {
///       debugPrint("Key is $key");
///     });
/// ```
///
class KDC {
  Future<String> getKey(user1, user2) async {
  final response = await http
      .get(Uri.parse('http://10.0.2.2:3000/key?user1=$user1&user2=$user2'))
      .timeout(const Duration(seconds: 5))
      .catchError((err) {
    throw Exception(
        'Failed to fetch key, make sure the node server is running');
    });
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to fetch key, server didnt return 200');
    }
  }
}


