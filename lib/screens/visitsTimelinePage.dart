import 'dart:convert';

import 'package:expandable/expandable.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hospital_stay_helper/class/visit.dart';
import 'package:hospital_stay_helper/components/tapEditBox.dart';
import 'package:hospital_stay_helper/main.dart';
import 'package:hospital_stay_helper/screens/visitDetailPage.dart';
import '../class/sharePref.dart';

class VisitsTimelinePage extends StatefulWidget {
  VisitsTimelinePage({Key key}) : super(key: key);

  @override
  _VisitsTimelinePageState createState() => _VisitsTimelinePageState();
}

class _VisitsTimelinePageState extends State<VisitsTimelinePage> {
  final String purpleTheme = "#66558E";
  final String lightPinkTheme = "#FDEBF1";
  final String darkPinkTheme = "#ED558C";
  final String blueTheme = "#44B5CD";
  // final String darkGreenTheme = "#758C20";
  final String lightGreenTheme = "#A1BF36";

  List<Visit> visits = [];
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  @override
  void initState() {
    _loadSaved();
    super.initState();

    // VisitNote myTestNote1 = VisitNote.fromJson({
    //   'title': "Checked in at Legacy",
    //   'time': "NOW",
    //   'date': "Today",
    //   'body': "Detail about this happended",
    // });
    // List<Map<String, dynamic>> myTestNotes = [
    //   {
    //     'title': "Checked in at Legacy",
    //     'time': "NOW",
    //     'date': "Today",
    //     'body': "Detail about this happended",
    //   }
    // ];

    // Visit myTestVisit = Visit.fromJson({
    //   'date': 'Today',
    //   'patientName': 'Sally',
    //   'notes': myTestNotes,
    // });

    // visits.add(myTestVisit);
  }

  void updateVisit() async {
    await MySharedPreferences.instance
        .setStringValue('visits', jsonEncode(visits));
  }

  void createVisit() {
    setState(() {
      listKey.currentState
          .insertItem(0, duration: const Duration(milliseconds: 500));
      visits.insert(0, Visit(notes: [VisitNote()]));
    });
    updateVisit();
  }

  void deleteVisit(int visitIndex) {
    setState(() {
      visits.removeAt(visitIndex);
      listKey.currentState.removeItem(visitIndex,
          (_, animation) => visitWidget(context, visitIndex, animation),
          duration: const Duration(milliseconds: 500));
    });
    updateVisit();
  }

  void createNote(Visit visit) {
    setState(() {
      visit.notes.insert(0, VisitNote());
    });
    updateVisit();
  }

  void deleteNote(Visit visit, int noteIndex) {
    setState(() {
      visit.notes.removeAt(noteIndex);
    });
    updateVisit();
  }

  getPageDescription() {
    return Padding(
        child: Card(
          color: Colors.white,
          child: Padding(
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text(
                  "Welcome to your Visit Timeline. Here, you can keep organized records of each hospital visit.\n",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
                Text(
                  'Tap "+"" to create a new visit. Tap your visit to edit and add notes.',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
              ]),
              padding: EdgeInsets.fromLTRB(15, 11, 15, 11)),
        ),
        padding: EdgeInsets.fromLTRB(0, 12, 0, 12));
  }

  void updateVisitData(Visit visit, String type, String data) {
    setState(() {
      switch (type) {
        case 'date':
          {
            visit.date = data;
          }
          break;
        case 'patientName':
          {
            visit.patientName = data;
          }
          break;
      }
    });
    updateVisit();
  }

  // update note here, pass to detailpage:
  void updateNoteData(Visit visit, int noteIndex, String type, String data) {
    setState(() {
      switch (type) {
        case 'title':
          {
            visit.notes[noteIndex].title = data;
          }
          break;
        case 'time':
          {
            visit.notes[noteIndex].time = data;
          }
          break;
        case 'date':
          {
            visit.notes[noteIndex].date = data;
          }
          break;
        case 'body':
          {
            visit.notes[noteIndex].body = data;
          }
          break;
      }
    });
    updateVisit();
  }

  _loadSaved() async {
    String _savedVisits =
        await MySharedPreferences.instance.getStringValue('visits');
    if (_savedVisits.isNotEmpty) {
      Iterable tmp = jsonDecode(_savedVisits);
      setState(() {
        visits = List<Visit>.from(tmp.map((model) => Visit.fromJson(model)));
      });
    }
  }

  Widget visitWidget(BuildContext context, int index, animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset(0, 0),
      ).animate(animation),
      child: GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VisitDetailPage(
                        key: PageStorageKey('visitdetailpage'),
                        visitIndex: index,
                        updateVisitFunction: updateVisitData,
                        updateNoteFunction: updateNoteData,
                        deleteVisit: deleteVisit,
                        visit: visits[index],
                        createNewNote: createNote,
                        deleteNoteFunction: deleteNote,
                      ))),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            decoration: BoxDecoration(
                color: HexColor(lightGreenTheme),
                borderRadius: BorderRadius.circular(5.0),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3))
                ]),
            // height: 310,
            child: Column(
              children: [
                // Visit info line:
                Row(
                  // This makes child alignment work (patientName):
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // This aligns date/patient containers
                  children: [
                    // Date:
                    // TapEditBox(
                    //   visit: visits[index],
                    //   dataType: 'date',
                    //   inputData: visits[index].date,
                    //   defaultText: 'Visit date',
                    //   isEditingVisit: true,
                    //   updateFunction: updateVisitData,
                    //   boxDecoration: BoxDecoration(
                    //       color: Colors.white,
                    //       // border: Border.all(),
                    //       borderRadius: BorderRadius.circular(8.0)),
                    //   height: 32.0,
                    //   width: 120.0,
                    // ),
                    Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(5.0),
                        margin: EdgeInsets.all(7.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            // border: Border.all(),
                            borderRadius: BorderRadius.circular(8.0)),
                        height: 32.0,
                        width: 120.0,

                        // Date text:
                        child: RichText(
                          text: TextSpan(
                              text: visits[index].date.isEmpty
                                  ? "Visit date"
                                  : '${visits[index].date}',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 17)),
                          textAlign: TextAlign.center,
                        )),

                    // Patient name:

                    // Container(
                    //   alignment: Alignment.topRight,
                    // child: TapEditBox(
                    //   visit: visits[index],
                    //   dataType: 'patientName',
                    //   inputData: visits[index].patientName,
                    //   defaultText: "Enter name",
                    //   isEditingVisit: true,
                    //   updateFunction: updateVisitData,
                    //   boxDecoration: BoxDecoration(
                    //       color: Colors.white,
                    //       // border: Border.all(),
                    //       borderRadius: BorderRadius.circular(8.0)),
                    //   height: 32.0,
                    //   width: 140.0,
                    // ),
                    // ),
                    Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(5.0),
                        margin: EdgeInsets.all(7.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            // border: Border.all(),
                            borderRadius: BorderRadius.circular(8.0)),
                        height: 32.0,
                        width: 140.0,

                        // Patient text:
                        child: RichText(
                          text: TextSpan(
                              text: visits[index].patientName.isEmpty
                                  ? "Patient's name"
                                  : '${visits[index].patientName}',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 17)),
                          textAlign: TextAlign.center,
                        )),
                  ],
                ),

                // Note:
                Column(
                  children: [
                    Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 5.0),
                        padding: const EdgeInsets.all(15.0),
                        height: 200, // TODO: make dynamic
                        decoration: BoxDecoration(
                          color: Colors.white,
                          // border: Border.all(),
                          borderRadius: BorderRadius.circular(20.0),
                          // boxShadow: [
                          // BoxShadow(
                          //     color: Colors.grey.withOpacity(0.5),
                          //     spreadRadius: 5,
                          //     blurRadius: 7,
                          //     offset: Offset(0, 3))
                          // ]
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          // Title and note body will be contained within this:

                          children: [
                            // Title line:
                            Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Note title:
                                    Expanded(
                                        flex: 2,
                                        child: RichText(
                                            text: TextSpan(
                                                text: visits[index]
                                                        .notes[0]
                                                        .title
                                                        .isEmpty
                                                    ? "Untitled note"
                                                    : ('${visits[index].notes[0].title}'),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline6))),

                                    // Note date/time:
                                    Expanded(
                                        child: Container(
                                            height: 85,
                                            alignment: Alignment.topRight,
                                            // padding: EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              border: Border.all(),
                                            ),
                                            child: Column(
                                              children: [
                                                // TODO: Replace placeholders:
                                                Container(
                                                  alignment: Alignment.center,
                                                  height: 26.0,
                                                  width: 100.0,
                                                  padding: EdgeInsets.all(3.0),
                                                  margin: EdgeInsets.all(7.0),
                                                  child: RichText(
                                                      text: TextSpan(
                                                    text: visits[index]
                                                            .notes[0]
                                                            .time
                                                            .isEmpty
                                                        ? "Visit time"
                                                        : '${visits[index].notes[0].time}',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17),
                                                  )),
                                                ),
                                                Container(
                                                  alignment: Alignment.center,
                                                  height: 26.0,
                                                  width: 100.0,
                                                  padding: EdgeInsets.all(3.0),
                                                  margin: EdgeInsets.all(7.0),
                                                  child: RichText(
                                                      text: TextSpan(
                                                    text: visits[index]
                                                            .notes[0]
                                                            .date
                                                            .isEmpty
                                                        ? "Visit date"
                                                        : '${visits[index].notes[0].date}',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17),
                                                  )),
                                                ),
                                              ],
                                            ))),
                                  ],
                                )),

                            // Note body:
                            Expanded(
                              flex: 2,
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 1.0, vertical: 8.0),
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      // border: Border.all(),
                                      borderRadius: BorderRadius.circular(5.0)),
                                  // Note text:
                                  child: RichText(
                                    text: TextSpan(
                                        text: visits[index]
                                                .notes[0]
                                                .body
                                                .isEmpty
                                            ? 'Enter a description for this note...'
                                            : '${visits[index].notes[0].body}',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 17)),
                                  )),
                            ),
                          ],
                        )),
                  ],
                ),

                // "More" icon:
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.more_horiz,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                    ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(primary: Colors.red[600]),
                        // Icon(Icons.add),
                        child: Icon(Icons.delete),
                        onPressed: () {
                          deleteVisit(index);
                        }),
                  ],
                ),
              ],
            ),
          )),
    );
  }

  getVisits() {
    return AnimatedList(
        key: listKey,
        initialItemCount: visits.length,
        itemBuilder: (context, index, animation) {
          // Visit:
          return visitWidget(context, index, animation);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: HexColor(purpleTheme),
        floatingActionButton: FloatingActionButton(
          backgroundColor: HexColor(blueTheme),
          child: Icon(Icons.add),
          onPressed: () {
            createVisit();
          },
        ),
        body: Column(
          children: [
            getPageDescription(),
            Expanded(child: getVisits()),
          ],
        ));
  }
}
