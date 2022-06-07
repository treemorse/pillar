// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
// ignore: library_prefixes
import 'package:latlong2/latlong.dart' as latLong;
import '../reusable_widgets/reusable_widget.dart';
import 'mapbox_screen.dart';

extension LatLngString on latLong.LatLng {
  String toStringCoordinates() => '$latitude, $longitude';
}

// ignore: must_be_immutable
class LocationPickerScreen extends StatefulWidget {
  String id;
  LocationPickerScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  Future? _pos;
  MapController? _mapController;
  latLong.LatLng? _lesPos;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    _pos = _getPosition();
    _mapController = MapController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick location")),
      body: FutureBuilder(
        future: _pos,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: latLong.LatLng(
                      snapshot.data.latitude,
                      snapshot.data.longitude,
                    ),
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
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: const Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding:
                        const EdgeInsets.only(bottom: 40, left: 20, right: 20),
                    child: firebaseUIButton(
                      context,
                      "Submit",
                      () {
                        saveLocation();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const MapBoxScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  saveLocation() async {
    setState(() {
      _lesPos = _mapController!.center;
    });
    await _firestore
        .collection('lessons')
        .doc(widget.id)
        .update({'location': _lesPos!.toStringCoordinates()});
    // ignore: avoid_print
    print(_lesPos!.toStringCoordinates());
  }

  Future<Position> _getPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }
}
