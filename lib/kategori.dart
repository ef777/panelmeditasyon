import 'dart:html' as html;
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_compression/image_compression.dart';
import 'package:url_launcher/url_launcher.dart';

class Kategori extends StatefulWidget {
  const Kategori({Key? key}) : super(key: key);

  @override
  _KategoriState createState() => _KategoriState();
}

class _KategoriState extends State<Kategori> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idcont = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _resimUrlController = TextEditingController();
  final TextEditingController _oncelikkategori = TextEditingController();

  html.File? _selectedImage;
  html.File? _selectedAudio;
  double _uploadProgress = 0.0;
  bool _isUploading = false;

  int yenitipkontrol(List<KategoriModel> kategoriModelsCollection) {
    List<int> ids = [];
    for (var item in kategoriModelsCollection) {
      try {
        print(item.tip);
        print("bu tip");
        int id = int.parse(item.tip);
        ids.add(id);
      } catch (e) {
        print('Failed to parse id: ${item.id}');
        // Handle the error or skip the invalid value
      }
    }

    int highestId =
        ids.reduce((value, element) => value > element ? value : element);
    int nextId = highestId + 1;

    return nextId;
  }

  late CollectionReference _KategoriModelsCollection;

  @override
  void initState() {
    super.initState();
    _KategoriModelsCollection =
        FirebaseFirestore.instance.collection('category');
  }

  var kategoriitems;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _KategoriModelsCollection.snapshots(),
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
                    child: Text('KategoriModel bulunamadı.'),
                  );
                }

                kategoriitems = snapshot.data!.docs
                    .map((doc) => KategoriModel.fromFirestore(doc))
                    .toList();

                kategoriitems.sort((a, b) =>
                    int.parse(a.oncelik).compareTo(int.parse(b.oncelik)));

                return ListView.builder(
                  itemCount: kategoriitems.length,
                  itemBuilder: (context, index) {
                    final kategoriitem = kategoriitems[index];

                    return InkWell(
                      onTap: () {
                        _showEditKategoriModelDialog(kategoriitem);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 3,
                          child: ListTile(
                            leading: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                      kategoriitem.resimurl!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(
                              kategoriitem.baslik,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Kategori: ${kategoriitem.baslik}'),
                                Text('tip: ${kategoriitem.tip}'),
                                Text('id: ${kategoriitem.id}'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _showDeleteKategoriModelDialog(kategoriitem);
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
          ),
          ElevatedButton(
            child: Text('Yeni KategoriModel Ekle'),
            onPressed: () {
              _showAddKategoriModelDialog(kategoriitems);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _updateImage(KategoriModel kategoriitem) async {
    final storage = firebase_storage.FirebaseStorage.instance;
    final storageRef = storage.ref();
    final imagePath =
        'KategoriModels/${DateTime.now().microsecondsSinceEpoch}.jpg';
    final uploadTask = storageRef.child(imagePath).putBlob(_selectedImage!);

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
    kategoriitem.resimurl = imageUrl.toString();
  }

  void _showEditKategoriModelDialog(KategoriModel kategoriitem) {
    _nameController.text = kategoriitem.baslik;
    _idcont.text = kategoriitem.id;
    _categoryController.text = kategoriitem.tip;
    _oncelikkategori.text = kategoriitem.oncelik;
    _resimUrlController.text = kategoriitem.resimurl;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          double _uploadProgress = 0.0; // Progress indicator value

          return AlertDialog(
            title: Text('KategoriModel Düzenle'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'KategoriModel Adı',
                    ),
                  ),
                  /*  TextField(
                    enabled: false,
                    controller: _categoryController,
                    decoration: InputDecoration(
                      labelText: 'tip',
                    ),
                  ), */
                  TextField(
                    controller: _oncelikkategori,
                    decoration: InputDecoration(
                      labelText: '“Öncelik No (en düşük, en önce)',
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    child: Text('Görsel Seç'),
                    onPressed: () {
                      _selectImage();
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    child: Text(
                      'Mevcut Görsel için tıklayın ',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onTap: () {
                      launch(_resimUrlController.text);
                    },
                  ),
                  /*  _resimUrlController.text.isNotEmpty
                      ? FadeInImage.assetNetwork(
                          placeholder: 'assets/loading.gif',
                          image:
                              'https://firebasestorage.googleapis.com/v0/b/meditasyonnn1.appspot.com/o/KategoriModels%2F1683850230326000.jpg?alt=media&token=c3601b28-2ddd-414e-9d63-11a0b3b84363',
                        ) */
                  Image.network(
                    _resimUrlController.text,
                    height: 300,
                    width: 300,
                  ),
                  SizedBox(
                    height: 10,
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
                  final updatedKategoriModel = KategoriModel(
                    oncelik: _oncelikkategori.text,
                    id: _idcont.text,
                    tip: _categoryController.text,
                    baslik: _nameController.text,
                    resimurl: _resimUrlController.text,
                  );

                  if (_selectedImage != null) {
                    // Delete previous image if exists
                    if (kategoriitem.resimurl.isNotEmpty) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Görsel Ekleniyor'),
                            content: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                        await _deleteImage(kategoriitem.resimurl);
                      } catch (e) {
                        print('Görsel silme hatası: $e');
                        Navigator.pop(context);
                      }
                    }

                    await _uploadImage(updatedKategoriModel);
                    Navigator.pop(context);
                  }

                  setState(() {
                    _uploadProgress = 0.0;
                  });

                  try {
                    await _KategoriModelsCollection.doc(kategoriitem.id)
                        .update(updatedKategoriModel.toMap());

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

  _showAddKategoriModelDialog(items) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          double _uploadProgress = 0.0; // Progress indicator value
          var yenitip = yenitipkontrol(items);
          _categoryController.text = yenitip.toString();
          print('yenitip' + yenitip.toString());
          return AlertDialog(
            title: Text('Yeni KategoriModel Ekle'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'baslik',
                    ),
                  ),
                  TextField(
                    controller: _oncelikkategori,
                    decoration: InputDecoration(
                      labelText: '“Öncelik No (en düşük, en önce)',
                    ),
                  ),
                  ElevatedButton(
                    child: Text('Görsel Seç'),
                    onPressed: () {
                      _selectImage();
                    },
                  ),

                  // ... the rest of your dialog children
                  ElevatedButton(
                    child: Text('Ekle'),
                    onPressed: _isUploading
                        ? null
                        : () async {
                            final kategoriitemo = KategoriModel(
                                oncelik: _oncelikkategori.text,
                                id: "",
                                baslik: _nameController.text,
                                resimurl: _resimUrlController.text,
                                tip: _categoryController.text);

                            // Resim ve ses seçildiyse yükle
                            if (_selectedImage != null) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Görsel Yükleniyor'),
                                    content: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
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

                              await _uploadImage(kategoriitemo);
                              Navigator.pop(context);
                            }

                            setState(() {
                              _uploadProgress = 0.0;
                            });

                            await _KategoriModelsCollection.add(
                                kategoriitemo.toMap());
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
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
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

  void _selectImage() {
    final input = html.FileUploadInputElement();
    input.accept = 'image/*';
    input.click();
    input.onChange.listen((event) {
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        _selectedImage = files[0];
      }
    });
  }

  void _selectAudio() {
    final input = html.FileUploadInputElement();
    input.accept = 'audio/*';
    input.click();
    input.onChange.listen((event) {
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        _selectedAudio = files[0];
      }
    });
  }

  Future<void> _uploadImage(KategoriModel KategoriModel) async {
    final storage = firebase_storage.FirebaseStorage.instance;
    final storageRef = storage.ref();
    final imagePath =
        'KategoriModels/${DateTime.now().microsecondsSinceEpoch}.jpg';

    final reader = html.FileReader();
    reader.readAsArrayBuffer(_selectedImage!);

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
      filePath: _selectedImage!.name,
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
    KategoriModel.resimurl = imageUrl.toString();
  }

/* 
  Future<void> _uploadImage(KategoriModel KategoriModel) async {
    final storage = firebase_storage.FirebaseStorage.instance;
    final storageRef = storage.ref();
    final imagePath =
        'KategoriModels/${DateTime.now().microsecondsSinceEpoch}.jpg';
    final uploadTask = storageRef.child(imagePath).putBlob(_selectedImage!);

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
    KategoriModel.resimurl = imageUrl.toString();
  }
 */
  void _showDeleteKategoriModelDialog(KategoriModel KategoriModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('KategoriModel Sil'),
          content: Text(
              "${KategoriModel.baslik} adlı KategoriModel'ı silmek istediğinize emin misiniz?'"),
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
                  await _deleteImage(KategoriModel.resimurl);
                } catch (e) {}

                await _KategoriModelsCollection.doc(KategoriModel.id).delete();
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

class KategoriModel {
  final String baslik;
  String resimurl;
  String oncelik;

  final String id;
  final String tip;

  KategoriModel({
    required this.oncelik,
    required this.tip,
    required this.baslik,
    required this.resimurl,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'baslik': baslik,
      'id': baslik,
      'resimurl': resimurl,
      'tip': tip,
      'oncelik': oncelik,
    };
  }

  factory KategoriModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return KategoriModel(
      oncelik: data['oncelik'],
      tip: data['tip'],
      id: doc.id,
      baslik: data['baslik'],
      resimurl: data['resimurl'],
    );
  }
}
