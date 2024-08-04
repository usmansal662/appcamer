// ignore_for_file: must_be_immutable

import 'package:camery/src/pages/camera_page.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class Temp8 extends StatelessWidget {
  Temp8({
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
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 80,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(lat, long),
                        zoom: 14,
                      ),
                      myLocationButtonEnabled: false,
                      markers: {
                        Marker(
                            markerId: MarkerId(DateTime.now().toString()),
                            position: LatLng(lat, long))
                      },
                      onMapCreated: setGoogleMapController,
                      zoomControlsEnabled: false,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                          color: const Color(0xffF38607),
                          borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        DateFormat('dd,MMMyyyy  hh:mm a')
                            .format(DateTime.now()),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic),
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
                  ],
                ),
              ),
            ],
          ),
          FittedBox(
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: Get.width * 0.5,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      color:
                          const Color.fromARGB(87, 20, 19, 19).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16)),
                  child: Center(
                    child: Text(
                      "Lat:${lat.toStringAsFixed(4)}   Long:${long.toStringAsFixed(4)}",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Container(
                  height: 40,
                  width: Get.width * 0.5,
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      color:
                          const Color.fromARGB(87, 20, 19, 19).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icon/weatherIcon.png',
                      ),
                      Text(
                        "${weatherVal.toString()} °C",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 18),
                      ),
                      FittedBox(
                        child: Text(
                          weatherDesription,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  GoogleMapController? googleMapController;
  void setGoogleMapController(GoogleMapController controller) {
    googleMapController = controller;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, long),
          zoom: 14,
        ),
      ),
    );
  }
}
