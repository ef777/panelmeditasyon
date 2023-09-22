import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Config extends GetxController {
  double? gunlukkazanc;
  double? aylikkazanc;
  double? yilkazanc;

  double? gunlukyenikullanici;
  double? aylikyeikullanici;
  double? yilkullanici;

  double? gunlukpaketyenileme;
  double? aylikpaketyenileme;
  double? yilpaketyenileme;

  //performans bitti

  double? gunlukdakika;
  double? aylikdakika;
  double? yildakika;

  double? gunlukdinleyensayisi;
  double? aylikdinleyensayisi;
  double? yildinleyensayisi;

  double? gunlukmeditasdinlemeyonadeti;
  double? aylikmeditasdinlemeyonadeti;
  double? yilmeditasdinlemeyonadeti;
  var favori = [];
  final aramadegisti = false.obs;

  degistir() {
    aramadegisti(!aramadegisti.value);
  }

  static Future<bool> checkInternet() async {
    try {
      print("internet kontrol ediliyor");
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected internet');
        return true;
      }
    } on SocketException catch (_) {
      print('not connected internet');

      return false;
    }
    print("internet kontrol edildi başarısız");
    return false;
  }

  static var premium = false;
  static var premiumbitis = "".obs;
  static var premiumbaslangic = "".obs;
  static var premiumkalan = "".obs;
  static var login = false.obs;
  static var logind = false;
  static var email = "".obs;
  static var uid = "".obs;
  static var isim = "".obs;

  static UserCredential? user;
  static var main = Color.fromRGBO(17, 17, 68, 1);
}
