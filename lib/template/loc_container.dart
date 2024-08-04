// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class locContainer extends StatelessWidget {
  const locContainer({
    super.key,
    required this.location,
    required this.lat,
    required this.long,
    required this.height,
  });

  final String location;
  final String lat;
  final String long;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset(
            'assets/images/locIcon.png',
            height: Get.height * 0.1,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location,
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  lat,
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  long,
                  style: const TextStyle(color: Colors.white),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
