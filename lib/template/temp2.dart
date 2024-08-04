// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Temp2 extends StatelessWidget {
  Temp2(
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
      height: 105,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: const Color.fromARGB(159, 148, 140, 140).withOpacity(0.5),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icon/weatherIcon.png'),
                Text(
                  "${weatherVal.toString()} °C",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 22),
                ),
              ],
            ),
          ),
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
                  "Lat : ${lat.toStringAsFixed(4)}",
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  "Long : ${long.toStringAsFixed(4)}",
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  DateFormat('hh:mm a').format(DateTime.now()),
                  style: const TextStyle(
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
