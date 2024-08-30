import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


late BuildContext contextIndex;
BuildContext? contextCurrent = contextCurrent ?? navigatorKey.currentContext;
BuildContext? dialogContext;
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

late Size screenSize;  //屏幕信息

class Contexts {
  static init(BuildContext context) async {
    screenSize = MediaQuery.of(context).size;
  }

}

