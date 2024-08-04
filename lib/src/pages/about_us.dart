import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'photoGaller/photoGallery.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage('assets/images/slidingpuzzleBg.png'),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              repAppBar(
                fn: () {
                  Get.back();
                },
                title: 'About Us',
              ),
              SizedBox(
                height: Get.height * 0.03,
              ),
              const Text(
                'Welcome to GPS Map Camera TimeStamp Tag – your ultimate companion for capturing moments with precision and detail. Our app seamlessly integrates advanced GPS technology with your camera, allowing you to add location, date, and time stamps to your photos effortlessly',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
