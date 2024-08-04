// ignore_for_file: must_be_immutable

import 'package:camery/src/pages/camera_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Temp11 extends StatelessWidget {
  Temp11({
    super.key,
    required this.location,
    required this.lat,
    required this.long,
    required this.weatherVal,
  });

  final String location;
  final double lat;
  final double long;
  int weatherVal;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
          color: const Color.fromARGB(186, 14, 14, 14).withOpacity(0.4),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  child: Row(
                    children: [
                      Container(
                        height: 35,
                        decoration: BoxDecoration(
                            color: const Color(0xffBE3B0F),
                            borderRadius: BorderRadius.circular(30)),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          DateFormat('dd,MMMyyyy').format(DateTime.now()),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Container(
                        height: 35,
                        decoration: BoxDecoration(
                            color: const Color(0xffF3AF07),
                            borderRadius: BorderRadius.circular(30)),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          DateFormat('hh:mm a').format(DateTime.now()),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    location,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                FittedBox(
                  child: Row(
                    children: [
                      Container(
                        height: 40,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(85, 235, 235, 139)
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          "Lat:${lat.toStringAsFixed(4)}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        height: 40,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(85, 235, 235, 139)
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          "Long:${long.toStringAsFixed(4)}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.amber,
                  ),
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icon/weatherIcon.png',
                  ),
                  Text(
                    "${weatherVal.toString()} °C",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 22),
                  ),
                  Text(
                    "${weatherDesription}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}