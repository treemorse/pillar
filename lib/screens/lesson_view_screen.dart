import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pillar/reusable_widgets/reusable_widget.dart';

import 'mapbox_screen.dart';
import 'profile_screen.dart';

class LessonViewScreen extends StatefulWidget {
  final String lessonId;
  const LessonViewScreen({Key? key, required this.lessonId}) : super(key: key);

  @override
  State<LessonViewScreen> createState() => _LessonViewScreenState();
}

class _LessonViewScreenState extends State<LessonViewScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore store = FirebaseFirestore.instance;

  void getProfile(String userid) async {
    final userInfo = await store.collection('users').doc(userid).get();
    final isInst = userInfo.data()!['isInstructor'];
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          uid: userid,
          isInstructor: isInst,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('lessons')
          .doc(widget.lessonId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var lesson = snapshot.data! as dynamic;
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: lesson['creator'] == auth.currentUser!.uid
                    ? () {
                        User user = auth.currentUser!;
                        String userid = user.uid;
                        getProfile(userid);
                      }
                    : () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const MapBoxScreen(),
                          ),
                        );
                      },
                icon: const Icon(Icons.arrow_back),
              ),
              title: const Text("Lesson Info"),
            ),
            body: Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Type: \n" + lesson['type'],
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Description: \n" + lesson['description'],
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Duration: \n" + lesson['time'],
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Price: \n" + lesson['price'],
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                  Expanded(child: Container()),
                  lesson['creator'] == auth.currentUser!.uid
                      ? firebaseUIButton(
                          context,
                          "Delete lesson",
                          () {
                            FirebaseFirestore.instance.runTransaction(
                                (Transaction myTransaction) async {
                              myTransaction.delete(lesson.reference);
                              User user = auth.currentUser!;
                              String userid = user.uid;
                              getProfile(userid);
                            });
                          },
                        )
                      : FittedBox(
                          fit: BoxFit.fill,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              firebaseUIButton(
                                context,
                                "Contact creator",
                                () {
                                  String userid = lesson['creator'];
                                  getProfile(userid);
                                },
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
