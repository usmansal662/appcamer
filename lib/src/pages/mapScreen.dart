// ignore_for_file: file_names

import 'dart:io';
import 'dart:ui';
import 'package:camery/src/pages/photoGaller/photoView.dart';
import 'package:camery/src/pages/puzzles/puzzlesolscreen.dart';
import 'package:camery/src/photoopenmap.dart';
import 'package:camery/src/utils/colors.dart';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:camery/model/locationModel.dart';
import 'package:camery/src/pages/camera_page.dart';
import 'package:camery/src/pages/photoGaller/photoGallery.dart';
import 'package:camery/src/utils/preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:photo_manager/photo_manager.dart' as photo;
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  gmaps.GoogleMapController? googleMapController;
  List<gmaps.Marker> markers = [];

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      updateMarker();
    } else {
      updateMarkerIOS();
    }
  }

  bool _isWithinDistance(
      gmaps.LatLng loc1, gmaps.LatLng loc2, double distanceInKm) {
    return Geolocator.distanceBetween(
          loc1.latitude,
          loc1.longitude,
          loc2.latitude,
          loc2.longitude,
        ) <=
        distanceInKm * 1000; // Convert km to meters
  }

  Map<gmaps.LatLng, List<File>> _groupImagesByProximity(
      Map<gmaps.LatLng, List<File>> imageLocations) {
    final groupedLocations = <gmaps.LatLng, List<File>>{};

    for (final entry in imageLocations.entries) {
      final location = entry.key;
      final images = entry.value;

      bool added = false;
      for (final groupedEntry in groupedLocations.entries) {
        if (_isWithinDistance(location, groupedEntry.key, 0.05)) {
          // 0.05 km
          groupedEntry.value.addAll(images);
          added = true;
          break;
        }
      }

      if (!added) {
        groupedLocations[location] = images;
      }
    }

    return groupedLocations;
  }

  void _onMarkerTapped(gmaps.LatLng position) {
    if (imageLocations.containsKey(position)) {
      final images = imageLocations[position]!;
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  childAspectRatio: 0.7),
              itemBuilder: (context, index) {
                return effectButton(
                  onClick: () {
                    Get.to(() => PhotoOpenMap(
                          images: images,
                          index: index,
                        ));
                  },
                  child: Image.file(
                    images[index],
                  ),
                );
              },
            ),
          );
        },
      );
    } else {
      final markerId = markers
          .firstWhere((marker) => marker.position == position)
          .markerId
          .value;
      final index = int.tryParse(markerId.replaceFirst('predefined_', ''));
      if (index != null && index < Preferences.latlongList.length) {
        final location = Preferences.latlongList[index];
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                itemCount: Preferences.latlongList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    childAspectRatio: 0.7),
                itemBuilder: (context, index) {
                  return effectButton(
                    onClick: () {
                      Get.to(() => PhotoViewPage(imageUrl: location.imageUrl));
                    },
                    child: Image.file(
                      File(location.imageUrl),
                    ),
                  );
                },
              ),
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/slidingpuzzleBg.png'),
              fit: BoxFit.fill),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 40),
          child: Column(
            children: [
              repAppBar(
                fn: () {
                  Get.back();
                },
                title: 'My Visits',
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 200,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xff8E36FF).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FittedBox(
                  child: Row(
                    children: List.generate(
                      2,
                      (index) {
                        bool isSatellite = index == 0;
                        bool isSelected =
                            Preferences.getSetaliteMap() == isSatellite;
                        return InkWell(
                          onTap: () {
                            Preferences.setSetaliteMap(isSatellite);
                            setState(() {});
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: isSelected
                                  ? const Color(0xff8E36FF)
                                  : Colors.transparent,
                            ),
                            child: Text(
                              isSatellite ? 'Satellite View' : 'Normal View',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'poppins',
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: gmaps.GoogleMap(
                        mapType: Preferences.getSetaliteMap()
                            ? gmaps.MapType.hybrid
                            : gmaps.MapType.normal,
                        initialCameraPosition: gmaps.CameraPosition(
                          target: gmaps.LatLng(lat, long),
                          zoom: 15,
                        ),
                        onMapCreated: setGoogleMapController,
                        markers: markers.toSet(),
                        zoomControlsEnabled: false,
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: effectButton(
                        onClick: () {
                          googleMapController?.animateCamera(
                            gmaps.CameraUpdate.newCameraPosition(
                              gmaps.CameraPosition(
                                target: gmaps.LatLng(lat, long),
                                zoom: 14,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 60,
                          width: 55,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: AppColor.primaryColor),
                          child: const Icon(
                            Icons.gps_fixed,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void setGoogleMapController(gmaps.GoogleMapController controller) {
    googleMapController = controller;
    controller.moveCamera(
      gmaps.CameraUpdate.newCameraPosition(
        gmaps.CameraPosition(
          target: gmaps.LatLng(lat, long),
          zoom: 14,
        ),
      ),
    );
  }

  Future<void> updateMarker() async {
    ByteData data = await rootBundle.load('assets/icon/markerIcon.png');
    Codec codec = await instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 80,
    );
    FrameInfo fi = await codec.getNextFrame();
    Uint8List bytes = (await fi.image.toByteData(format: ImageByteFormat.png))!
        .buffer
        .asUint8List();

    List<LocationModel> list = Preferences.latlongList;

    // Add predefined markers
    List<gmaps.Marker> predefinedMarkers = List.generate(
      list.length,
      (index) => gmaps.Marker(
        markerId: gmaps.MarkerId('predefined_${index.toString()}'),
        icon: gmaps.BitmapDescriptor.fromBytes(
          bytes,
        ),
        position: gmaps.LatLng(list[index].lat, list[index].long),
        infoWindow: const gmaps.InfoWindow(),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  itemCount: Preferences.latlongList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      childAspectRatio: 0.7),
                  itemBuilder: (context, index) {
                    return effectButton(
                      onClick: () {
                        Get.to(() =>
                            PhotoViewPage(imageUrl: list[index].imageUrl));
                      },
                      child: Image.file(
                        File(list[index].imageUrl),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );

    // Group and add markers for images
    final groupedLocations = _groupImagesByProximity(imageLocations);
    List<gmaps.Marker> imageMarkers = groupedLocations.entries.map((entry) {
      final location = entry.key;
      final images = entry.value;
      final lastImage =
          images.last; // Use the last image for marker representation

      return gmaps.Marker(
        markerId: gmaps.MarkerId(location.toString()),
        position: location,
        icon: gmaps.BitmapDescriptor.bytes(lastImage.readAsBytesSync(),
            width: 35, height: 35), // Use the same icon or define another one
        infoWindow: gmaps.InfoWindow(
          title: '${images.length} images',
        ),
        onTap: () => _onMarkerTapped(location),
      );
    }).toList();

    // Combine both marker lists
    markers = [...predefinedMarkers, ...imageMarkers];
    setState(() {});
  }

  Future<void> updateMarkerIOS() async {
    ByteData data = await rootBundle.load('assets/icon/markerIcon.png');
    Codec codec = await instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 80,
    );
    FrameInfo fi = await codec.getNextFrame();
    Uint8List bytes = (await fi.image.toByteData(format: ImageByteFormat.png))!
        .buffer
        .asUint8List();
    List<LocationModel> list = Preferences.latlongList;
    markers = List.generate(
      list.length,
      (index) => Marker(
        markerId: MarkerId(DateTime.now().microsecondsSinceEpoch.toString()),
        icon: BitmapDescriptor.fromBytes(bytes),
        position: LatLng(list[index].lat, list[index].long),
        infoWindow: const InfoWindow(),
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  itemCount: Preferences.latlongList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      childAspectRatio: 0.7),
                  itemBuilder: (context, index) {
                    return effectButton(
                      onClick: () {
                        Get.to(() =>
                            PhotoViewPage(imageUrl: list[index].imageUrl));
                      },
                      child: Image.file(
                        File(list[index].imageUrl),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );

    setState(() {});
  }
}

Map<gmaps.LatLng, List<File>> imageLocations = {};

Future<void> fetchImagesWithLocation() async {
  final permitted = await photo.PhotoManager.requestPermissionExtend();
  if (!permitted.isAuth) {
    // Handle permission denial
    return;
  }

  final albums =
      await photo.PhotoManager.getAssetPathList(type: photo.RequestType.image);
  for (final album in albums) {
    final assetCount = await album.assetCountAsync; // Wait for the asset count
    final images = await album.getAssetListRange(start: 0, end: assetCount);
    for (final image in images) {
      final file = await image.file;
      if (file != null) {
        final tags = await readExifFromBytes(file.readAsBytesSync());
        if (tags != null &&
            tags.containsKey('GPS GPSLatitude') &&
            tags.containsKey('GPS GPSLongitude')) {
          final latValues = tags['GPS GPSLatitude']!.values!.cast<Ratio>();
          final longValues = tags['GPS GPSLongitude']!.values!.cast<Ratio>();
          final latRef = tags['GPS GPSLatitudeRef']!.printable;
          final longRef = tags['GPS GPSLongitudeRef']!.printable;

          final latitude = _convertToDegree(latValues, latRef!);
          final longitude = _convertToDegree(longValues, longRef!);

          final location = gmaps.LatLng(latitude, longitude);
          if (!imageLocations.containsKey(location)) {
            imageLocations[location] = [file];
          } else {
            final existingFiles = imageLocations[location]!;
            bool isDuplicate = existingFiles
                .any((existingFile) => existingFile.path == file.path);
            if (!isDuplicate) {
              imageLocations[location]!.add(file);
            }
          }
        }
      }
    }
  }
}

double _convertToDegree(List<Ratio> values, String ref) {
  final double degrees = _ratioToDouble(values[0]);
  final double minutes = _ratioToDouble(values[1]);
  final double seconds = _ratioToDouble(values[2]);

  double result = degrees + (minutes / 60.0) + (seconds / 3600.0);

  if (ref == 'S' || ref == 'W') {
    result = -result;
  }
  return result;
}

double _ratioToDouble(Ratio ratio) {
  return ratio.numerator.toDouble() / ratio.denominator.toDouble();
}
