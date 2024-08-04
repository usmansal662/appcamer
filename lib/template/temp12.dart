// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../src/pages/camera_page.dart';

class Temp12 extends StatelessWidget {
  Temp12({
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
          color: const Color.fromARGB(186, 14, 14, 14).withOpacity(0.6),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                      color: const Color(0xffBE3B0F),
                      borderRadius: BorderRadius.circular(30)),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    DateFormat('dd,MMMyyyy  hh:mm a').format(DateTime.now()),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 2,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(35, 100, 98, 98)
                          .withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30)),
                  child: FittedBox(
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
                            "${weatherDesription}",
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  location,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 50,
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
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 40,
            width: Get.width,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: const Color.fromARGB(69, 190, 59, 15).withOpacity(0.4),
                borderRadius: BorderRadius.circular(22)),
            child: Center(
              child: Text(
                "Lat:${lat.toStringAsFixed(4)}      |        Long:${long.toStringAsFixed(4)}",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
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
