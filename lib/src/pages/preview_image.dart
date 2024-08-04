// ignore_for_file: must_be_immutable, camel_case_types

import 'dart:io';
import 'package:camery/src/imagedone.dart';
import 'package:camery/src/pages/puzzles/puzzlesolscreen.dart';
import 'package:camery/src/utils/apputils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:camery/src/pages/camera_page.dart';
import 'package:camery/src/utils/colors.dart';
import '../utils/images.dart';
import '../utils/preferences.dart';

class PeviewImage extends StatefulWidget {
  File pathed;

  bool iswidgetExist;
  bool isTagExist;
  PeviewImage(
      {required this.pathed,
      required this.iswidgetExist,
      required this.isTagExist,
      super.key});

  @override
  State<PeviewImage> createState() => _PeviewImageState();
}

class _PeviewImageState extends State<PeviewImage> {
  @override
  void initState() {
    setnavbar();
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColor.scaffoldBgColor,
          appBar: PreferredSize(
            preferredSize: Size(Get.width, 70),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      exitDialog();
                    },
                    child: const Text(
                      '<  Back',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontFamily: 'poppins'),
                    ),
                  ),
                  effectButton(
                    onClick: () {
                      Get.to(
                        () => SaveDoneImg(
                          pathed: widget.pathed,
                          iswidgetExist: widget.iswidgetExist,
                          isTagExist: widget.isTagExist,
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/icon/donebtn.png',
                      height: 40,
                    ),
                  )
                ],
              ),
            ),
          ),
          body: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: FittedBox(
                  child: Image.file(
                    File(widget.pathed.path),
                  ),
                ),
              ),
              if (widget.isTagExist)
                if (!AppUtils.isSubscribed)
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.lightpinkColor.withOpacity(0.09),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Image.asset(
                              'assets/icon/applogo.png',
                              height: 30,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'GPS Map Camera\nTimeStamp Tag',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
              Preferences.getTemplate == 'Temp2'
                  ? Positioned(
                      top: 70,
                      left: 0,
                      right: 0,
                      child: Preferences.getTemplate.imageWidget)
                  : Positioned(
                      bottom: 60,
                      left: 20,
                      right: 20,
                      child: Preferences.getTemplate.imageWidget),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: AppImage.tempImgList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Preferences.setTemplate(AppImage.tempImgList[index].$2);
                      setState(() {});
                    },
                    child: Center(
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              AppImage.tempImgList[index].$1,
                              fit: BoxFit.fill,
                            ),
                          ),
                          Visibility(
                              visible: Preferences.getTemplate ==
                                  AppImage.tempImgList[index].$2,
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Icon(
                                    Icons.check_circle,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                ),
                              ))
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class repButton extends StatelessWidget {
  Widget title;
  double height;
  double width;
  repButton({
    super.key,
    required this.title,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        width: width,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/icon/verfCont.png'), fit: BoxFit.cover),
        ),
        child: title);
  }
}

exitDialog() {
  Get.dialog(AlertDialog(
    title: const Text(
      'Are you sure to exit?',
      style: TextStyle(fontFamily: 'poppins'),
    ),
    actions: [
      ElevatedButton(
        style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xff863CE5)),
        onPressed: () {
          Get.back();
        },
        child: const Text(
          'No',
          style: TextStyle(fontFamily: 'poppins'),
        ),
      ),
      ElevatedButton(
        onPressed: () {
          Get.back();
          Get.back();
        },
        child: const Text(
          'Yes',
          style: TextStyle(fontFamily: 'poppins'),
        ),
      ),
    ],
  ));
}
