import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
// ignore: library_prefixes
import 'package:latlong2/latlong.dart' as latLong;
import 'package:pillar/reusable_widgets/reusable_widget.dart';
import 'package:pillar/screens/profile_screen.dart';

import 'lesson_builder_screen.dart';
import 'lesson_view_screen.dart';

class MapBoxScreen extends StatefulWidget {
  const MapBoxScreen({Key? key}) : super(key: key);
  @override
  State<MapBoxScreen> createState() => _MapBoxScreenState();
}

class _MapBoxScreenState extends State<MapBoxScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore store = FirebaseFirestore.instance;
  bool _isFollower = false;

  changeSetting(bool value) {
    setState(() {
      _isFollower = value;
    });
  }

  void getProfile() async {
    final User user = auth.currentUser!;
    final userid = user.uid;
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

  Future<List<Marker>> createMarkers() async {
    var lessons = await store.collection('lessons').get();
    List<Marker> _markers = [];
    final User user = auth.currentUser!;
    final userid = user.uid;
    final userInfo = await store.collection('users').doc(userid).get();
    for (var element in lessons.docs) {
      if (element['creator'] != auth.currentUser!.uid) {
        final otherInfo =
            await store.collection('users').doc(element['creator']).get();
        if ((userInfo.data()!['following'].contains(element['creator']) ||
                !_isFollower) &&
            userInfo.data()!['isInstructor'] ==
                !otherInfo.data()!['isInstructor']) {
          var lalo = element['location'].split(", ");
          latLong.LatLng location =
              latLong.LatLng(double.parse(lalo[0]), double.parse(lalo[1]));
          _markers.add(
            Marker(
              width: 50.0,
              height: 50.0,
              point: location,
              builder: (context) => IconButton(
                icon: const Icon(Icons.location_on),
                color: const Color.fromARGB(255, 255, 0, 0),
                iconSize: 45.0,
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          LessonViewScreen(lessonId: element['lid']),
                    ),
                  );
                },
              ),
            ),
          );
        }
      }
    }
    return _markers;
  }

  initializeAll() async {
    var _marks = await createMarkers();
    var _pos = await _getPosition();
    return [_marks, _pos];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
              future: initializeAll(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  var _marks = (snapshot.data! as dynamic)[0] as List<Marker>;
                  var _pos = (snapshot.data! as dynamic)[1] as Position;
                  return FlutterMap(
                    options: MapOptions(
                      center: latLong.LatLng(_pos.latitude, _pos.longitude),
                      zoom: 17.0,
                    ),
                    layers: [
                      TileLayerOptions(
                        urlTemplate:
                            "https://api.mapbox.com/styles/v1/treemorse/cl40lew4s000p14me7yes8d8n/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoidHJlZW1vcnNlIiwiYSI6ImNsNDBrZHMwcDI1NjYzam5wcHZ0NmFzNXoifQ._GQ8Yu9vaJ1X11KaxfgJFA",
                        additionalOptions: {
                          'accessToken':
                              'sk.eyJ1IjoidHJlZW1vcnNlIiwiYSI6ImNsNDBraHhvdzA3ZHMzZG52bXRlN2U2cTgifQ.fNTKe4R4ocLDGy4DVpOjnQ',
                          'id': 'mapbox.mapbox-streets-v8',
                        },
                      ),
                      MarkerLayerOptions(
                        markers: [
                              Marker(
                                width: 80.0,
                                height: 80.0,
                                point: latLong.LatLng(
                                  _pos.latitude,
                                  _pos.longitude,
                                ),
                                builder: (context) => IconButton(
                                  icon: const Icon(Icons.my_location_outlined),
                                  color: const Color.fromARGB(255, 25, 0, 255),
                                  iconSize: 45.0,
                                  onPressed: () {
                                    // ignore: avoid_print
                                    print("Marker tapped");
                                  },
                                ),
                              ),
                            ] +
                            (_marks),
                      ),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.only(top: 40, left: 25),
              child: Column(
                children: [
                  const Text(
                    "Known",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: _isFollower,
                    onChanged: (bool value) => changeSetting(value),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.only(top: 30, right: 20),
              child: IconButton(
                iconSize: 70,
                icon: const Icon(
                  Icons.person,
                  color: Colors.black,
                ),
                onPressed: () => getProfile(),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
              child: firebaseUIButton(
                context,
                "Lesson Builder",
                () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LessonBuilderScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Position> _getPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }
}
