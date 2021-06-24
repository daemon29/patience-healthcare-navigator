import 'package:intl/intl.dart';

class Visit {
  String date, patientName;
  List<VisitNote> notes;

  Visit(List<VisitNote> notes) {
    this.date = DateFormat.yMd().format(DateTime.now());
    this.patientName = "";
    this.notes = notes;
  }
  Visit.fromJson(Map<String, dynamic> object) {
    date = object['date'];
    patientName = object['patientName'];
    Iterable notesObjects = object['notes'];
    notes = List<VisitNote>.from(notesObjects.map(
        (e) => VisitNote.fromJson(e))); // cannot pass visitnote obj in here
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> notesJson =
        notes == null ? null : notes.map((e) => e.toJson()).toList();
    return {
      'date': date,
      'patientName': patientName,
      'notes': notesJson,
    };
  }
}

class VisitNote {
  String title, time, date, body;

  VisitNote() {
    DateTime now = DateTime.now();
    this.date = DateFormat.yMd().format(now);
    this.time = DateFormat.jm().format(now);
    this.title = "";
    this.body = "";
  }
  VisitNote.fromJson(Map<String, dynamic> object) {
    title = object['title'];
    time = object['time'];
    date = object['date'];
    body = object['body'];
  }

  Map<String, dynamic> toJson() =>
      {"title": title, "time": time, "date": date, "body": body};
}
