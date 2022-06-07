import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pillar/reusable_widgets/reusable_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:pillar/models/lesson.dart' as model;
import 'location_ picker_screen.dart';
import 'mapbox_screen.dart';

class LessonBuilderScreen extends StatefulWidget {
  const LessonBuilderScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LessonBuilderScreenState();
  }
}

class LessonBuilderScreenState extends State<LessonBuilderScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _id;
  String? _description;
  String? _type;
  String? _time;
  String? _price;

  var uuid = const Uuid();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  addLesson() async {
    setState(() {
      _id = uuid.v1();
    });
    model.Lesson _lesson = model.Lesson(
      lid: _id!,
      creator: FirebaseAuth.instance.currentUser!.uid,
      location: "",
      description: _description!,
      type: _type!,
      time: _time!,
      price: _price!,
      interested: [],
    );
    await _firestore.collection("lessons").doc(_id!).set(_lesson.toJson());
  }

  Widget _buildDesc() {
    return TextFormField(
      minLines: 3,
      maxLines: 6,
      maxLength: 100,
      decoration: const InputDecoration(labelText: 'Description'),
      validator: (String? value) {
        if (value == "") {
          return 'Description is Required';
        }
        return null;
      },
      onSaved: (String? value) {
        _description = value;
      },
    );
  }

  Widget _buildType() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Type'),
      validator: (String? value) {
        if (value == "") {
          return 'Type is Required';
        }
        return null;
      },
      onSaved: (String? value) {
        _type = value;
      },
    );
  }

  Widget _buildTime() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Time',
      ),
      validator: (String? value) {
        if (value == "") {
          return 'Time is Required';
        }
        return null;
      },
      onSaved: (String? value) {
        _time = value;
      },
    );
  }

  Widget _buildPrice() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Price'),
      validator: (String? value) {
        if (value == "") {
          return 'Price is Required';
        }
        return null;
      },
      onSaved: (String? value) {
        _price = value;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var _pageSize = MediaQuery.of(context).size.height;
    var _notifySize = MediaQuery.of(context).padding.top;
    var _appBarSize = AppBar().preferredSize.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MapBoxScreen(),
            ),
          ),
        ),
        title: const Text("Lesson Builder"),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: _pageSize - (_appBarSize + _notifySize),
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                _buildDesc(),
                _buildType(),
                _buildTime(),
                _buildPrice(),
                Expanded(child: Container()),
                firebaseUIButton(
                  context,
                  'Submit',
                  () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    _formKey.currentState!.save();
                    addLesson();

                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => LocationPickerScreen(id: _id!),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
