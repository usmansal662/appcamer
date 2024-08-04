// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Temp1 extends StatelessWidget {
  Temp1(
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
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: const Color.fromARGB(159, 34, 33, 33).withOpacity(0.2),
          borderRadius: BorderRadius.circular(60)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  DateFormat('hh:mm a').format(DateTime.now()),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${weatherVal.toString()} °C",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 22),
                ),
                Image.asset('assets/icon/weatherIcon.png')
              ],
            ),
          ),
        ],
      ),
    );
  }
}
