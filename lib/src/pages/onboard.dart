// ignore_for_file: body_might_complete_normally_nullable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camery/src/pages/home/homeScreen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../utils/colors.dart';
import '../utils/preferences.dart';

class OnBoard extends StatefulWidget {
  const OnBoard({super.key});

  @override
  State<OnBoard> createState() => _OnBoardState();
}

class _OnBoardState extends State<OnBoard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    super.initState();
    if (Preferences.getSavePath().isEmpty) {
      savePath();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/splash-bg.png'),
                fit: BoxFit.fill)),
        child: Stack(
          children: [
            const Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'GPS Photo With',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Map & Location',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Capture the World: Where Every Photo\nTells a Place',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 17,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: Get.height * 0.1),
                  child: Image.asset(
                    'assets/images/surface.png',
                    height: 100,
                  ),
                )),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: Get.height * 0.15),
                child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                            0, -40 * (0.5 - (_controller.value - 0.5).abs())),
                        child: child,
                      );
                    },
                    child: Image.asset(
                      'assets/images/bounce.png',
                      height: 140,
                    )),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: Get.height * 0.03),
                child: isLoading
                    ? const CupertinoActivityIndicator(
                        color: Colors.white,
                        radius: 30,
                      )
                    : Builder(
                        builder: (context) {
                          final GlobalKey<SlideActionState> key = GlobalKey();
                          return Container(
                            height: Get.height * 0.07,
                            width: Get.width * 0.8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(60),
                              color: const Color(0xff8136DD),
                            ),
                            child: SlideAction(
                              key: key,
                              alignment: Alignment.bottomCenter,
                              sliderButtonIcon: Container(
                                height: 50,
                                width: 50,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                child: Image.asset(
                                  'assets/icon/arrow.gif',
                                  height: 10,
                                  width: 10,
                                ),
                              ),
                              text: '     Slide to Get Started',
                              textStyle: const TextStyle(
                                  fontFamily: 'poppins',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                              innerColor: Colors.transparent,
                              outerColor: const Color(0xff8136DD),
                              onSubmit: () {
                                // Future.delayed(const Duration(seconds: 1), () {
                                //   setState(() {
                                //     isLoading = true;
                                //   });
                                //   Future.delayed(const Duration(seconds: 1), () {
                                //     setState(() {
                                //       isLoading = false;
                                //     });
                                Get.offAll(
                                  () => const HomeScreen(),
                                );
                                //   });
                                // });
                              },
                            ),
                          );
                        },
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void savePath() async {
    // try {
    //   final directory = await getExternalStorageDirectory();
    //   var pathdir = directory?.path.split('Android');

    //   final myImagePath = '${pathdir?[0]}GPSMapCameraTimeStampTag';

    //   final myImgDir = await Directory(myImagePath).create(recursive: true);
    //   Preferences.setSavePath(myImgDir.path);
    // } catch (e) {
    final directory = await getApplicationDocumentsDirectory();
    Preferences.setSavePath(directory.path);
    // }
  }
}
