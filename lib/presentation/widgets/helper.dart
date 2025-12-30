import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> initWindow() async {
  //* Set android status bar color
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white, systemNavigationBarIconBrightness: Brightness.dark, statusBarBrightness: Brightness.dark, statusBarColor: Colors.white, statusBarIconBrightness: Brightness.dark));
  }
}
