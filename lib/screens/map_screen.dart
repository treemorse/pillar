import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pillar/reusable_widgets/reusable_widget.dart';
import 'package:pillar/screens/signin_screen.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const YandexMap(),
          Positioned(
            bottom: -10,
            child: firebaseUIButton(
              context,
              'Log out',
              () {
                FirebaseAuth.instance.signOut().then((value) {
                  // ignore: avoid_print
                  print("Signed Out");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignInScreen(),
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
