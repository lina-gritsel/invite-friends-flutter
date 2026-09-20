import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final robotoBytes = await File('test/fonts/Roboto.ttf').readAsBytes();
  final roboto = FontLoader('Roboto')
    ..addFont(Future.value(ByteData.sublistView(robotoBytes)));
  final materialIcons = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await Future.wait([roboto.load(), materialIcons.load()]);
  await testMain();
}
