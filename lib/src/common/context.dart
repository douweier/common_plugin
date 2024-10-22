import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


late BuildContext contextIndex;

late Size screenSize;  //屏幕信息

class Contexts {
  static init(BuildContext context) async {
    contextIndex = context;
    screenSize = MediaQuery.of(contextIndex).size;
  }

}

