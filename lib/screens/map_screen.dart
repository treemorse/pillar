import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const YandexMap(),
        Positioned(
          bottom: 0,
          right: 16,
          height: 60,
          child: FloatingActionButton(
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
