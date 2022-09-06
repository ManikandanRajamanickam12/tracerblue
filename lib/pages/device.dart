import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:tracerblue/pages/home.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({Key? key}) : super(key: key);

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  late Query ref;
  List saveddevices = [];
  List savedlocation = [];
  List savedtimestamp = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ref = FirebaseDatabase.instance
        .ref()
        .child('movesense_devices')
        .orderByChild('last-update');
  }

  DateTime convert(timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return date;
  }

  var newFormat = DateFormat("yMd");
  var timeFormat = DateFormat("jm");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffEDEDED),
        body: SingleChildScrollView(
          child: Container(
            child: SafeArea(
                child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(15),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_sharp),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Container(
                      child: const Text(
                        "TracerBlue",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
                Neumorphic(
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    intensity: 1,
                    depth: 2,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(15)),
                    lightSource: LightSource.topLeft,
                    color: Color(0xffEDEDED),
                    shadowLightColorEmboss: Colors.white,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: EdgeInsets.only(left: 25, top: 15),
                          child: const Text(
                            "All Devices",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          )),
                      Container(
                        padding: EdgeInsets.all(15),
                        color: Color(0xffEDEDED),
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.75,
                        child: FirebaseAnimatedList(
                          query: ref,
                          itemBuilder: (BuildContext context,
                              DataSnapshot snapshot,
                              Animation<double> animation,
                              int index) {
                            Map contact = snapshot.value as Map;
                            // print(contact);

                            contact['key'] = snapshot.key;
                            // print(contact["key"]);
                            String location = contact["location"];
                            savedlocation.add(location);
                            // List devices = contact["devices"] as List;
                            // saveddevices.add(devices);
                            int timestamp = contact["last-update"];
                            savedtimestamp.add(convert(timestamp));
                            savedtimestamp = savedtimestamp.toSet().toList();

                            return Container(
                              child: Column(
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
                                            color:
                                                Colors.black.withOpacity(0.8),
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
                                        boxShape: NeumorphicBoxShape.roundRect(
                                            BorderRadius.circular(100)),
                                        lightSource: LightSource.topLeft,
                                        color: Color(0xffEDEDED),
                                        shadowLightColorEmboss: Colors.white,
                                      ),
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        padding: EdgeInsets.all(15),
                                        child: SvgPicture.asset(
                                            'assets/run.svg',
                                            alignment: Alignment.center,
                                            width: 10,
                                            height: 40,
                                            fit: BoxFit.scaleDown),
                                      ),
                                    ),
                                    trailing: Container(
                                      padding: EdgeInsets.only(top: 20),
                                      child: Column(
                                        children: [
                                          Text(
                                            newFormat
                                                .format(savedtimestamp[index])
                                                .toString(),
                                            style: TextStyle(
                                                color: Colors.black
                                                    .withOpacity(0.8),
                                                fontSize: 15),
                                          ),
                                          Text(
                                            timeFormat
                                                .format(savedtimestamp[index])
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
                                    height: 10,
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )),
          ),
        ));
  }
}
