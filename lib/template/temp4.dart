// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Temp4 extends StatelessWidget {
  Temp4(
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
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10.0),
          bottomRight: Radius.circular(10.0),
        ),
        border: Border(
          left: BorderSide(
            color: Colors.white, // or whatever color you want
            width: 2.0, // or whatever width you want
          ),
          right: BorderSide(
            color: Colors.white, // or whatever color you want
            width: 2.0, // or whatever width you want
          ),
          bottom: BorderSide(
            color: Colors.white, // or whatever color you want
            width: 2.0, // or whatever width you want
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 40,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                border: Border.all(
                  color: Colors.white,
                )),
            child: Row(
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
          ),
          const SizedBox(
            height: 10,
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
                        color: Colors.white70,
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
                        color: Colors.white70,
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
