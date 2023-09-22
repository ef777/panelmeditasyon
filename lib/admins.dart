import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAdminModelsPage extends StatefulWidget {
  const AdminAdminModelsPage({Key? key}) : super(key: key);

  @override
  _AdminAdminModelsPageState createState() => _AdminAdminModelsPageState();
}

class _AdminAdminModelsPageState extends State<AdminAdminModelsPage> {
  late CollectionReference _adminModelsCollection;

  @override
  void initState() {
    super.initState();
    _adminModelsCollection = FirebaseFirestore.instance.collection('admins');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _showAddAdminModelDialog,
      ),
      body: Center(
          child: StreamBuilder<QuerySnapshot>(
        stream: _adminModelsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Bir hata oluştu: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final adminModels = snapshot.data!.docs
              .map((doc) => AdminModel.fromFirestore(doc))
              .toList();

          var isLargeScreen = MediaQuery.of(context).size.width > 600;
          if (!isLargeScreen) {
            return ListView.builder(
              itemCount: adminModels.length,
              itemBuilder: (context, index) {
                final adminModel = adminModels[index];

                return AdminModelTile(
                  adminModel: adminModel,
                  onPasswordChange: (newPassword) =>
                      _updatePassword(adminModel, newPassword),
                  onDelete: () => _deleteAdmin(adminModel),
                );
              },
            );
          } else {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Center(
                  child: Padding(
                padding: EdgeInsets.all(16),
                child: DataTable(
                  headingRowColor: MaterialStateColor.resolveWith(
                      (states) => Colors.grey[300]!),
                  dataRowColor:
                      MaterialStateColor.resolveWith((states) => Colors.white),
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
                        'Edit',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Delete',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  rows: adminModels.map((adminModel) {
                    final name = adminModel.name;
                    final email = adminModel.email;

                    return DataRow(
                      cells: <DataCell>[
                        DataCell(
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              name,
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
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () =>
                                _showPasswordChangeDialog(context, adminModel),
                          ),
                        ),
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteAdmin(adminModel),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              )),
            );
          }
        },
      )),
    );
  }

  void _showAddAdminModelDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _nameController = TextEditingController();
        final TextEditingController _passwordController =
            TextEditingController();
        final TextEditingController _emailController = TextEditingController();

        return AlertDialog(
          title: Text('Add User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Add'),
              onPressed: () {
                final adminModel = AdminModel(
                  id: '',
                  name: _nameController.text,
                  password: _passwordController.text,
                  email: _emailController.text,
                );
                _addAdmin(adminModel);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addAdmin(AdminModel adminModel) async {
    await _adminModelsCollection.add(adminModel.toMap());
  }

  void _updatePassword(AdminModel adminModel, String newPassword) async {
    await _adminModelsCollection
        .doc(adminModel.id)
        .update({'password': newPassword});
  }

  void _deleteAdmin(AdminModel adminModel) async {
    await _adminModelsCollection.doc(adminModel.id).delete();
  }

  void _showPasswordChangeDialog(BuildContext context, AdminModel adminModel) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _newPasswordController =
            TextEditingController();

        return AlertDialog(
          title: Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                _updatePassword(adminModel, _newPasswordController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class AdminModelTile extends StatelessWidget {
  final AdminModel adminModel;
  final Function(String) onPasswordChange;
  final VoidCallback onDelete;

  const AdminModelTile({
    Key? key,
    required this.adminModel,
    required this.onPasswordChange,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(adminModel.name),
      subtitle: Text(adminModel.email),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _showPasswordChangeDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }

  void _showPasswordChangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _newPasswordController =
            TextEditingController();

        return AlertDialog(
          title: Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                onPasswordChange(_newPasswordController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class AdminModel {
  final String id;
  final String name;
  final String password;
  final String email;

  AdminModel({
    required this.id,
    required this.name,
    required this.password,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'password': password,
      'email': email,
    };
  }

  factory AdminModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminModel(
      id: doc.id,
      name: data['name'],
      password: data['password'],
      email: data['email'],
    );
  }
}
