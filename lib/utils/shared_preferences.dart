import 'package:shared_preferences/shared_preferences.dart';

Future<void> storeUserId(String userId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('userId', userId);  // Store the Firebase UID
}

Future<String?> getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId');  // Retrieve the Firebase UID
}
