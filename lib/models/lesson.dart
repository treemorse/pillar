import 'package:cloud_firestore/cloud_firestore.dart';

class Lesson {
  final String lid;
  final String creator;
  final String location;
  final String description;
  final String type;
  final String time;
  final String price;
  final List interested;

  const Lesson({
    required this.lid,
    required this.creator,
    required this.location,
    required this.description,
    required this.type,
    required this.time,
    required this.price,
    required this.interested,
  });

  static Lesson fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Lesson(
      lid: snapshot["lid"],
      creator: snapshot["creator"],
      location: snapshot["location"],
      description: snapshot["description"],
      type: snapshot["type"],
      time: snapshot["time"],
      price: snapshot["price"],
      interested: snapshot["interested"],
    );
  }

  Map<String, dynamic> toJson() => {
        "lid": lid,
        "creator": creator,
        "location": location,
        "description": description,
        "type": type,
        "time": time,
        "price": price,
        "interested": interested,
      };
}
