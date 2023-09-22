import 'dart:html' as html;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_compression/image_compression.dart';
import 'package:panelmeditasyon/kategori.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

import 'package:image_compression/image_compression.dart';

class MeditationListPage extends StatefulWidget {
  const MeditationListPage({Key? key}) : super(key: key);

  @override
  _MeditationListPageState createState() => _MeditationListPageState();
}

class _MeditationListPageState extends State<MeditationListPage> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _oncelikController = TextEditingController();

  final TextEditingController _creatorController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _resimUrlController = TextEditingController();
  final TextEditingController _sesUrlController =
      TextEditingController(); // Add this line
  bool _isPro = false;
  bool _isonecikan = false;
  bool _aktif = false;

  html.File? _selectedImage;
  html.File? _selectedAudio;
  double _uploadProgress = 0.0;
  bool _isUploading = false;
  KategoriModel? _selectedcat;
  late CollectionReference _meditationsCollection;
  late CollectionReference _kategoriModelsCollection;
  var category = <KategoriModel>[];
  var meditations = <Meditation>[];
  KategoriModel? getMatchingCategory(
      List<KategoriModel> kategoriler, Meditation meditasyon) {
    return kategoriler.firstWhere((kategori) => kategori.tip == meditasyon.tip,
        orElse: () => kategoriler[0]);
  }

  Future<void> categorycek() async {
    _kategoriModelsCollection =
        FirebaseFirestore.instance.collection('category');
    category = await _kategoriModelsCollection.get().then((querySnapshot) =>
        querySnapshot.docs
            .map((doc) => KategoriModel.fromFirestore(doc))
            .toList());

    category
        .sort((a, b) => int.parse(a.oncelik).compareTo(int.parse(b.oncelik)));
  }

  String categoriisimc(String tip) {
    for (var i = 0; i < category.length; i++) {
      if (category[i].tip == tip) {
        return category[i].baslik!;
      }
    }
    return '';
  }

  List<Widget> buildCategoryLists(List<Meditation> meditations) {
    print(meditations);
    print("meditations");
    List<Widget> categoryLists = [];

    try {
      // Kategori tiplerini alın
      List<String> categoryTypes = meditations
          .map((meditation) => meditation.tip)
          .where((tip) => tip != null)
          .toSet()
          .toList();

      print(categoryTypes);
      print("categoryTypes");

      // Kategori gruplarını oluşturun
      for (KategoriModel kategori in category) {
        // Kategoriye ait meditasyonları filtreleyin
        List<Meditation> categoryMeditations = meditations
            .where((meditation) => meditation.tip == kategori.tip)
            .toList();

        // Kategori başlığını oluşturun
        Widget categoryTitle = Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            kategori.baslik!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        );

        // ListView.builder oluşturun
        Widget categoryListView = ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: categoryMeditations.length,
          separatorBuilder: (context, index) => SizedBox(height: 8),
          itemBuilder: (context, index) {
            final meditation = categoryMeditations[index];
            if (meditation.resimurl != null) {
              return InkWell(
                onTap: () {
                  _showEditMeditationDialog(meditation);
                },
                child: Card(
                  elevation: 3,
                  child: ListTile(
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image:
                              CachedNetworkImageProvider(meditation.resimurl!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(
                      meditation.baslik ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'tip: ${categoriisimc(meditation.tip!)} - ${meditation.tip}'),
                        Text('Kimden: ${meditation.kimden ?? ''}'),
                        Text('Süre: ${meditation.dakika ?? ''} dakika'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _showDeleteMeditationDialog(meditation);
                      },
                    ),
                  ),
                ),
              );
            } else {
              return SizedBox.shrink();
            }
          },
        );

        // Kategori başlığını ve ListView.builder'ı birleştirin
        Widget categoryList = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            categoryTitle,
            categoryListView,
          ],
        );

        // Kategori listesini ekle, ancak boşsa uyarı ver
        if (categoryMeditations.isNotEmpty) {
          categoryLists.add(categoryList);
        } else {
          categoryLists.add(
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Bu kategoriye ait meditasyon bulunamadı.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('Hata: $e\nStackTrace: $stackTrace');
      // Hata durumunda uygun bir hata mesajı gösterilebilir veya gerekli işlemler yapılabilir
    }

    return categoryLists;
  }

  DateTime now = DateTime.now();
  String formattedDate = "000";
  @override
  void initState() {
    super.initState();
    categorycek();
    _meditationsCollection = FirebaseFirestore.instance.collection('meds');
  }

  @override
  Widget build(BuildContext context) {
    now = DateTime.now();
    formattedDate = DateFormat('yyyy-MM-dd').format(now);

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _meditationsCollection.snapshots(),
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
                    child: Text('Meditation bulunamadı.'),
                  );
                }

                meditations = snapshot.data!.docs
                    .map((doc) => Meditation.fromFirestore(doc))
                    .toList();
                List<Widget> categoryLists = buildCategoryLists(meditations);

                try {
                  return Container(
                      child: ListView(
                    children: categoryLists,
                  ));
                } catch (e) {
                  return Center(
                    child: Text('Liste oluşturulurken bir hata oluştu: $e'),
                  );
                }
              },
            ),
          ),
          ElevatedButton(
            child: Text('Yeni Meditation Ekle'),
            onPressed: () {
              _showAddMeditationDialog(meditations);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _updateAudio(Meditation meditation) async {
    final storage = firebase_storage.FirebaseStorage.instance;
    final storageRef = storage.ref();
    final audioPath =
        'meditations/${DateTime.now().microsecondsSinceEpoch}.mp3';
    final uploadTask = storageRef.child(audioPath).putBlob(_selectedAudio!);

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

    final audioUrl = await snapshot.ref.getDownloadURL();
    meditation.sesurl = audioUrl.toString();
  }

  void _showEditMeditationDialog(Meditation meditation) {
    KategoriModel? _selectedcat = getMatchingCategory(category, meditation);

    _categoryController.text = meditation.tip;
    _nameController.text = meditation.baslik;
    _creatorController.text = meditation.kimden;
    _durationController.text = meditation.dakika;
    _isPro = meditation.premium == "1" ? true : false;
    _isonecikan = meditation.onecikan == "1" ? true : false;
    _aktif = meditation.aktif == "1" ? true : false;
    _oncelikController.text = meditation.oncelik;

    _resimUrlController.text = meditation.resimurl;
    _sesUrlController.text = meditation.sesurl;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          double _uploadProgress = 0.0; // Progress indicator value

          return AlertDialog(
            title: Text('Meditation Düzenle'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DropdownButtonFormField<KategoriModel>(
                    value: _selectedcat,
                    items: category.map((KategoriModel value) {
                      return DropdownMenuItem<KategoriModel>(
                        value: value,
                        child: Text(value.baslik!),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: "Grup",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedcat = value;
                        _categoryController.text = _selectedcat!.tip.toString();
                      });
                    },
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Meditation Adı',
                    ),
                  ),
                  TextField(
                    controller: _oncelikController,
                    decoration: InputDecoration(
                      labelText: '“Öncelik No(en düşük, en önce)',
                    ),
                  ),
                  TextField(
                    controller: _creatorController,
                    decoration: InputDecoration(
                      labelText: 'Seslendiren',
                    ),
                  ),
                  TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Süre (dakika)',
                    ),
                  ),
                  Row(
                    children: [
                      Text('Pro?'),
                      Switch(
                        value: _isPro,
                        onChanged: (value) {
                          setState(() {
                            _isPro = value;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Öne çıkan?'),
                      Switch(
                        value: _isonecikan,
                        onChanged: (value) {
                          setState(() {
                            _isonecikan = value;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Aktif?'),
                      Switch(
                        value: _aktif,
                        onChanged: (value) {
                          setState(() {
                            _aktif = value;
                          });
                        },
                      ),
                    ],
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
                      '“Kaydedilmiş Görsel için tıklayın',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onTap: () {
                      launch(_resimUrlController.text);
                    },
                  ),
                  Image.network(
                    _resimUrlController.text,
                    height: 300,
                    width: 300,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    child: Text('Ses Seç'),
                    onPressed: () {
                      _selectAudio();
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    child: Text(
                      'Kaydedilmiş ses dinlemek için tıklayın',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onTap: () {
                      launch(_sesUrlController.text);
                    },
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
                  final updatedMeditation = Meditation(
                    tarih: formattedDate.toString(),
                    oncelik: _oncelikController.text,
                    aktif: _aktif ? "1" : "0",
                    id: meditation.id,
                    tip: _categoryController.text,
                    baslik: _nameController.text,
                    kimden: _creatorController.text,
                    dakika: _durationController.text,
                    premium: _isPro ? "1" : "0",
                    onecikan: _isonecikan ? "1" : "0",
                    resimurl: _resimUrlController.text,
                    sesurl: _sesUrlController.text,
                  );

                  if (_selectedImage != null) {
                    // Delete previous image if exists
                    if (meditation.resimurl.isNotEmpty) {
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
                                    'Önceki Görsel siliniyor. Lütfen bekleyin...'),
                                LinearProgressIndicator(
                                  value: _uploadProgress,
                                ),
                              ],
                            ),
                          );
                        },
                      );

                      try {
                        await _deleteImage(meditation.resimurl);
                      } catch (e) {
                        print('Görsel silme hatası: $e');
                        Navigator.pop(context);
                      }
                    }

                    await _uploadImage(updatedMeditation);
                    Navigator.pop(context);
                  }

                  if (_selectedAudio != null) {
                    if (meditation.sesurl.isNotEmpty) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(' Ses Ekleniyor'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    'Önceki ses siliniyor. Lütfen bekleyin...'),
                                LinearProgressIndicator(
                                  value: _uploadProgress,
                                ),
                              ],
                            ),
                          );
                        },
                      );

                      try {
                        await _deleteAudio(meditation.sesurl);
                      } catch (e) {
                        print('Ses silme hatası: $e');
                        Navigator.pop(context);
                      }
                    }

                    await _uploadAudio(updatedMeditation);
                    Navigator.pop(context);
                  }

                  setState(() {
                    _uploadProgress = 0.0;
                  });

                  try {
                    await _meditationsCollection
                        .doc(meditation.id)
                        .update(updatedMeditation.toMap());

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

  void _showAddMeditationDialog(List<Meditation> meditations) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          double _uploadProgress = 0.0; // Progress indicator value

          return AlertDialog(
            title: Text('Yeni Meditation Ekle'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  //  dropdown menu for meditations
                  DropdownButtonFormField<KategoriModel>(
                    value: _selectedcat,
                    items: category.map((KategoriModel value) {
                      return DropdownMenuItem<KategoriModel>(
                        value: value,
                        child: Text(value.baslik!),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: "Grup",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedcat = value;
                      });
                    },
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Meditation Adı',
                    ),
                  ),
                  TextField(
                    controller: _oncelikController,
                    decoration: InputDecoration(
                      labelText: '“Öncelik No(en düşük, en önce)',
                    ),
                  ),
                  TextField(
                    controller: _creatorController,
                    decoration: InputDecoration(
                      labelText: 'Seslendiren',
                    ),
                  ),
                  TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Süre (dakika)',
                    ),
                  ),
                  Row(
                    children: [
                      Text('Pro?'),
                      Switch(
                        value: _isPro,
                        onChanged: (value) {
                          setState(() {
                            _isPro = value;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Öneçıkan?'),
                      Switch(
                        value: _isonecikan,
                        onChanged: (value) {
                          setState(() {
                            _isonecikan = value;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Aktif?'),
                      Switch(
                        value: _aktif,
                        onChanged: (value) {
                          setState(() {
                            _aktif = value;
                          });
                        },
                      ),
                    ],
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
                  ElevatedButton(
                    child: Text('Ses Seç'),
                    onPressed: () {
                      _selectAudio();
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  // ... the rest of your dialog children
                  ElevatedButton(
                    child: Text('Ekle'),
                    onPressed: _isUploading
                        ? null
                        : () async {
                            final meditation = Meditation(
                              tarih: formattedDate.toString(),
                              oncelik: _oncelikController.text,
                              id: '',
                              tip: _selectedcat!.tip.toString(),
                              baslik: _nameController.text,
                              kimden: _creatorController.text,
                              dakika: _durationController.text,
                              premium: _isPro ? "1" : "0",
                              resimurl: '',
                              sesurl: '',
                              onecikan: _isonecikan ? "1" : "0",
                              aktif: _aktif ? "1" : "0",
                            );

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

                              await _uploadImage(meditation);
                              Navigator.pop(context);
                            }
                            if (_selectedAudio != null) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Ses Yükleniyor'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                            'Ses yükleniyor. Lütfen bekleyin...'),
                                        LinearProgressIndicator(
                                          value: _uploadProgress,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );

                              await _uploadAudio(meditation);
                              Navigator.pop(context);
                            }

                            setState(() {
                              _uploadProgress = 0.0;
                            });

                            DocumentReference newDocRef =
                                await _meditationsCollection
                                    .add(meditation.toMap());
                            String meditasyonId = newDocRef.id;
                            meditation.id = meditasyonId;
                            await newDocRef.update(meditation.toMap());
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

  void _selectImage() {
    final html.FileUploadInputElement uploadInput =
        html.FileUploadInputElement();
    uploadInput.accept = 'image/*'; // Sadece resim dosyalarını seçmesini sağlar
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.length > 0) {
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

  Future<void> _uploadImage(Meditation meditation) async {
    final storage = firebase_storage.FirebaseStorage.instance;
    final storageRef = storage.ref();
    final imagePath =
        'meditations/${DateTime.now().microsecondsSinceEpoch}.jpg';

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
    meditation.resimurl = imageUrl.toString();
  }

  Future<void> _uploadAudio(Meditation meditation) async {
    final storage = firebase_storage.FirebaseStorage.instance;
    final storageRef = storage.ref();
    final audioPath =
        'meditations/${DateTime.now().microsecondsSinceEpoch}.mp3';
    final uploadTask = storageRef.child(audioPath).putBlob(_selectedAudio!);

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

    final audioUrl = await snapshot.ref.getDownloadURL();
    meditation.sesurl = audioUrl.toString();
  }

  void _showDeleteMeditationDialog(Meditation meditation) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Meditation Sil'),
          content: Text(
              "${meditation.baslik} adlı Meditation'ı silmek istediğinize emin misiniz?'"),
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
                  await _deleteImage(meditation.resimurl);
                } catch (e) {}
                try {
                  await _deleteAudio(meditation.sesurl);
                } catch (e) {}
                await _meditationsCollection.doc(meditation.id).delete();
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

class Meditation {
  final String baslik;
  final String aktif;
  final String tarih;
  final String oncelik;

  final String dakika;
  final String kimden;
  String resimurl;
  String sesurl;
  final String onecikan;
  String id;
  final String tip;
  final String premium;

  Meditation({
    required this.aktif,
    required this.tarih,
    required this.oncelik,
    required this.tip,
    required this.baslik,
    required this.dakika,
    required this.kimden,
    required this.resimurl,
    required this.sesurl,
    required this.onecikan,
    required this.premium,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tarih': tarih,
      'oncelik': oncelik,
      'baslik': baslik,
      'dakika': dakika,
      'kimden': kimden,
      'resimurl': resimurl,
      'sesurl': sesurl,
      'onecikan': onecikan,
      'tip': tip,
      'premium': premium,
      'aktif': aktif,
    };
  }

  factory Meditation.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Meditation(
      aktif: data['aktif'] ?? '',
      tarih: data['tarih'] ?? '',
      oncelik: data['oncelik'] ?? '',
      premium: data['premium'] ?? '',
      tip: data['tip'] ?? '',
      id: doc.id,
      baslik: data['baslik'] ?? '',
      dakika: data['dakika'] ?? '',
      kimden: data['kimden'] ?? '',
      resimurl: data['resimurl'] ?? '',
      sesurl: data['sesurl'] ?? '',
      onecikan: data['onecikan'] ?? '',
    );
  }
}
