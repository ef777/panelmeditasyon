import 'package:cloud_firestore/cloud_firestore.dart';

class Document {
  final String title;
  final String minutes;
  final String category;
  final String author;
  final String imageUrl;
  final String soundUrl;

  Document({
    required this.title,
    required this.minutes,
    required this.category,
    required this.author,
    required this.imageUrl,
    required this.soundUrl,
  });

  factory Document.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Document(
      title: data['baslik'],
      minutes: data['dakika'],
      category: data['kategori'],
      author: data['kimden'],
      imageUrl: data['resimurl'],
      soundUrl: data['sesurl'] ?? '',
    );
  }
}

final firestoreInstance = FirebaseFirestore.instance;

Future<List<Document>> fetchDocuments() async {
  QuerySnapshot querySnapshot =
      await firestoreInstance.collection('meds').get();
  List<Document> documents = [];

  if (querySnapshot.docs.isNotEmpty) {
    querySnapshot.docs.forEach((doc) {
      documents.add(Document.fromFirestore(doc));
    });
  }

  return documents;
}
