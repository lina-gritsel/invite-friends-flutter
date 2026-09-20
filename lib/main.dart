import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invite_friends/app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  runApp(const InviteFriendsApp());
}
