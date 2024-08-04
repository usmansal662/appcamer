// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Temp3 extends StatelessWidget {
  Temp3(
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
      height: 120,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: const Color.fromARGB(159, 148, 140, 140),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                location,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w500),
              ),
              Image.asset('assets/icon/weatherIcon.png'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'LATITUDE:',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      lat.toStringAsFixed(4),
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
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'LONGITUDE:',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      long.toStringAsFixed(4),
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      DateFormat('dd/MM/yyy').format(DateTime.now()),
                      style: const TextStyle(
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
