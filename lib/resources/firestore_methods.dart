import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  makeInstructor(bool isInstructor, String id) async {
    if (isInstructor) {
      await _firestore
          .collection('users')
          .doc(id)
          .update({'isInstructor': true});
    } else {
      await _firestore
          .collection('users')
          .doc(id)
          .update({'isInstructor': false});
    }
  }

  likeLesson(String lid, String uid) async {
    DocumentSnapshot snap =
        await _firestore.collection('lessons').doc(lid).get();
    List interested = (snap.data()! as dynamic)['interested'];

    if (interested.contains(uid)) {
      await _firestore.collection('lessons').doc(lid).update({
        'interested': FieldValue.arrayRemove([uid])
      });
    } else {
      await _firestore.collection('lessons').doc(lid).update({
        'interested': FieldValue.arrayUnion([uid])
      });
    }
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print(e.toString());
    }
  }
}