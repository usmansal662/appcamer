import 'dart:io';
import 'package:camery/src/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:photo_view/photo_view.dart';

class PhotoOpenMap extends StatefulWidget {
  List<File> images;
  int index;
  PhotoOpenMap({super.key, required this.images, required this.index});

  @override
  State<PhotoOpenMap> createState() => _PhotoOpenMapState();
}

class _PhotoOpenMapState extends State<PhotoOpenMap> {
  late PageController controller;
  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.scaffoldBgColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text(
            '<  Back',
            style: TextStyle(
                fontSize: 18, color: Colors.white, fontFamily: 'poppins'),
          ),
        ),
      ),
      body: PageView.builder(
        itemCount: widget.images.length,
        controller: controller,
        itemBuilder: (contxet, index) {
          return PhotoView(
            imageProvider: FileImage(widget.images[index]),
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 1.8,
            initialScale: PhotoViewComputedScale.contained,
          );
        },
      ),
    );
  }
}
