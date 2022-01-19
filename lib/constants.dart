import 'package:flutter/widgets.dart';

const String homeScreenTitleImgM = 'assets/images/appbar_title_white.png';
const String homeScreenTitleImgC = 'assets/images/appbar_title_blue.png';

const String appDatabaseFileName = 'app.db';
const String appDatabaseBackupFileName = 'app.db.backup';
const int appDatabaseVersion = 1;

const String messagesTableName = 'messages';

class MessagesDbCols {
  static const String id = '_id';
  static const String message = 'message';
  static const String createdTime = 'created_time';
}

class ErrorMessages {
  static const String iCloudConnectionOrPermissionStr =
      'Platform Exception: iCloud container ID is not valid, or user is not signed in for iCloud, or user denied iCloud permission for this app';
}

const double scaffoldBodyWidthRate = 0.9;
const Color threadNameBgColor = Color(0xFFFAEBDD);
