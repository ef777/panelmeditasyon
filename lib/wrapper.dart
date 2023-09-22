import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:panelmeditasyon/home.dart';
import 'package:panelmeditasyon/login.dart';

import 'config.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Rx<User?> firebaseUser = Rx<User?>(null);
  Config config = Get.put(Config());
  Future getstatdata(String belge) async {
    print('statistic data getiriliyor');

    CollectionReference statistic =
        FirebaseFirestore.instance.collection('statistics');
    print(belge.toString());
    print(' belge');
    DocumentReference belgeReferansi = statistic.doc(belge);
    DocumentSnapshot doc = await belgeReferansi.get();
    if (doc.exists) {
      print('Belge bulundu.');
      final dat = doc.data();

      if (dat is Map<String, dynamic>) {
        print('döküman okundu');
        config.gunlukdinleyensayisi = dat['dailyUniqueListeners'] ?? 0;
        config.gunlukmeditasdinlemeyonadeti = dat['dailyMdPlays'] ?? 0;
        config.gunlukpaketyenileme = dat['dailyNewSubscriptions'] ?? 0;
        config.gunlukyenikullanici = dat['dailyNewUsers'] ?? 0;
        config.gunlukkazanc = dat['dailyTotalRevenue'] ?? 0;
        config.gunlukdakika = dat['dailyMdListens'] ?? 0;
        config.aylikdakika = dat['monthlyMdListens'] ?? 0;
        config.aylikdinleyensayisi = dat['monthlyUniqueListeners'] ?? 0;
        config.aylikkazanc = dat['monthlyTotalRevenue'] ?? 0;
        config.aylikmeditasdinlemeyonadeti = dat['monthlyMdPlays'] ?? 0;
        config.aylikpaketyenileme = dat['monthlyNewSubscriptions'] ?? 0;
        config.aylikyeikullanici = dat['monthlyNewUsers'] ?? 0;
        print("aşama 1");
        config.yildakika =
            dat['yearlyMdListens'] != null ? dat['yearlyMdListens'] : 0 ?? 0;
        print("aşama 2");

        config.yildinleyensayisi = dat['yearlyUniqueListeners'] != null
            ? dat['yearlyUniqueListeners']
            : 0 ?? 0;
        print("aşama 3");

        config.yilkazanc = dat['yearlyTotalRevenue'] != null
            ? dat['yearlyTotalRevenue']
            : 0 ?? 0;
        config.yilmeditasdinlemeyonadeti =
            dat['yearlyMdPlays'] != null ? dat['yearlyMdPlays'] : 0 ?? 0;
        config.yilpaketyenileme = dat['yearlyNewSubscriptions'] != null
            ? dat['yearlyNewSubscriptions']
            : 0 ?? 0;
        config.yilkullanici =
            dat['yearlyNewUsers'] != null ? dat['yearlyNewUsers'] : 0 ?? 0;
        print('statistic data getirildi');
      } else {
        print('döküman hatası.');
        return null;
      }
    } else {
      print('Belge bulunamadı.');
      return null;
    }
  }

  Future<String> getrefadress() async {
    CollectionReference koleksiyonReferansi =
        FirebaseFirestore.instance.collection('data');
    DocumentReference belgeReferansi = koleksiyonReferansi.doc('reference');

    DocumentSnapshot doc = await belgeReferansi.get();
    if (doc.exists) {
      final dat = doc.data();
      if (dat is Map<String, dynamic> && dat.containsKey('daily')) {
        String dailystParam = dat['daily'];
        return dailystParam;
      } else {
        print('reference parametresi bulunamadı.');
        return "bos";
      }
    } else {
      print('reference bulunamadı.');
      return "bos";
    }
  }

  data() async {
    String refAddress = await getrefadress();
    Future.delayed(Duration(seconds: 2)).then((_) {});
    getstatdata(refAddress);

    print("tamamlandı");
  }

  @override
  void onInit() {
    data();
    Future.delayed(Duration(seconds: 3)).then((_) {});

    super.onInit();
  }

  /* Future<void> logout() async {
    await _auth.signOut();
  } */
}

class wrapper extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  final LoginController _LoginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (Config.login == false.obs) {
        return LoginPage();
      } else {
        // User i
        return HomePage();
      }
    });
  }
}
