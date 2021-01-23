import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vijay',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
        splash: Image.asset('assets/homework.png'
        ),
        nextScreen: HomePage(),
        splashTransition: SplashTransition.fadeTransition,
        backgroundColor: Colors.amber[900],
        duration: 2000,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final db = FirebaseFirestore.instance;
  String task;
  void showdialog() {
    GlobalKey<FormState> formkey = GlobalKey<FormState>();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add TODO'),
            content: Form(
              key: formkey,
              autovalidate: true,
              child: TextFormField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(), labelText: "Task"),
                validator: (_val) {
                  if (_val.isEmpty) {
                    return "Can't be Empty";
                  } else {
                    return null;
                  }
                },
                onChanged: (_val) {
                  task = _val;
                },
              ),
            ),
            actions: [
              RaisedButton(
                onPressed: () {
                  db.collection('task').add({'task': task});
                  Navigator.pop(context);
                },
                child: Text("add"),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: showdialog,
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text('Tasks'),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: db.collection('task').snapshots(),
          builder: (context, snapshots) {
            if (snapshots.hasData) {
              return ListView.builder(
                itemCount: snapshots.data.documents.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshots.data.documents[index];
                  return Container(
                    child: ListTile(
                      title: Text(ds['task']),
                      onLongPress: () {
                        db.collection('task').document(ds.documentID).delete();
                      },
                      onTap: () {
                        db
                            .collection('task')
                            .doc(ds.documentID)
                            .updateData({'task': "Work Done"});
                      },
                    ),
                  );
                },
              );
            } else if (snapshots.hasError) {
              return LinearProgressIndicator();
            } else {
              return LinearProgressIndicator();
            }
          }),
    );
  }
}
