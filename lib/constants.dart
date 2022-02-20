import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const String homeScreenTitleImgM = 'assets/images/appbar_title_white.png';
const String homeScreenTitleImgC = 'assets/images/appbar_title_blue.png';

const String appDatabaseFileName = 'app.db';
const String appDatabaseBackupFileNamePrefix = 'monostory.db_';
const int appDatabaseVersion = 2;

const String threadsTableNameV1 = 'threads';
const String threadsTableNameV2 = 'threads';
const String storiesTableNameV1 = 'messages';
const String storiesTableNameV2 = 'stories';

const String defaultThreadName = 'All';

class ThreadsTableCols {
  static const String id = '_id';
  static const String name = 'name';
}

class StoriesTableCols {
  static const String id = '_id';
  static const String story = 'story';
  static const String fkThreadId = 'fk_thread_id';
  static const String createdTime = 'created_time';
  static const String starred = 'starred';
}

class StoriesTableColsV1 {
  static const String id = '_id';
  static const String message = 'message';
  static const String fkThreadId = 'fk_thread_id';
  static const String createdTime = 'created_time';
  static const String starred = 'starred';
}

class SettingsKeys {
  static const String useCellularData = 'use_cellular_data';
}

class ErrorMessages {
  static const String iCloudConnectionOrPermissionStr =
      'Platform Exception: iCloud container ID is not valid, or user is not signed in for iCloud, or user denied iCloud permission for this app';
  static const String messageReadingFailure = 'Unexpected error occurred';
}

///
/// Text Color
///
class TextColorLM {
  static const Color dft = Color(0xFF37352F);
  static const Color gray = Color(0xFF9B9A97);
  static const Color brown = Color(0xFF64473A);
  static const Color orange = Color(0xFFD9730D);
  static const Color yellow = Color(0xFFDFAB01);
  static const Color green = Color(0xFF0F7B6C);
  static const Color blue = Color(0xFF0B6E99);
  static const Color purple = Color(0xFF6940A5);
  static const Color pink = Color(0xFFAD1A72);
  static const Color red = Color(0xFFE03E3E);
}

class TextColorDM {
  static const Color dft = Color(0xFFFFFFFF);
  static const Color gray = Color(0xFF979A9B);
  static const Color brown = Color(0xFF937264);
  static const Color orange = Color(0xFFFFA344);
  static const Color yellow = Color(0xFFFFDC49);
  static const Color green = Color(0xFF4DAB9A);
  static const Color blue = Color(0xFF529CCA);
  static const Color purple = Color(0xFF9A6DD7);
  static const Color pink = Color(0xFFE255A1);
  static const Color red = Color(0xFFFF7369);
}

///
/// Background Color
///
class BgColorLM {
  static const Color dft = Color(0xFFFFFFFF);
  static const Color gray = Color(0xFFEBECED);
  static const Color brown = Color(0xFFE9E5E3);
  static const Color orange = Color(0xFFFAEBDD);
  static const Color yellow = Color(0xFFFBF3DB);
  static const Color green = Color(0xFFDDEDEA);
  static const Color blue = Color(0xFFDDEBF1);
  static const Color purple = Color(0xFFEAE4F2);
  static const Color pink = Color(0xFFF4DFEB);
  static const Color red = Color(0xFFFBE4E4);
}

class BgColorDM {
  static const Color dft = Color(0xFF2F3437);
  static const Color gray = Color(0xFF454B4E);
  static const Color brown = Color(0xFF434040);
  static const Color orange = Color(0xFF594A3A);
  static const Color yellow = Color(0xFF59563B);
  static const Color green = Color(0xFF354C4B);
  static const Color blue = Color(0xFF364954);
  static const Color purple = Color(0xFF443F57);
  static const Color pink = Color(0xFF533B4C);
  static const Color red = Color(0xFF594141);
}

class SelectBgColorLM {
  static const Color dft = Color(0xFFCECDCA);
  static const Color gray = Color(0xFF9B9A97);
  static const Color brown = Color(0xFF8C2E00);
  static const Color orange = Color(0xFFF55D00);
  static const Color yellow = Color(0xFFE9A800);
  static const Color green = Color(0xFF00876B);
  static const Color blue = Color(0xFF0078DF);
  static const Color purple = Color(0xFF6724DE);
  static const Color pink = Color(0xFFDD0081);
  static const Color red = Color(0xFFFF001A);
}

class SelectBgColorDM {
  static const Color dft = Color(0xFF505558);
  static const Color gray = Color(0xFF979A9B);
  static const Color brown = Color(0xFF937264);
  static const Color orange = Color(0xFFFFA344);
  static const Color yellow = Color(0xFFFFDC49);
  static const Color green = Color(0xFF4DAB9A);
  static const Color blue = Color(0xFF529CCA);
  static const Color purple = Color(0xFF9A6DD7);
  static const Color pink = Color(0xFFE255A1);
  static const Color red = Color(0xFFFF7369);
}

const double scaffoldBodyWidthRate = 0.9;
// const Color threadNameTextColor = TextColorLM.orange;
const Color threadNameBgColor = BgColorLM.orange;
const Color undefinedThreadBgColor = BgColorLM.gray;
const Color dateTimeBgColor = Colors.transparent;
const Color threadInfoBgColor = BgColorLM.pink;

const double bottomSheetRadius = 15.0;

const int threadNameMaxCharLength = 30;

const int storyMaxLength = 512;

class MonoIcons {
  static IconData thread_icon =
      Platform.isIOS ? CupertinoIcons.tag : Icons.label;
  static IconData chevron_forward =
      Platform.isIOS ? CupertinoIcons.chevron_forward : Icons.chevron_right;
  static IconData more =
      Platform.isIOS ? CupertinoIcons.ellipsis : Icons.more_horiz;
}
