// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'card.dart';

class FindDevicesScreen extends StatefulWidget {
  @override
  State<FindDevicesScreen> createState() => _FindDevicesScreenState();
}

class _FindDevicesScreenState extends State<FindDevicesScreen> {
  final fieldcontroller = TextEditingController();

  final formkey = GlobalKey<FormState>();

  String location = "";

  AutovalidateMode _autoValidate = AutovalidateMode.disabled;

  DatabaseReference ref =
      FirebaseDatabase.instance.ref().child("movesense_devices");

  List device = [];
  bool showdata = true;

  savedata() {
    location = fieldcontroller.text.toString().toLowerCase();
    String result = location.replaceAll(RegExp(' +'), '-');

    Map<String, dynamic> contact = {
      'location': result,
      'devices': device.toSet().toList(),
      'last-update': ServerValue.timestamp,
    };
    ref.push().set(contact);
    fieldcontroller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xffECECEF),
      body: RefreshIndicator(
        backgroundColor: Colors.white54,
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SafeArea(
                child: Container(
                  height: 50,
                  padding: EdgeInsets.all(10),
                  child: const Text(
                    "Netrin BLE Devices",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.2,
                  alignment: Alignment.center,
                  child: Neumorphic(
                    style: NeumorphicStyle(
                      color: Color(0xffECECEF),
                      shape: NeumorphicShape.concave,
                      depth: -2,
                      shadowLightColorEmboss: Colors.white,
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(5)),
                      shadowLightColor: Colors.grey,
                      shadowDarkColor: Colors.grey,
                    ),
                    child: Form(
                      key: formkey,
                      autovalidateMode: _autoValidate,
                      child: TextFormField(
                        controller: fieldcontroller,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                            // border: InputBorder.none,
                            hintText: 'Current Location'),
                        validator: (value) {
                          if (value!.isEmpty && value.length < 32) {
                            return "Enter the location not exceeds 32 letters";
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Neumorphic(
                style: NeumorphicStyle(
                  color: Color(0xffECECEF),
                  shape: NeumorphicShape.concave,
                  depth: -2,
                  shadowLightColorEmboss: Colors.white,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(5)),
                  shadowLightColor: Colors.grey,
                  shadowDarkColor: Colors.grey,
                ),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.63,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        StreamBuilder<List<BluetoothDevice>>(
                          stream: Stream.periodic(Duration(seconds: 2))
                              .asyncMap(
                                  (_) => FlutterBlue.instance.connectedDevices),
                          initialData: [],
                          builder: (c, snapshot) => Column(
                            children: snapshot.data!
                                .map((d) => ListTile(
                                      title: Text(d.name),
                                      subtitle: Text(d.id.toString()),
                                    ))
                                .toList(),
                          ),
                        ),
                        StreamBuilder<List<ScanResult>>(
                            stream: FlutterBlue.instance.scanResults,
                            initialData: [],
                            builder: (c, snapshot) => Column(
                                  children: snapshot.data!.map((r) {
                                    if (r.device.name.startsWith("Movesense") &&
                                        showdata) {
                                      device.add(r.device.name
                                          .substring(10, r.device.name.length));

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
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              NeumorphicButton(
                  style: const NeumorphicStyle(
                      color: Color(0xffECECEF),
                      shape: NeumorphicShape.flat,
                      depth: -2),
                  onPressed: () async {
                    if (!formkey.currentState!.validate()) {
                      setState(() {
                        setState(() => _autoValidate = AutovalidateMode.always);
                      });
                      return;
                    } else {
                      savedata();
                      setState(() {
                        _autoValidate = AutovalidateMode.disabled;
                        showdata = false;
                      });
                    }
                  },
                  child: Text("Save")),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () {
                  FlutterBlue.instance.startScan(timeout: Duration(seconds: 4));
                  showdata = true;
                });
          }
        },
      ),
    );
  }
}
