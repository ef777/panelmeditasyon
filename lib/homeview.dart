import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:panelmeditasyon/config.dart';

class HomeView extends StatefulWidget {
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Config config = Get.put(Config());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Günlük, Aylık ve Yil Kazancı',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[900],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      Colors.green[700],
                      'Günlük Kazanç',
                      'TL ${config.gunlukkazanc.toString()}',
                      Icons.monetization_on_rounded,
                    ),
                    _buildStatCard(
                      Colors.blue[700],
                      'aylik Kazanç',
                      'TL ${config.aylikkazanc.toString()}',
                      Icons.monetization_on_rounded,
                    ),
                    _buildStatCard(
                      Colors.orange[700],
                      'yil Kazanç',
                      'TL ${config.yilkazanc.toString()}',
                      Icons.monetization_on_rounded,
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Text(
                  'Yeni Kullanıcılar',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[900],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 14.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      Colors.purple[700],
                      'Günlük Yeni Kullanıcılar',
                      config.gunlukyenikullanici.toString(),
                      Icons.person_add_rounded,
                    ),
                    _buildStatCard(
                      Colors.teal[700],
                      'aylik Yeni Kullanıcılar',
                      config.aylikyeikullanici.toString(),
                      Icons.person_add_rounded,
                    ),
                    _buildStatCard(
                      Colors.red[700],
                      'yil Yeni Kullanıcılar',
                      config.yilkullanici.toString(),
                      Icons.person_add_rounded,
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Text(
                  'Yenilemeler',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[900],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 14.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      Colors.brown[700],
                      'Günlük Yenilemeler',
                      config.gunlukpaketyenileme.toString(),
                      Icons.refresh_rounded,
                    ),
                    _buildStatCard(
                      Colors.amber[700],
                      'aylik Yenilemeler',
                      config.aylikpaketyenileme.toString(),
                      Icons.refresh_rounded,
                    ),
                    _buildStatCard(
                      Colors.indigo[700],
                      'yil Yenilemeler',
                      config.yilpaketyenileme.toString(),
                      Icons.refresh_rounded,
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Text(
                  'Performans ve İstatistikler',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[900],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 14.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      Colors.deepPurple[700],
                      'Günlük Dinlenme Dakika',
                      config.gunlukdakika.toString(),
                      Icons.timer_rounded,
                    ),
                    _buildStatCard(
                      Colors.deepOrange[700],
                      'Günlük Dinlenme Kişi',
                      config.gunlukdinleyensayisi.toString(),
                      Icons.person_rounded,
                    ),
                    _buildStatCard(
                      Colors.teal[700],
                      'Günlük Dinlenme Meditasyon',
                      config.gunlukmeditasdinlemeyonadeti.toString(),
                      Icons.music_note_rounded,
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      Colors.deepPurple[700],
                      'aylik Dinlenme Dakika',
                      config.aylikdakika.toString(),
                      Icons.timer_rounded,
                    ),
                    _buildStatCard(
                      Colors.deepOrange[700],
                      'aylik Dinlenme Kişi',
                      config.aylikdinleyensayisi.toString(),
                      Icons.person_rounded,
                    ),
                    _buildStatCard(
                      Colors.teal[700],
                      'aylik Dinlenme Meditasyon',
                      config.aylikmeditasdinlemeyonadeti.toString(),
                      Icons.music_note_rounded,
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      Colors.deepPurple[700],
                      'yil Dinlenme Dakika',
                      config.yildakika.toString(),
                      Icons.timer_rounded,
                    ),
                    _buildStatCard(
                      Colors.deepOrange[700],
                      'yil Dinlenme Kişi',
                      config.yildinleyensayisi.toString(),
                      Icons.person_rounded,
                    ),
                    _buildStatCard(
                      Colors.teal[700],
                      'yil Dinlenme Meditasyon',
                      config.yilmeditasdinlemeyonadeti.toString(),
                      Icons.music_note_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildStatCard(
      Color? color, String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40.0,
                color: color,
              ),
              SizedBox(height: 5.0),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.0),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
