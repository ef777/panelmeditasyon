import 'dart:html' as html;
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_compression/image_compression.dart';
import 'package:url_launcher/url_launcher.dart';

class Canli extends StatefulWidget {
  const Canli({Key? key}) : super(key: key);

  @override
  _CanliState createState() => _CanliState();
}

class _CanliState extends State<Canli> {
  final TextEditingController baslikcont = TextEditingController();
  final TextEditingController aciklamacont = TextEditingController();
  final TextEditingController oncelikcont = TextEditingController();
  final TextEditingController kimdencont = TextEditingController();
  final TextEditingController idcont = TextEditingController();
  final TextEditingController icresimcont = TextEditingController();
  final TextEditingController gidecekkont = TextEditingController();
  final TextEditingController disresimcont = TextEditingController();
  final TextEditingController aktifkont = TextEditingController();
  final TextEditingController tipkont = TextEditingController();


  final TextEditingController canlimodel1isim = TextEditingController();
  final TextEditingController canlimodel2isim = TextEditingController();
  final TextEditingController canlimodel1aktif = TextEditingController();
  final TextEditingController canlimodel2aktif = TextEditingController();



  html.File? _selectedImage2;
  double _uploadProgress = 0.0;
  bool _isUploading = false;

  late CollectionReference _CanliModelsCollection;
  late CollectionReference _CanliayarlarCollection;

  @override
  void initState() {
    super.initState();
    _CanliModelsCollection =
        FirebaseFirestore.instance.collection('programvesertifika');
         _CanliayarlarCollection =
        FirebaseFirestore.instance.collection('canlitip');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Canli',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: _CanliModelsCollection.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Bir hata oluştu: ${snapshot.error}'),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.blue),
                      );
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('CanliModel bulunamadı.'),
                      );
                    }

                    final Canliitems = snapshot.data!.docs
                        .map((doc) => CanliModel.fromFirestore(doc))
                        .toList();
                    Canliitems.sort((a, b) =>
                        int.parse(a.oncelik).compareTo(int.parse(b.oncelik)));

                    List<CanliModel> canli =
                        Canliitems.where((item) => item.tip == '1').toList();

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: canli.length,
                      itemBuilder: (context, index) {
                        final Canliitem = canli[index];
                        return InkWell(
                          onTap: () {
                            _showEditCanliModelDialog(Canliitem);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              elevation: 3,
                              child: ListTile(
                                leading: CachedNetworkImage(
                                  imageUrl: Canliitem.disresimurl,
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                                title: Text(
                                  Canliitem.baslik,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Canli: ${Canliitem.baslik}'),
                                    Text('tip: ${Canliitem.tip}'),
                                    Text('id: ${Canliitem.id}'),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    _showDeleteCanliModelDialog(Canliitem);
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: 16),
                Text(
                  'Sertifika',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: _CanliModelsCollection.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Bir hata oluştu: ${snapshot.error}'),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.blue),
                      );
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('CanliModel bulunamadı.'),
                      );
                    }

                    final Canliitems = snapshot.data!.docs
                        .map((doc) => CanliModel.fromFirestore(doc))
                        .toList();
                    Canliitems.sort((a, b) =>
                        int.parse(a.oncelik).compareTo(int.parse(b.oncelik)));

                    List<CanliModel> sertifika =
                        Canliitems.where((item) => item.tip == '2').toList();

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: sertifika.length,
                      itemBuilder: (context, index) {
                        final Canliitem = sertifika[index];
                        return InkWell(
                          onTap: () {
                            _showEditCanliModelDialog(Canliitem);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              elevation: 3,
                              child: ListTile(
                                leading: CachedNetworkImage(
                                  imageUrl: Canliitem.disresimurl,
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                                title: Text(
                                  Canliitem.baslik,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Canli: ${Canliitem.baslik}'),
                                    Text('tip: ${Canliitem.tip}'),
                                    Text('id: ${Canliitem.id}'),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    _showDeleteCanliModelDialog(Canliitem);
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Row(children:[ 

 ElevatedButton(
                child: Text('Yeni CanliModel Ekle'),
                onPressed: _showAddCanliModelDialog,
              )
,
 ElevatedButton(
                child: Text('CanliModel ayar işlemleri'),
                onPressed: _showCanliislemayarDialog,
              )
              ])),
        ],
      ),
    );
  }

/*   Future<void> _updateImage2(CanliModel Canliitem) async {
    final storage = firebase_storage.FirebaseStorage.instance;
    final storageRef = storage.ref();
    final imagePath =
        'CanliModels/${DateTime.now().microsecondsSinceEpoch}.jpg';
    final uploadTask = storageRef.child(imagePath).putBlob(_selectedImage2!);

    uploadTask.snapshotEvents.listen((event) {
      final progress = event.bytesTransferred / event.totalBytes;
      setState(() {
        _uploadProgress = progress;
      });
    });

    final snapshot = await uploadTask.whenComplete(() {
      setState(() {
        _uploadProgress = 1.0;
      });
    });

    final imageUrl = await snapshot.ref.getDownloadURL();
    Canliitem.disresimurl = imageUrl.toString();
  }
 */
  void _showEditCanliModelDialog(CanliModel Canliitem) {
    baslikcont.text = Canliitem.baslik;
    idcont.text = Canliitem.id;
    aciklamacont.text = Canliitem.aciklama;
    kimdencont.text = Canliitem.kimden;
    disresimcont.text = Canliitem.disresimurl;
    gidecekkont.text = Canliitem.gidecekurl;
    aktifkont.text = Canliitem.aktif;
    tipkont.text = Canliitem.tip;
    oncelikcont.text = Canliitem.oncelik;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          double _uploadProgress = 0.0; // Progress indicator value

          return AlertDialog(
            title: Text('CanliModel Düzenle'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: aktifkont,
                    decoration: InputDecoration(
                      labelText: 'Aktif ( "1", "0")',
                    ),
                  ),
                  TextField(
                    controller: tipkont,
                    decoration: InputDecoration(
                      labelText: 'Tip (canli icin "1", sertifika icin "2")',
                    ),
                  ),
                  TextField(
                    controller: oncelikcont,
                    decoration: InputDecoration(
                      labelText: '“Öncelik No(en düşük, en önce)',
                    ),
                  ),
                  TextField(
                    controller: gidecekkont,
                    decoration: InputDecoration(
                      labelText: 'Gidecek url ',
                    ),
                  ),
                  TextField(
                    controller: kimdencont,
                    decoration: InputDecoration(
                      labelText: 'Eğitmen',
                    ),
                  ),
                  TextField(
                    controller: aciklamacont,
                    decoration: InputDecoration(
                      labelText: 'Başlık',
                    ),
                  ),
                  TextField(
                                            maxLines: null, // Bu satır ile metin girişi çok satırlı hale getiriliyor

                    controller: baslikcont ,
                    decoration: InputDecoration(
                      labelText: 'Açıklama',
                      
                    ),
                  ),
                  ElevatedButton(
                    child: Text('Büyük Görsel seç'),
                    onPressed: () {
                      _selectedImage2 = null;

                      _selectImage2();
                    },
                  ),
                  //cached network image
                  if (Canliitem.disresimurl != null)
                    CachedNetworkImage(
                      width: 300,
                      height: 300,
                      imageUrl: Canliitem.disresimurl!,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('İptal'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Text('Güncelle'),
                onPressed: () async {
                  final updatedCanliModel = CanliModel(
                    oncelik: oncelikcont.text,
                    aciklama: aciklamacont.text,
                    kimden: kimdencont.text,
                    aktif: aktifkont.text,
                    id: idcont.text,
                    tip: tipkont.text,
                    baslik: baslikcont.text,
                    gidecekurl: gidecekkont.text,
                    disresimurl: disresimcont.text,
                  );

                  if (_selectedImage2 != null) {
                    // Delete previous image if exists
                    if (Canliitem.disresimurl.isNotEmpty) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Görsel Ekleniyor'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    'Önceki Görsel varsa siliniyor. Lütfen bekleyin...'),
                                LinearProgressIndicator(
                                  value: _uploadProgress,
                                ),
                              ],
                            ),
                          );
                        },
                      );

                      try {
                        await _deleteImage(Canliitem.disresimurl);
                      } catch (e) {
                        print('Görsel silme hatası: $e');
                        Navigator.pop(context);
                      }
                    }

                    await _uploadImage2(updatedCanliModel);

                    Navigator.pop(context);
                  }

                  setState(() {
                    _uploadProgress = 0.0;
                  });

                  try {
                    await _CanliModelsCollection.doc(Canliitem.id)
                        .update(updatedCanliModel.toMap());

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tamamlandı!'),
                      ),
                    );

                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Hata!' + e.toString()),
                      ),
                    );

                    print('Güncelleme başarısız: $e');
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  void _showAddCanliModelDialog() {
    baslikcont.text = "";
    idcont.text = "";
    aciklamacont.text = "";
    kimdencont.text = "";
    disresimcont.text = "";
    gidecekkont.text = "";
    aktifkont.text = "";
    tipkont.text = "";
    oncelikcont.text = "";
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          double _uploadProgress = 0.0; // Progress indicator value

          return AlertDialog(
            title: Text('Yeni CanliModel Ekle'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextField(
                    controller: aktifkont,
                    decoration: InputDecoration(
                      labelText: 'aktif ( "1", "0")',
                    ),
                  ),
                  TextField(
                    controller: oncelikcont,
                    decoration: InputDecoration(
                      labelText: '“Öncelik No(en düşük, en önce)',
                    ),
                  ),
                  TextField(
                    controller: tipkont,
                    decoration: InputDecoration(
                      labelText: 'tip (canli icin "1", sertifika icin "2")',
                    ),
                  ),
                  TextField(
                    controller: gidecekkont,
                    decoration: InputDecoration(
                      labelText: 'Gidecek url ',
                    ),
                  ),
                  TextField(
                    controller: kimdencont,
                    decoration: InputDecoration(
                      labelText: 'Eğitmen',
                    ),
                  ),

                  TextField(
                    controller: aciklamacont,
                    decoration: InputDecoration(
                      labelText: 'Başlık',
                    ),
                  ),
                  TextField(
                      maxLines: null,
                    controller: baslikcont ,
                    decoration: InputDecoration(
                      labelText: 'Açıklama',
                    ),
                  ),

                  SizedBox(height: 10),
                  ElevatedButton(
                    child: Text('Büyük Görsel Seç'),
                    onPressed: () {
                      _selectImage2();
                    },
                  ),
                  SizedBox(height: 10),

                  // ... the rest of your dialog children
                  ElevatedButton(
                    child: Text('Ekle'),
                    onPressed: _isUploading
                        ? null
                        : () async {
                            final canliitem = CanliModel(
                              oncelik: oncelikcont.text,
                              aciklama: aciklamacont.text,
                              kimden: kimdencont.text,
                              aktif: aktifkont.text,
                              id: idcont.text,
                              tip: tipkont.text,
                              baslik: baslikcont.text,
                              gidecekurl: gidecekkont.text,
                              disresimurl: disresimcont.text,
                            );

                            // Resim ve ses seçildiyse yükle
                            if (_selectedImage2 != null) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Görsel Yükleniyor'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                            'Görsel yükleniyor. Lütfen bekleyin...'),
                                        LinearProgressIndicator(
                                          value: _uploadProgress,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );

                              await _uploadImage2(canliitem);

                              Navigator.pop(context);
                            }

                            setState(() {
                              _uploadProgress = 0.0;
                            });

                            await _CanliModelsCollection.add(canliitem.toMap());
                            setState(() {
                              _isUploading = false;
                            });
                            Navigator.of(context).pop();
                          },
                  ),
                  if (_isUploading)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          LinearProgressIndicator(
                            value: _uploadProgress,
                          ),
                          Text(
                            '${(_uploadProgress * 100).toStringAsFixed(2)}% yüklendi',
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('İptal'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }
 void _showCanliislemayarDialog() {
  print("tıklandi");
  showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {

          return
     StreamBuilder<QuerySnapshot>(
                  stream: _CanliayarlarCollection.snapshots(),
                  builder: (context, snapshot) {
                    print("tıklandi2");
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Bir hata oluştu: ${snapshot.error}'),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.blue),
                      );
                    }

                    if (snapshot.data!.docs.isEmpty) {
                                          print("veri yok");

                      return const Center(
                        child: Text('CanliModel bulunamadı.'),
                      );
                    }
                                 print("veri var");

                  List<Map<String, dynamic>> belgeListesi = snapshot.data!.docs.map((doc) => doc.data()! as Map<String, dynamic>).toList();
var belge = belgeListesi[0];
var canli1aktif = belge['canliaktif1'];
var canli2aktif = belge['canliaktif2'];
var canli1isim = belge['canliisim1'];
var canli2isim = belge['canliisim2'];
print("işte okunana değerler");
                print(canli1aktif);
                print(canli2aktif);
                print(canli1isim);
                print(canli2isim);
      canlimodel1isim.text = canli1isim;
    canlimodel2isim.text = canli2isim;
    canlimodel1aktif.text = canli1aktif;
    canlimodel2aktif.text = canli2aktif;

   return   AlertDialog(
            title: Text('canli model ayar düzenle'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextField(
                    controller: canlimodel1aktif,
                    decoration: InputDecoration(
                      labelText: 'canli akitf 1 ( "1", "0")',
                    ),
                  ),
                  TextField(
                    controller: canlimodel2aktif,
                    decoration: InputDecoration(
                      labelText: 'canli akitf 2 ( "1", "0")',
                    ),
                  ),
                   TextField(
                    controller: canlimodel1isim,
                    decoration: InputDecoration(
                      labelText: 'canli isim 1',
                    ),
                  ),
                  TextField(
                    controller: canlimodel2isim,
                    decoration: InputDecoration(
                      labelText: 'canli isim 2',
                    ),
                  ),
               
              
               

              
                        ],
                      ),
                    ),
                
              
            
            actions: [
              TextButton(
                child: Text('İptal'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Düzenle'),
                onPressed: () {
                   _CanliayarlarCollection.doc("ayar").update({
  'canliaktif1': canlimodel1aktif.text,
  'canliaktif2': canlimodel2aktif.text,
  'canliisim1': canlimodel1isim.text,
  'canliisim2': canlimodel2isim.text,
});
                  Navigator.of(context).pop();

                },
              ),
            ],
          );
        });
      },
    );

  });}

   
  
 
 
  void _selectImage2() {
    final input = html.FileUploadInputElement();
    input.accept = 'image/*';
    input.click();
    input.onChange.listen((event) {
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        _selectedImage2 = files[0];
      }
    });
  }

  Future<void> _uploadImage2(CanliModel CanliModel) async {
    final storage = firebase_storage.FirebaseStorage.instance;
    final storageRef = storage.ref();
    final imagePath =
        'CanliModels/${DateTime.now().microsecondsSinceEpoch}.jpg';

    final reader = html.FileReader();
    reader.readAsArrayBuffer(_selectedImage2!);

    await reader.onLoadEnd.first;

    final data = reader.result as Uint8List;
    final buffer = data.buffer as ByteBuffer;
    final raw = buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    Configuration config = Configuration(
      jpgQuality: 10,
      animationGifSamplingFactor: 10,
      outputType: OutputType.jpg,
    );
    final input = ImageFile(
      rawBytes: raw, //or buffer
      filePath: _selectedImage2!.name,
    );

    final output =
        compress(ImageFileConfiguration(input: input, config: config));
    final blob = html.Blob([output.rawBytes]);
    final uploadTask = storageRef.child(imagePath).putBlob(blob);

    uploadTask.snapshotEvents.listen((event) {
      final progress = event.bytesTransferred / event.totalBytes;
      setState(() {
        _uploadProgress = progress;
      });
    });

    final snapshot = await uploadTask.whenComplete(() {
      setState(() {
        _uploadProgress = 1.0;
      });
    });

    final imageUrl = await snapshot.ref.getDownloadURL();
    CanliModel.disresimurl = imageUrl.toString();
  }

/* 
  Future<void> _uploadImage2(CanliModel CanliModel) async {
    final storage = firebase_storage.FirebaseStorage.instance;
    final storageRef = storage.ref();
    final imagePath =
        'CanliModels/${DateTime.now().microsecondsSinceEpoch}.jpg';
    final uploadTask = storageRef.child(imagePath).putBlob(_selectedImage2!);

    uploadTask.snapshotEvents.listen((event) {
      final progress = event.bytesTransferred / event.totalBytes;
      setState(() {
        _uploadProgress = progress;
      });
    });

    final snapshot = await uploadTask.whenComplete(() {
      setState(() {
        _uploadProgress = 1.0;
      });
    });

    final imageUrl = await snapshot.ref.getDownloadURL();
    CanliModel.disresimurl = imageUrl.toString();
  }
 */
  void _showDeleteCanliModelDialog(CanliModel canlimodel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('CanliModel Sil'),
          content: Text(
              "${canlimodel.baslik} adlı CanliModel'ı silmek istediğinize emin misiniz?'"),
          actions: [
            TextButton(
              child: Text('Hayır'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Evet'),
              onPressed: () async {
                // Resim ve sesi sil
                try {
                  await _deleteImage(canlimodel.disresimurl);
                } catch (e) {}

                await _CanliModelsCollection.doc(canlimodel.id).delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteImage(String imageUrl) async {
    if (imageUrl.isNotEmpty) {
      final storage = firebase_storage.FirebaseStorage.instance;
      final storageRef = storage.ref();
      await storageRef.child(imageUrl).delete();
    }
  }

  Future<void> _deleteAudio(String audioUrl) async {
    if (audioUrl.isNotEmpty) {
      final storage = firebase_storage.FirebaseStorage.instance;
      final storageRef = storage.ref();
      await storageRef.child(audioUrl).delete();
    }
  }
}

class CanliModel {
  final String tip;
  String oncelik;

  String id;
  final String aciklama;
  final String aktif;
  final String baslik;
  final String kimden;
  String disresimurl;
  final String gidecekurl;

  CanliModel({
    required this.oncelik,
    required this.aciklama,
    required this.kimden,
    required this.aktif,
    required this.tip,
    required this.baslik,
    required this.disresimurl,
    required this.gidecekurl,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'baslik': baslik,
      'aciklama': aciklama,
      'kimden': kimden,
      'id': id,
      'gidecekurl': gidecekurl,
      'disresimurl': disresimurl,
      'aktif': aktif,
      'tip': tip,
      'oncelik': oncelik,
    };
  }

  factory CanliModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CanliModel(
      oncelik: data['oncelik'],
      tip: data['tip'],
      id: doc.id,
      baslik: data['baslik'],
      aciklama: data['aciklama'],
      kimden: data['kimden'],
      gidecekurl: data['gidecekurl'],
      disresimurl: data['disresimurl'],
      aktif: data['aktif'],
    );
  }
}
