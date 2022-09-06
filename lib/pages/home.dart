// ignore_for_file: unnecessary_const

import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:tracerblue/main.dart';
import 'package:tracerblue/pages/card.dart';
import 'package:tracerblue/pages/device.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool location = false;
  bool scanning = false;
  String place = "Enter the Location";
  String savePlace = "";
  String? errmsg;
  final placeController = TextEditingController();
  AutovalidateMode _autoValidate = AutovalidateMode.disabled;
  List device = [];
  DatabaseReference ref =
      FirebaseDatabase.instance.ref().child("movesense_devices");

  final formkey = GlobalKey<FormState>();

  savedata() {
    savePlace = place.toLowerCase();
    String result = savePlace.replaceAll(RegExp(' +'), '-');

    // Map<String, dynamic> contact = {
    //   'location': result,
    //   'devices': device.toSet().toList(),
    //   'last-update': ServerValue.timestamp,
    // };
    device = device.toSet().toList();
    device.forEach((element) {
      ref.update({
        element: {
          'location': result,
          "device": element,
          'last-update': ServerValue.timestamp,
        }
      });
    });
    // ref.push().set(contact);
  }

  List saveddevices = [];
  List savedlocation = [];
  List savedtimestamp = [];
  late Query _ref;
  Map? data1;
  List savedone = [];
  List _resultList = [];
  fetch() async {
    _ref = FirebaseDatabase.instance
        .ref()
        .child('movesense_devices')
        .orderByChild('last-update')
        .limitToLast(2);
  }

  display() {
    _ref.onChildAdded.listen((event) {
      data1 = event.snapshot.value as Map;
      Map<String, dynamic>.from(event.snapshot.value as dynamic)
          .forEach((key, value) {
        _resultList.add(value);
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // _ref = FirebaseDatabase.instance
    //     .ref()
    //     .child('movesense_devices')
    //     .orderByChild('last-update')
    //     .limitToLast(2);
    fetch();
    display();
  }

  DateTime convert(timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return date;
  }

  var newFormat = DateFormat("yMd");
  var timeFormat = DateFormat("jm");
  bool fetchdata = true;
  bool seperate = false;
  bool updatescan = false;
  @override
  Widget build(BuildContext context) {
    print(_resultList);

    return Scaffold(
      backgroundColor: const Color(0xffEDEDED),
      // resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(35),
                    child: const Text(
                      "TracerBlue",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Neumorphic(
                    style: NeumorphicStyle(
                      shape: NeumorphicShape.flat,
                      intensity: 1,
                      depth: 2,
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(15)),
                      lightSource: LightSource.topLeft,
                      color: const Color(0xffEDEDED),
                      shadowLightColorEmboss: Colors.white,
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 180,
                              padding: const EdgeInsets.only(
                                  top: 10, left: 20, bottom: 10),
                              child: const Text(
                                "Recently Found",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            TextButton(
                              child: const Text(
                                "VIEW ALL DEVICES",
                                style: const TextStyle(color: Colors.red),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const DevicePage()),
                                );
                              },
                            ),
                          ],
                        ),
                        if (fetchdata == true && updatescan == false) ...[
                          Container(
                            padding: const EdgeInsets.only(top: 10),
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.height * 0.18,
                            child: RefreshIndicator(
                              onRefresh: () {
                                return Future.delayed(
                                    const Duration(seconds: 1), () {
                                  setState(() {
                                    fetch();
                                    display();
                                    seperate = true;
                                    fetchdata = false;
                                  });
                                });
                              },
                              child: FirebaseAnimatedList(
                                query: _ref,
                                itemBuilder: (BuildContext context,
                                    DataSnapshot snapshot,
                                    Animation<double> animation,
                                    int index) {
                                  Map contact = snapshot.value as Map;

                                  // contact['key'] = snapshot.key;
                                  // print(contact["key"]);
                                  String location = contact["location"];
                                  savedlocation.add(location);
                                  // List devices = contact["devices"] as List;
                                  // saveddevices.add(devices);
                                  int timestamp = contact["last-update"];
                                  savedtimestamp.add(convert(timestamp));
                                  savedtimestamp =
                                      savedtimestamp.toSet().toList();

                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              savedlocation[index],
                                              style: TextStyle(
                                                color: Colors.black
                                                    .withOpacity(0.8),
                                                fontSize: 20,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 3,
                                            ),
                                            Text(
                                              contact["device"],
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        ),
                                        leading: Neumorphic(
                                          style: NeumorphicStyle(
                                            shape: NeumorphicShape.flat,
                                            intensity: 1,
                                            depth: 3,
                                            boxShape:
                                                NeumorphicBoxShape.roundRect(
                                                    BorderRadius.circular(100)),
                                            lightSource: LightSource.topLeft,
                                            color: const Color(0xffEDEDED),
                                            shadowLightColorEmboss:
                                                Colors.white,
                                          ),
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            padding: const EdgeInsets.all(15),
                                            child: SvgPicture.asset(
                                                'assets/run.svg',
                                                alignment: Alignment.center,
                                                width: 10,
                                                height: 40,
                                                fit: BoxFit.scaleDown),
                                          ),
                                        ),
                                        trailing: Container(
                                          padding:
                                              const EdgeInsets.only(top: 20),
                                          child: Column(
                                            children: [
                                              Text(
                                                newFormat
                                                    .format(
                                                        savedtimestamp[index])
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.black
                                                        .withOpacity(0.8),
                                                    fontSize: 15),
                                              ),
                                              Text(
                                                timeFormat
                                                    .format(
                                                        savedtimestamp[index])
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.black
                                                        .withOpacity(0.8),
                                                    fontSize: 15),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      )
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ] else if (seperate == true && fetchdata == false) ...[
                          Container(
                            padding: const EdgeInsets.only(top: 10),
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.height * 0.2,
                            child: Column(
                              children: [
                                ListTile(
                                  title: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _resultList[0],
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.8),
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(_resultList[1],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                  leading: Neumorphic(
                                    style: NeumorphicStyle(
                                      shape: NeumorphicShape.flat,
                                      intensity: 1,
                                      depth: 3,
                                      boxShape: NeumorphicBoxShape.roundRect(
                                          BorderRadius.circular(100)),
                                      lightSource: LightSource.topLeft,
                                      color: const Color(0xffEDEDED),
                                      shadowLightColorEmboss: Colors.white,
                                    ),
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      padding: const EdgeInsets.all(15),
                                      child: SvgPicture.asset('assets/run.svg',
                                          alignment: Alignment.center,
                                          width: 10,
                                          height: 40,
                                          fit: BoxFit.scaleDown),
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Column(
                                      children: [
                                        Text(
                                          newFormat
                                              .format(convert(_resultList[2]))
                                              .toString(),
                                          style: TextStyle(
                                              color:
                                                  Colors.black.withOpacity(0.8),
                                              fontSize: 15),
                                        ),
                                        const SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                          timeFormat
                                              .format(convert(_resultList[2]))
                                              .toString(),
                                          style: TextStyle(
                                              color:
                                                  Colors.black.withOpacity(0.8),
                                              fontSize: 15),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                ListTile(
                                  title: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _resultList[3],
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.8),
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(_resultList[4],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                  leading: Neumorphic(
                                    style: NeumorphicStyle(
                                      shape: NeumorphicShape.flat,
                                      intensity: 1,
                                      depth: 3,
                                      boxShape: NeumorphicBoxShape.roundRect(
                                          BorderRadius.circular(100)),
                                      lightSource: LightSource.topLeft,
                                      color: const Color(0xffEDEDED),
                                      shadowLightColorEmboss: Colors.white,
                                    ),
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      padding: const EdgeInsets.all(15),
                                      child: SvgPicture.asset('assets/run.svg',
                                          alignment: Alignment.center,
                                          width: 10,
                                          height: 40,
                                          fit: BoxFit.scaleDown),
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Column(
                                      children: [
                                        Text(
                                          newFormat
                                              .format(convert(_resultList[5]))
                                              .toString(),
                                          style: TextStyle(
                                              color:
                                                  Colors.black.withOpacity(0.8),
                                              fontSize: 15),
                                        ),
                                        const SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                          timeFormat
                                              .format(convert(_resultList[5]))
                                              .toString(),
                                          style: TextStyle(
                                              color:
                                                  Colors.black.withOpacity(0.8),
                                              fontSize: 15),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ] else if (fetchdata == false &&
                            updatescan == true) ...[
                          Container(
                            padding: const EdgeInsets.only(top: 10),
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.height * 0.2,
                            child: SingleChildScrollView(
                              child: StreamBuilder<List<ScanResult>>(
                                  stream: FlutterBlue.instance.scanResults,
                                  initialData: [],
                                  builder: (c, snapshot) => Column(
                                        children: snapshot.data!.map((r) {
                                          if (r.device.name
                                              .startsWith("Movesense")) {
                                            return ScanResultTile(
                                              result: r,
                                            );
                                          } else {
                                            return Container(
                                              width: 0,
                                              height: 0,
                                            );
                                          }
                                        }).toList(),
                                      )),
                            ),
                          ),
                        ]
                      ]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: SvgPicture.asset('assets/blue.svg',
                        alignment: Alignment.center,
                        width: 90,
                        height: 100,
                        fit: BoxFit.fill),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.175,
                    child: Column(
                      children: [
                        if (location == false) ...[
                          Column(
                            children: [
                              Text(
                                place,
                                style: const TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              TextButton(
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              side: const BorderSide(
                                                  color: Colors.black)))),
                                  onPressed: (() {
                                    setState(() {
                                      location = true;
                                    });
                                  }),
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: 180,
                                    child: const Text(
                                      "CHANGE LOCATION NAME",
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black),
                                    ),
                                  ))
                            ],
                          ),
                        ] else ...[
                          Column(
                            children: [
                              Neumorphic(
                                style: NeumorphicStyle(
                                  shape: NeumorphicShape.flat,
                                  intensity: 1,
                                  depth: -2,
                                  boxShape: NeumorphicBoxShape.roundRect(
                                      BorderRadius.circular(12)),
                                  lightSource: LightSource.topLeft,
                                  color: const Color(0xff00000029),
                                  shadowLightColorEmboss: Colors.white,
                                ),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  child: Form(
                                    key: formkey,
                                    autovalidateMode: _autoValidate,
                                    child: TextFormField(
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500),
                                      cursorColor:
                                          Colors.black.withOpacity(0.8),
                                      textAlign: TextAlign.start,
                                      controller: placeController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.only(
                                            top: 10.0,
                                            bottom: 10,
                                            left: 15,
                                            right: 10),
                                        suffixIcon: const Icon(
                                          Icons.edit,
                                          color: Colors.black,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value!.isEmpty &&
                                            value.length < 32) {
                                          errmsg =
                                              "Enter the location not exceeds 32 letters";
                                          return errmsg;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              NeumorphicButton(
                                style: NeumorphicStyle(
                                    shape: NeumorphicShape.flat,
                                    boxShape: NeumorphicBoxShape.roundRect(
                                        BorderRadius.circular(18)),
                                    intensity: 1,
                                    depth: 3,
                                    color: const Color(0xffECECEF)),
                                onPressed: () {
                                  place = placeController.text;
                                  setState(() {
                                    if (place == "Enter the Location" ||
                                        place.isEmpty ||
                                        place.length > 32) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Enter the location not exceeds 32 letters")),
                                      );
                                    } else {
                                      place = placeController.text;
                                      location = false;
                                    }
                                  });

                                  // placeController.clear();
                                },
                                child: Text(
                                  "CONFIRM",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black.withOpacity(0.7),
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Column(
                    children: [
                      if (scanning == false) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: NeumorphicButton(
                            style: NeumorphicStyle(
                                shape: NeumorphicShape.flat,
                                boxShape: NeumorphicBoxShape.roundRect(
                                    BorderRadius.circular(18)),
                                intensity: 1,
                                depth: 3,
                                color: const Color(0xffECECEF)),
                            onPressed: () {
                              setState(() {
                                scanning = true;
                                fetchdata = false;
                                seperate = false;
                                updatescan = true;

                                FlutterBlue.instance.startScan(
                                    timeout: const Duration(seconds: 20));

                                var result = FlutterBlue.instance.scanResults;
                                result.listen((event) {
                                  event.forEach((r) {
                                    if (r.device.name.startsWith("Movesense")) {
                                      device.add(r.device.name
                                          .substring(10, r.device.name.length));
                                    }
                                  });

                                  // device.add(event.map((ScanResult r) {
                                  //   if (r.device.name
                                  //       .startsWith("Movesense")) {
                                  //     return r.device.name.substring(
                                  //         10, r.device.name.length);
                                  //   } else {
                                  //     return "0";
                                  //   }
                                  // }));
                                });
                              });
                            },
                            child: Container(
                              width: 140,
                              height: 22,
                              alignment: Alignment.center,
                              child: const Text(
                                "START SCAN",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        Container(
                          height: MediaQuery.of(context).size.height * 0.1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "SCANNING FOR DEVICES",
                                style: TextStyle(
                                    color: Color(0xff3F3D56),
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              TextButton(
                                  onPressed: () {
                                    FlutterBlue.instance.stopScan();
                                    place = placeController.text;
                                    setState(() {
                                      if (place != "Enter the Location" &&
                                          place != "") {
                                        savedata();
                                        scanning = false;
                                        fetchdata = true;
                                        updatescan = false;

                                        _resultList.clear();
                                      } else {
                                        place = "Enter the Location";
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: const Text(
                                                    "Location field Can't be empty")));
                                      }
                                    });
                                  },
                                  child: const Text(
                                    "TAP TO CANCEL",
                                    style: TextStyle(
                                      color: Color(0xff3F3D56),
                                    ),
                                  ))
                            ],
                          ),
                        )
                      ]
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
