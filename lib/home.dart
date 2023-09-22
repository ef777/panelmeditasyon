import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:panelmeditasyon/admins.dart';
import 'package:panelmeditasyon/homeview.dart';
import 'package:panelmeditasyon/login.dart';

import 'canliegitim.dart';
import 'kategori.dart';
import 'kullanici.dart';
import 'meditasyone.dart';

class HomeController extends GetxController {
  RxInt selectedIndex = 0.obs;
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(95, 95, 125, 1),
        title: Text('Panel Spiritya'),
        centerTitle: true,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/images/logo.svg',
            width: 30,
            height: 30,
          ),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Get.off(LoginPage());
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.0),
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Colors.white,
            ),
            child: Obx(() => _buildBottomNavigationBar()),
          ),
        ),
      ),
      body: Obx(() => _getPage(controller.selectedIndex.value)),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Color.fromRGBO(95, 95, 125, 1),
      currentIndex: controller.selectedIndex.value,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      unselectedIconTheme: IconThemeData(color: Colors.grey),
      selectedIconTheme: IconThemeData(color: Colors.white),
      unselectedFontSize: 12,
      selectedFontSize: 14,
      unselectedLabelStyle: TextStyle(color: Colors.grey),
      selectedLabelStyle: TextStyle(color: Colors.white),
      onTap: (index) => controller.selectedIndex.value = index,
      items: [
        BottomNavigationBarItem(
          icon: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home),
              SizedBox(height: 5),
            ],
          ),
          label: 'Anasayfa',
        ),
        BottomNavigationBarItem(
          icon: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_fill),
              SizedBox(height: 5),
            ],
          ),
          label: 'Meditasyonlar',
        ),
        BottomNavigationBarItem(
          icon: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.category),
              SizedBox(height: 5),
            ],
          ),
          label: 'Kategoriler',
        ),
        BottomNavigationBarItem(
          icon: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.live_tv),
              SizedBox(height: 5),
            ],
          ),
          label: 'Canlı Egitimler',
        ),
        BottomNavigationBarItem(
          icon: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.admin_panel_settings),
              SizedBox(height: 5),
            ],
          ),
          label: 'Adminler',
        ),
        BottomNavigationBarItem(
          icon: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person),
              SizedBox(height: 5),
            ],
          ),
          label: 'Kullanıcılar',
        ),
      ],
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return HomeView();
      case 1:
        return MeditationListPage();
      case 2:
        return Kategori();
      case 3:
        return Canli();
      case 4:
        return AdminAdminModelsPage();
      case 5:
        return UserListPage();
      default:
        return HomeView();
    }
  }
}
