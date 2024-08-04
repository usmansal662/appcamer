// ignore_for_file: file_names

import 'dart:io';

import 'package:camery/src/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

class PhotoViewPage extends StatefulWidget {
  final String imageUrl;

  const PhotoViewPage({super.key, required this.imageUrl});

  @override
  State<PhotoViewPage> createState() => _PhotoViewPageState();
}

class _PhotoViewPageState extends State<PhotoViewPage> {
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
        actions: [
          IconButton(
            onPressed: () {
              _saveLocalImage();
            },
            icon: const Icon(
              Icons.save,
            ),
          ),
          IconButton(
            onPressed: () {
              Share.shareFiles([widget.imageUrl]);
            },
            icon: const Icon(
              Icons.share,
            ),
          ),
        ],
      ),
      body: PhotoView(
        imageProvider: FileImage(File(widget.imageUrl)),
        minScale: PhotoViewComputedScale.contained * 0.8,
        maxScale: PhotoViewComputedScale.covered * 1.8,
        initialScale: PhotoViewComputedScale.contained,
      ),
    );
  }

  _saveLocalImage() async {
    await ImageGallerySaver.saveImage(File(widget.imageUrl).readAsBytesSync());
    Get.snackbar('Image', 'Save to gallery', colorText: Colors.white);
  }
}
