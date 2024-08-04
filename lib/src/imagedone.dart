// ignore_for_file: must_be_immutable, camel_case_types

import 'dart:io';
import 'package:camery/google%20ads/adId.dart';
import 'package:camery/google%20ads/adservice.dart';
import 'package:camery/google%20ads/constantremote.dart';
import 'package:camery/src/pages/puzzles/puzzlesolscreen.dart';
import 'package:camery/src/utils/apputils.dart';
import 'package:camery/src/utils/preferences.dart';
import 'package:camery/src/widgets/rewardAdDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:camery/model/locationModel.dart';
import 'package:camery/src/pages/camera_page.dart';
import 'package:camery/src/utils/colors.dart';
import 'package:screenshot/screenshot.dart';

class SaveDoneImg extends StatefulWidget {
  File pathed;

  bool iswidgetExist;
  bool isTagExist;
  SaveDoneImg(
      {required this.pathed,
      required this.iswidgetExist,
      required this.isTagExist,
      super.key});

  @override
  State<SaveDoneImg> createState() => _SaveDoneImgState();
}

class _SaveDoneImgState extends State<SaveDoneImg> {
  ScreenshotController screenshotController = ScreenshotController();
  @override
  void initState() {
    setnavbar();
    super.initState();
  }

  bool _isLightsIntLoaded = false;
  bool isrewardWatch = false;

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                    Get.back();
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
                  onClick: () async {
                    if (Preferences.latlongList.length % 3 == 1) {
                      if (AdServices.everythirdImagesavedInterstitial == null &&
                          !AppUtils.isSubscribed &&
                          everythirdImageSavedInterstitial) {
                        AdServices.loadeverythirdImagesavedInterstitial();
                      }
                    }
                    if (!AppUtils.isSubscribed &&
                        everythirdImageSavedInterstitial &&
                        Preferences.latlongList.length % 3 == 1) {
                      await showLoadingDialogInterstialAd(() {
                        if (AdServices.everythirdImagesavedInterstitial !=
                            null) {
                          AdServices.everythirdImagesavedInterstitial?.show();
                        }
                        Get.back();
                      }, sec: 4);
                    }
                    try {
                      final directory = Preferences.getSavePath();
                      String outputPath =
                          '$directory/IMG_${DateTime.now().microsecondsSinceEpoch}.jpg';
                      screenshotController
                          .captureAndSave(outputPath)
                          .then((value) async {
                        if (value != null) {
                          Preferences.addLatLong = LocationModel(
                              address: location?.address ?? '',
                              imageUrl: value,
                              dateTime: DateTime.now(),
                              lat: lat,
                              long: long);
                        }
                      });
                      // }
                    } catch (e) {
                      debugPrint(e.toString());
                    } finally {
                      Get.back();
                      Get.back();
                    }
                  },
                  child: Image.asset(
                    'assets/icon/savebtn.png',
                    height: 40,
                  ),
                )
              ],
            ),
          ),
        ),
        body: Screenshot(
          controller: screenshotController,
          child: Stack(
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
                  !isrewardWatch
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Get.dialog(ChatTimesUpDialog(
                                onExit: (ctx) {
                                  setState(() {});
                                },
                              ), barrierDismissible: false)
                                  .then((value) => setState(() {
                                        isrewardWatch = value[0] ?? false;
                                      }));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    AppColor.lightpinkColor.withOpacity(0.09),
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
                        )
                      : const SizedBox(),
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
              _isLightsIntLoaded ? const LoadingAd() : Container()
            ],
          ),
        ),
      ),
    );
  }
}
