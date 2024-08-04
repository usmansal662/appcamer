// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Temp5 extends StatelessWidget {
  Temp5(
      {super.key,
      required this.location,
      required this.lat,
      required this.long,
      required this.weatherVal});

  final String location;
  final double lat;
  final double long;
  int weatherVal;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.23,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: const Color(0xffFFFF94).withOpacity(0.2)
          // image: DecorationImage(
          //     image: AssetImage('assets/templates/temp5Bg.png'),
          //     fit: BoxFit.fill),
          ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: 60,
              width: Get.width * 0.5,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  border: Border.all(
                    color: Colors.white,
                  )),
              child: const Text(
                'Enjoy Holiday',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w400),
              ),
            ),
            Text(
              DateFormat('EEE: dd/MM/yyy').format(DateTime.now()),
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LATITUDE:',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                    Text(
                      lat.toStringAsFixed(4),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LONGITUDE:',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                    Text(
                      long.toStringAsFixed(4),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              DateFormat('hh:mm a').format(DateTime.now()),
              style: const TextStyle(color: Colors.black, fontSize: 18),
            ),
            Text(
              location,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
