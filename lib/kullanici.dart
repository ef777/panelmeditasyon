import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kullanıcılar'),
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }

            final users = snapshot.data!.docs;

            var isLargeScreen = MediaQuery.of(context).size.width > 600;

            if (isLargeScreen) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: DataTable(
                    headingRowColor: MaterialStateColor.resolveWith(
                        (states) => Colors.grey[300]!),
                    dataRowColor: MaterialStateColor.resolveWith(
                        (states) => Colors.white),
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Text(
                          'Name',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Email',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Premium',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'İletişim Onayı',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                    rows: users.map((user) {
                      final userData = user.data() as Map<String, dynamic>;
                      final email = userData['email'];
                      final isPremium = userData['premium'] ?? false;
                      final isOfferAccepted = userData['teklif'] ?? false;

                      return DataRow(
                        cells: <DataCell>[
                          DataCell(
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                userData['name'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          DataCell(
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(email),
                            ),
                          ),
                          DataCell(
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(isPremium ? "Evet" : "Hayır"),
                            ),
                          ),
                          DataCell(
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(isOfferAccepted ? "Evet" : "Hayır"),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final userData = users[index].data() as Map<String, dynamic>;
                  final email = userData['email'];
                  final isPremium = userData['premium'] ?? false;
                  final isOfferAccepted = userData['teklif'] ?? false;

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    elevation: 2,
                    child: ListTile(
                      title: Text(
                        userData['name'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text(
                            'Email: $email',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Premium: ${isPremium ? "Evet" : "Hayır"}',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'İletişim Onayı: ${isOfferAccepted ? "Evet" : "Hayır"}',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
