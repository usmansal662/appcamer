import 'dart:io';

import 'package:camery/src/check_update/update.dart';
import 'package:camery/src/pages/puzzles/puzzlesolscreen.dart';
import 'package:camery/src/pages/settings/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RateUsScreen extends StatefulWidget {
  const RateUsScreen({super.key});

  @override
  State<RateUsScreen> createState() => _RateUsScreenState();
}

class _RateUsScreenState extends State<RateUsScreen> {
  final List<String> _emojis = [
    '😵',
    '😑',
    '😐',
    '😃',
    '😍',
  ];
  final List<String> _emojistxt = [
    'Worst',
    'Bad',
    'Okay',
    'Happy',
    'Superb',
  ];
  double _value = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/slidingpuzzleBg.png'),
              fit: BoxFit.fill),
        ),
        child: Center(
          child: Container(
            height: Get.height * 0.5,
            width: Get.width * 0.95,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/icon/settingcurve.png'),
                  fit: BoxFit.fill),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Color(0xffC4A4EE)),
                        child: const Text(
                          'X',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w500),
                        ),
                      )),
                  SizedBox(
                    height: Get.height * 0.05,
                  ),
                  const Center(
                    child: Text(
                      'How\'s Your\nExperience So Far?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20.69,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'poppins'),
                    ),
                  ),
                  SizedBox(
                    height: Get.height * 0.02,
                  ),
                  Center(
                      child: SizedBox(
                    height: 80,
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: _emojis.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            child: Column(
                              children: [
                                effectButton(
                                    onClick: () {
                                      setState(() {
                                        _value = index + 1;
                                      });
                                    },
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: _value == index + 1
                                              ? Color(0xff725596)
                                              : Colors.transparent,
                                          shape: BoxShape.circle),
                                      child: Text(
                                        _emojis[index],
                                        style: const TextStyle(fontSize: 32),
                                      ),
                                    )),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  _emojistxt[index],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'poppins'),
                                )
                              ],
                            ),
                          );
                        }),
                  )),
                  const SizedBox(
                    height: 20,
                  ),
                  const Center(
                    child: Text(
                      'We would love to know!',
                      style: TextStyle(color: Color(0xff6B6B6B)),
                    ),
                  ),
                  effectButton(
                    onClick: () {
                      if (Platform.isAndroid) {
                        if (_value <= 2) {
                          goToContactUs();
                        } else {
                          launchPlayStore();
                        }
                      } else {
                        launchAppStore();
                      }
                    },
                    child: Container(
                      height: 70,
                      width: Get.width,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/icon/btn.png'))),
                      child: const Center(
                        child: Text(
                          'Submit',
                          style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'poppins',
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
